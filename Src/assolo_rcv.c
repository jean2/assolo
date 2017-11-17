/* FILE: assolo_rcv.c */
/*
 * Copyright (c) 2003 Rice University
 * All Rights Reserved.
 *
 * Permission to use, copy, modify, distribute, and sell this software
 * and its documentation is hereby granted without
 * fee, provided that the above copyright notice appear in all copies
 * and that both that copyright notice and this permission notice
 * appear in supporting documentation, and that the name of Rice
 * University not be used in advertising or publicity pertaining to
 * distribution of the software without specific, written prior
 * permission.  Rice University makes no representations about the
 * suitability of this software for any purpose.  It is provided "as
 * is" without express or implied warranty.
 *
 * RICE UNIVERSITY DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS
 * SOFTWARE, INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND
 * FITNESS, IN NO EVENT SHALL RICE UNIVERSITY BE LIABLE FOR ANY
 * SPECIAL, INDIRECT OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN
 * AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING
 * OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS
 * SOFTWARE.
 *
 * Author: Vinay Ribeiro, vinay@rice.edu.  */

/*
 * "assolo_rcv" receives chirp packets from "assolo_snd", estimates
 *  available bandwidth and writes this to a file.
 *
 *  assolo_rcv.c and related code is based on udpread.c of the NetDyn tool.
 *
 */

/*
 * udpread.c
 * Copyright (c) 1991 University of Maryland
 * All Rights Reserved.
 *
 * Permission to use, copy, modify, distribute, and sell this software and its
 * documentation for any purpose is hereby granted without fee, provided that
 * the above copyright notice appear in all copies and that both that
 * copyright notice and this permission notice appear in supporting
 * documentation, and that the name of U.M. not be used in advertising or
 * publicity pertaining to distribution of the software without specific,
 * written prior permission.  U.M. makes no representations about the
 * suitability of this software for any purpose.  It is provided "as is"
 * without express or implied warranty.
 *
 * U.M. DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE, INCLUDING ALL
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS, IN NO EVENT SHALL U.M.
 * BE LIABLE FOR ANY SPECIAL, INDIRECT OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION
 * OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN
 * CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 * Author:  Dheeraj Sanghi, Department of Computer Science.
 */

#include "assolo_rcv.h"

#ifdef HAVE_SO_TIMESTAMP
	struct msghdr  msg;
	struct iovec   iov[1];
	struct cmsghdr *cmptr;
#endif

FILE *fd_debug;	/* file pointer for debug file */
// TODO Maybe bugged ? Check if needed and if runner and receiver use it.
// Only if Debug mode is ON valgrind remarks
// This file Line 291
/*
==32320== Invalid free() / delete / delete[]
==32320==    at 0x4024B3A: free (vg_replace_malloc.c:366)
==32320==    by 0x40C2AA9: fclose@@GLIBC_2.1 (iofclose.c:88)
==32320==    by 0x8049421: main (assolo_rcv.c:276)
==32320==  Address 0x41c4a88 is 0 bytes inside a block of size 352 free'd
==32320==    at 0x4024B3A: free (vg_replace_malloc.c:366)
==32320==    by 0x40C2AA9: fclose@@GLIBC_2.1 (iofclose.c:88)
==32320==    by 0x804918C: close_all (assolo_rcv.c:276)
==32320==    by 0x804C46D: sig_alrm (signal_alrm_rcv.c:97)
==32320==    by 0x40916E7: ??? (in /lib/tls/i686/cmov/libc-2.11.1.so)
==32320==    by 0x80495DE: main (assolo_rcv.c:454)
*/

socklen_t fromlen = 1;	/* Must be non-zero, used in recvfrom(). */

struct in_addr 			src_addr;
struct itimerval 		cancel_time,timeout;	/* used in setitimer*/
struct itimerval 		wait_time;		/* sigalrm time */
struct sockaddr_in 		src;			/* socket addr for outgoing packets */
struct sockaddr_in 		dst;			/* socket addr for incoming packets */
struct control_rcv2snd	*pkt;				/* control packet pointer*/
struct udprecord 		*udprecord;		/* log record for a packet */
struct pkt_info 		*packet_info;		/* keeps track of packet numbers, receive time, send time*/
struct chirprecord 		*chirp_info;

