#include "assolo_rcv.h"

extern void compute_stats();

extern void sig_alrm(int signo);
extern void sig_pipe(int signo);

/* from Figure 5.6, UNIX network programming */
Sigfunc *Signal(int signo, Sigfunc *func)
{
  struct sigaction act, oact;

  act.sa_handler= func;
  sigemptyset(&act.sa_mask);
  act.sa_flags=0;

#ifdef SA_RESTART
  act.sa_flags |= SA_RESTART; /* SVR4, 4.4BSD */
#endif

  if (sigaction(signo, &act, &oact) <0)
    return (SIG_ERR);

  return (oact.sa_handler);
}

/* If received enough chirps, send OK packet to sender */
void send_ok()
{
  if (last_chirp > next_ok_due)
    {
      if (debug)
	fprintf(stderr,"Sending OK packet\n");
      send_pkt(RECV_OK);
      next_ok_due = last_chirp + MAX_RECV_OK_COUNT / 5;
    }
  return;
}

/* when remote host goes down we get SIGPIPE. Gracefully close connection */
void sig_pipe(int signo)
{
  remote_host_broken = 1;	/*remote host is broken*/
}

/* when alarm goes off, perform bandwidth estimation */
void sig_alrm(int signo)
{
  struct timeval tp_stop;

  gettimeofday(&tp_stop, (struct timezone *) 0);

  if ((double) tp_stop.tv_sec + (((double) tp_stop.tv_usec) / 1000000.0)
      > stop_time)
    {
      send_pkt(STOP);
      /* no need to increment request_num */
    }
  if (debug)
    fprintf(stderr, "num_pkts_in_info=%d\n", num_pkts_in_info);

  if (num_pkts_in_info > 0)
    {
      no_chirps_recd = 0;
      compute_stats();

      send_ok();
      num_pkts_in_info = 0;	/*reset variables*/

      if (sender_request_num < request_num - 1)
	send_pkt(UPDATE_RATES);
      else
      	{
	  if (check_for_new_pars())
	    {
	      /* TODO Bugged Code for automated adjustment of Upper- and
	       * LowerBorder.
	       * Hotfix: Needed for automatic adjustment of the upper and
	       * lower border
	       * Details in "compute_bw_contextsw_rcv.c" Line 368
	       * Uncomment only if you know what you doing */
	      // high_rate = high_rate * 10000;
	      send_pkt(UPDATE_RATES);
	      //high_rate=high_rate / 10000;

	      request_num++;
	    }
      	}
    }
  else
    {
      no_chirps_recd++;
      if (no_chirps_recd > 4)
    	{
	  fprintf(stderr, "\nNot receiving packets from sender, aborting\n");
	  remote_host_broken = 1;
	  close_all();
	  return;
      	}

    }
  /* this timer is set just in case the sender goes down and we are not
   * stuck forever waiting*/
  setitimer(ITIMER_REAL,&timeout,0);

  return;
}


/* Returns minimum timer granularity in secs */
double timer_gran()
{
  struct itimerval tv;
  double granularity;

  /* Find out what is the system clock granularity.  */
  tv.it_interval.tv_sec = 0;
  tv.it_interval.tv_usec = 1;
  tv.it_value.tv_sec = 0;
  tv.it_value.tv_usec = 0;
  setitimer (ITIMER_REAL, &tv, 0);
  setitimer (ITIMER_REAL, 0, &tv);

  granularity = ( (double) tv.it_interval.tv_sec
		  + ((double) tv.it_interval.tv_usec) / 1000000.0 );

  if(debug)
    fprintf(stderr, "min timer gran=%f sec\n", granularity);

  return (granularity);
}