int debug 		= 0;
int jumbo		= 1;		/* number of pkts per jumbo packet */
int cc			= 0;
int state		= 0;
int ack_not_rec_count	= 0;
int lowcount		= 0;
int highcount		= 0;		/*used in sending range updates */
int next_ok_due		= 0;		/* used to send OK packets to sender */
int created_arrays	= 0;
int filter		= 0;
int busy_period_thresh	= 5;		/* parameters for excursion detection algorithm */
int num_inst_bw		= 11;		/* number of estimates to smooth over for mean */
int inst_head		= 0;		/* pointer to current location in circular buffer */
int inst_bw_count	= 0;		/* total number of chirps used in estimation till now*/
int pktsize		= 1000;
int num_pkts_in_info	= 0;		/* how big packet_info currently is*/
int sndPort 		= SNDPORT;	/* destination UDP port */
int net_option		= 1; 		/* network option, Gbps or not */
int remote_host_broken	= 0;
int no_chirps_recd	= 0;
int soudp;			/* socket for udp connection */
int pkts_per_write;		/* how many packet are expected to arrive at each write interval */
int max_good_pkt_this_chirp;	/* used in chirps affected by coalescence */
int num_interarrival;		/* number of different interarrivals to keep track of */
int first_chirp;
int last_chirp;			/* keeps track of first and last chirp numbers currently in the records */
int chirps_per_write;		/* how many chirps will there be per write timer interrupt */

u_int32_t request_num		= 0;	/* current request number */
u_int32_t sender_request_num	= 0;	/* current request number */
u_int32_t chal_no		= 0;
u_int32_t cur_num		= 0;	/* current control packet number */

char data[MAXMESG];			/* Maxm size packet */
char data_snd[MAXMESG];			/* Maxm size packet */
char hostname[MAXHOSTNAMELEN];
char localhost[MAXHOSTNAMELEN];		/* string with local host name */

double total_inst_bw_excursion	= 0.0;	/* sum of chirp estimates over the number of estimates specified */
double mx_inst			= 0.0;
double ls_inst			= 0.0;
double den_vhf			= 0.0;
double old_inst_mean		= 0.0;
double perc_bad_chirps		= 0.0;	/* In the last write interval how many chirps were affected by context switching */
double decrease_factor		= 1.5;	/* parameters for excursion detection algorithm */
double context_receive_thresh	= 0.000010;	/* 10us */
double low_rate			= DEFAULT_MIN_RATE;	/* rate range in chirp (Mbps) */
double high_rate		= DEFAULT_MAX_RATE; 	/* rate range in chirp (Mbps) */
double avg_rate			= DEFAULT_AVG_RATE;	/* rate range in chirp (Mbps) */
double soglia			= DEFAULT_SGL; 		/* treshold */
double spread_factor		= 1.2;			/* decrease in spread of packets within the chirp*/
double inter_chirp_time;		/* time between chirps as stated by the sender */
double chirp_duration;			/* transmission time of one chirp */
double write_interval;			/* how often to write to file */
double min_timer;			/* minimum timer granularity */
double stop_time;			/* time to stop experiment */
double *inst_bw_estimates_excursion;	/* pointer to interarrivals to look for */
double *qing_delay;
double *qing_delay_cumsum;
double *rates;
double *av_bw_per_pkt;
double *iat;


/* variables form assolo_rcv_tcp.c*/
struct	sockaddr_in receiver;	/* Own address/port etc. */
struct	sockaddr_in remoteaddr;	/* remote's address/port */

int	so1;			/* socket id for incoming pkts */
int	rcv_size = MAXRCVBUF;	/* socket receive buffer size */

/* Extra variables. -- Suman */
int 	new_so1;		/* Actual socket id for incoming msg */
int	flag_on_recv;
int	argc_val=0;

char paramstring[PARAMSTRING_MAX];
char instbw_remote[PARAMSTRING_MAX];
char *params;
char *argv_array[ARGVARRAY_MAX];	/* Array of pointers to the parameters*/


/* //TODO Comment Function */
void reset_pars()
{
  fromlen = 1;			/* must be non-zero, used in recvfrom() */
  debug = 0;
  jumbo = 1;			/* number of pkts per jumbo packet */
  request_num = 0;		/* current request number */
  sender_request_num = 0;	/* current request number */
  chal_no = 0;
  cc = 0;
  state = 0;
  ack_not_rec_count = 0;
  lowcount = 0;
  highcount = 0;		/* used in sending range updates */

  next_ok_due = 0;		/* used to send OK packets to sender */

  created_arrays = 0;

  cur_num = 0;			/* current control packet number */

  total_inst_bw_excursion = 0.0;	/* sum of chirp estimates over
					 * the number of estimates specified */

  perc_bad_chirps = 0.0;	/* in the last write interval how many
				 * chirps were affected by context
				 * switching */

  /* parameters for excursion detection algorithm */
  decrease_factor = 1.5;
  busy_period_thresh = 5;

  /* context switching threshold */
  context_receive_thresh = 0.000010;	/* 10us */

  num_inst_bw = 11;		/* number of estimates to smooth over for
				 * mean */

  inst_head = 0;		/* pointer to current location in circular
				 * buffer */

  inst_bw_count = 0;		/* total number of chirps used in estimation
				 * till now */

  pktsize=1000;

  /* rate range in chirp (Mbps) */
  low_rate = DEFAULT_MIN_RATE;
  high_rate = DEFAULT_MAX_RATE;
  avg_rate = DEFAULT_AVG_RATE;

  soglia = DEFAULT_SGL;		/* treshold */
  filter = 0;			/* filter type */

  spread_factor = 1.2;		/* decrease in spread of packets within
				 * the chirp*/
  num_pkts_in_info = 0;		/* how big packet_info currently is */

  sndPort = SNDPORT;		/* destination UDP port */

  net_option = 1;		/* network option, Gbps or not */
  argc_val = 0;
  remote_host_broken = 0;
}


/* //TODO Comment Function */
in_addr_t gethostaddr(char *	name)
{
  in_addr_t			addr;
  register struct hostent *	hp;

  addr = (in_addr_t)inet_addr (name);
  if (addr != -1)
    return (addr);

  hp = gethostbyname(name);
  if (hp != NULL)
    return (*((in_addr_t *) hp->h_addr));
  else
    return (0);
}


/* usage information */
void usage()
{
  fprintf(stderr,"usage: assolo_rcv\n");
  fprintf(stderr, "\t -h Help. Produces this output\n");
  fprintf(stderr, "\t -v version\n");
  fprintf(stderr, "\t -D print debug information \n");

  exit(1);
}


/* close all open files and sockets */
void close_all()
{
  /* cancelling timer*/
  setitimer(ITIMER_REAL, &cancel_time, 0);
  if (debug)
    fprintf(stderr,"Cancelled timer\n");

  close(soudp);
  close(new_so1);

  if (debug)
    {
      if(fd_debug!=NULL)
	{
	  fflush(fd_debug);
	  fclose(fd_debug);
	}
    }
}


/* //TODO Comment Function */
void create_listen_socket()
{
  /* create a socket for conenction with sender */
  so1 = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
  if (so1 < 0)
    {
      perror("assolo_rcv_tcp: socket");
      exit(1);
    }

  /* initialize address/port etc for incoming connection */
  bzero((char *) &receiver, sizeof(receiver));
  receiver.sin_family = AF_INET;
  receiver.sin_port = htons(TCPRCVPORT);

  /* the following is to use socket even if already bound */
  flag_on_recv = YES;

  if (setsockopt(so1, SOL_SOCKET, SO_REUSEADDR,
		 (char *) &flag_on_recv, sizeof(flag_on_recv)) < 0)
    {
      perror("assolo_rcv_tcp: setsockopt failed");
      exit(1);
    }

  /* bind the address/port number to the socket */
  if (bind (so1, (struct sockaddr *) &receiver, sizeof(receiver)) < 0)
    {
      perror("assolo_rcv_tcp: bind");
      exit(1);
    }

  /* set receive buffers to maximum so that packets are not lost if
   * for some reason this program does not get CPU for some time. */
  if (setsockopt(so1, SOL_SOCKET, SO_RCVBUF,
		 (char *) &rcv_size, sizeof(rcv_size)) < 0)
    {
      perror("assolo_rcv_tcp: receive buffer option");
      exit(1);
    }

  /* First we get a connect from the sender. Then we setup */
  /* a connection to the receiver. -- Suman */
  if (listen(so1,1) < 0)
    {
      perror("assolo_rcv_tcp: listen");
      exit(1);
    }

  return;
}


/* wait for remote host to connect, get parameters from remote  */
void remote_connection()
{

  int tcp_no_delay = 1;		/* Variable to use to set the TCP Push
				 * bit, in the setsockopt system call */

  new_so1 = accept(so1, (struct sockaddr *) &remoteaddr, &fromlen);
  if (new_so1 < 0)
    {
      perror("assolo_rcv_tcp: accept");
      remote_host_broken = 1;
      return;
    }

  if (setsockopt (new_so1, IPPROTO_TCP, TCP_NODELAY,
		  (char *) &tcp_no_delay, sizeof(tcp_no_delay)) < 0)
    {
      perror("assolo_rcv_tcp: TCP_NODELAY_options");
    }

  if (read(new_so1, paramstring, PARAMSTRING_MAX) == 0)
    {
      perror("assolo_rcv_tcp: read error");
      remote_host_broken = 1;
      return;
    }
  paramstring[PARAMSTRING_MAX - 1] = '\0';

  /* split received parameters into array of strings  */
  params = strtok(paramstring, ":");

  argc_val = 0;
  /* setup argc_val and argv_array  */
  while ((params != NULL) && (argc_val < ARGVARRAY_MAX))
    {
      argv_array[argc_val] = params;	/*store location in array*/
      argc_val++;
      params = strtok(NULL, ":");
    }
  if (argc_val == ARGVARRAY_MAX)
    {
      fprintf(stderr, "assolo_rcv_tcp: too many parameters\n");
      remote_host_broken = 1;
      return;
    }

  argv_array[argc_val] = params;/*store location in array*/
}

/*real time*/
#ifdef RT_PROCESS
int set_real_time_priority(void)
{
  struct sched_param schp;
  
  /*
   * set the process to real-time privs
   */
  memset(&schp, 0, sizeof(schp));
  schp.sched_priority = sched_get_priority_max(SCHED_FIFO);

  if (sched_setscheduler(0, SCHED_FIFO, &schp) != 0)
    {
      perror("sched_setscheduler");
      return -1;
    }

  return 0;
}
#endif


/* main function executing all others */
int main(int	argc, char	*argv[])
{
  /*create a TCP socket for listening */
  create_listen_socket();

  min_timer=timer_gran();	/* find minimum timer granularity */

  /*
   * Start the signal handler for SIGALRM.
   * The timer is started whenever a packet from a
   * new chirp is received.
   * Compute available bandwidth after each timer expires.
   */
  Signal(SIGALRM, sig_alrm);	/* in signal_alrm_rcv.c */
  Signal(SIGPIPE, sig_pipe);	/* in signal_alrm_rcv.c */

  lockMe();	/* make sure memory not overwritten, in realtime.c */

  /* real-time FIFO scheduler */
#ifdef RT_PROCESS
  set_real_time_priority();
#endif

  /* Parse options, in parse_cmd_line_rcv.c */
  parse_cmd_line_rcv(argc, argv);	

  while(1)
    {
      fprintf(stderr,"Waiting for remote host\n");

      /* wait for remote host to make connection */
      remote_connection();

      /* Parse options from assolo_run, in parse_cmd_line_rcv.c */
      parse_cmd_line(argc_val,argv_array);

      if (remote_host_broken != 1)
	{
	  /* allocate memory for different arrays, in alloc_rcv.c */
	  create_arrays();

	  /* contact sender and reply to challenge packet, in control_rcv.c */
	  initiate_connection();

	  /* start receiving chirp packets */
	  receive_chirp_pkts();
	}

      /* free all arrays that were allocated memory */
      free_arrays();
      close_all();
      reset_pars();
    }

  return(0);
}
