/* FILE: assolo_snd.c */
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
 * "assolo_snd" sends chirp packet trains to "assolo_rcv" based
 * on specified parameters.
 *
 *  assolo_snd.c is based on udpsend.c of the NetDyn tool.
 * */


/*
 * udpsend.c
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


/*
 * Return the address (in network byte order) of the requested host.
 *
 * We return 0 if we can't find anything.
 */

#include "assolo_snd.h"
#include "delay.h"
#include "network_tools.h"

#define PKTSIZE		1400	/* default packet size */
#define MAXHNAME	100	/* maximum hostname size */

socklen_t fromlen = 1;		/* must be non-zero, used in recvfrom */

struct sockaddr_in	snd;		/* used in binding */
struct sockaddr_in 	dst;		/* destination internet address, one is for the valid destination address and the other */
struct timeval		*tp;		/* used for getting timeofday */
struct timeval		tp1;
struct udprecord 	*sendpkt;	/* udp packet content */
struct control_rcv2snd	*rcvpkt;

u_int32_t jumbo = 1;	/* each jumbo chirp "packet" consists of jumbo number of packets */
u_int32_t request_num;
u_int32_t chal_no;

int debug		= 0;
int nc		= 1;		/* index variable for chirp-count */
int prev_rcv_pkt_num	= 0;
int connected		= 0;		/* 0 = not connected, 1 = connected */
int sndPort		= SNDPORT;
int recv_ok_count	= 0;
int pktsize		= PKTSIZE;	/* packet size */
int pktsend		= 0;		/* number of packets sent so far */
int write_error		= NO;		/* error on sending a packet */
int np;					/* index variable for packet-count */
int cc;
int soudp;
int num_interarrival;		/* number of packets in a chirp minus one */

char data[MAXMESG];		/* Maxm size packet */
char data_rcv[MAXMESG];		/* Maxm size packet */

double gap			= 0;		/* gap in us between 2 trains */
double sleeptime		= 0;		/* sleep in us between 2 bulks */
double largest_inter_arrival	= 0;		/* min/largest inter arrival in the chirp in us*/
double low_rate			= 1.0;		/*lowest rate (Mbps) to probe at*/
double high_rate		= 1.0;
double soglia			= 0.05;
double avg_rate			= 0.3;		/*avg. rate (Mbps) to probe at */
double duration			= 600.0;	/* time in seconds for which to probe at */
double chirp_duration		= 0.0;		/* duration of a chirp */
double spread_factor		= 1.2;		/* decrease in spread of packets within the chirp*/
double inter_chirp_time;

/* Usage information */
int usage()
{
  fprintf(stderr, "usage: assolo_snd [-h] <more options>\n");
  fprintf(stderr, "The options are: \n");
  fprintf(stderr, "\t -U <sender port, default=%d>\n", SNDPORT);
  fprintf(stderr, "\t -h \tHelp: produces this output\n");
  fprintf(stderr, "\t -v version\n");
  fprintf(stderr, "\t -D print debug information\n");
  exit(1);
}

/* //TODO Comment Function */
void parse_cmd_line(int argc, char *argv[])
{
  char	*ptr;			/* to traverse the arguments */

  argv++; argc--;

  /* option processing */
  while (argc > 0)
    {
      ptr = *argv;
      while (*ptr)
	{
	  switch (*ptr++)
	    {
	    case 'U':		/* port */
	      if( *ptr == 0)
		{
		  argc--; argv++;
		  if (*argv == 0)
		    {
		      fprintf(stderr, "assolo_rcv: no port number given with '-U'.\n");
		      exit(1);
		    }
		  sndPort = atoi(*argv);
		}
	      else
		{
		  sndPort = atoi(ptr);
		  *ptr = 0;
		}
	      break;

	    case '-':
	      break;
	    case 'D':
	      debug=1;
	      break;

	    case 'v':
	      fprintf(stderr, "assolo version %s\n", VERSION);
	      exit(0);
	      break;

	    case 'h':		/* help */
	    case 'H':
	      usage();

	    default:
	      fprintf(stderr, "assolo_snd: Unknown option '%c'\n", ptr[-1]);
	      exit(1);
	    }
	}
      argc--; argv++;
    }
}

/* challenge number must be included in every control packet from rcv to snd */
void create_challenge_number()
{
  struct timeval chal_tp;
  gettimeofday(&chal_tp, (struct timezone *) 0);

  srand(hash((u_int32_t) chal_tp.tv_usec, (u_int32_t) chal_tp.tv_sec));

  chal_no = (u_int32_t) (rand());
  if(debug)
    fprintf(stderr, "Creating chall number=%u\n", chal_no);

  return;
}

/* connect to  receiver machine that has passed the test*/
void connect_so()
{
  unsigned int dst_ip = 0;

  if (connect(soudp, (struct sockaddr *) &dst, sizeof (dst)) < 0)
    {
      perror("assolo_snd: could not connect to the receiver");
      exit(1);
    }

  dst_ip = ntohl((unsigned int) dst.sin_addr.s_addr);

  fprintf(stderr, "Connected to %u.%u.%u.%u\n", (dst_ip>>24)&0x000000ff, (dst_ip>>16)&0x000000ff, (dst_ip>>8)&0x000000ff, (dst_ip)&0x000000ff);

  if(debug)
    fprintf(stderr, "connecting socket\n");

  connected = 1;

  return;
}


/* connect to  receiver machine that has passed the test*/
void unconnect_so()
{
  close(soudp);

  /* create a socket to send and receive packets */
  soudp = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
  if (soudp < 0)
    {
      perror("assolo_snd: socket");
      exit(1);
    }

  bzero((char *) &snd, sizeof(snd));
  snd.sin_family = AF_INET;
  snd.sin_addr.s_addr = htonl(INADDR_ANY);
  snd.sin_port = htons(sndPort);

  bind(soudp,(struct sockaddr *) &snd, sizeof(snd));

  if(debug)
    fprintf(stderr, "disconnecting socket\n");

  create_challenge_number();

  fprintf(stderr, "\nWaiting for receiver to setup connection\n");

  nc = 1; /*resetting chirp number */
  connected = 0;

  return;
}

/* //TODO Comment Function */
inline void send_pkt()
{
  u_int32_t crc;
  struct timeval tp_snd;

  gettimeofday(&tp_snd, (struct timezone *) 0);

  sendpkt->timesec = htonl((u_int32_t) tp_snd.tv_sec);
  sendpkt->timeusec = htonl((u_int32_t) tp_snd.tv_usec);
  sendpkt->num = htonl((u_int32_t) (np));
  sendpkt->chirp_num = htonl((u_int32_t) (nc));
  sendpkt->request_num = htonl((u_int32_t) (request_num));

  sendpkt->chal_no=htonl((u_int32_t) (chal_no));

  crc = gen_crc_snd2rcv(sendpkt);
  sendpkt->checksum = htonl((u_int32_t) (crc));

  /* Send jumbo packet out*/

  if (connected)
    cc = write(soudp, data, (size_t) pktsize);
  else
    cc = sendto(soudp, (char *) sendpkt, sizeof(struct udprecord),
		0, (struct sockaddr *) &dst, sizeof(dst));

  /* if receiver shuts down, reset and wait for new connection */
  if (cc < 0)
    {
      fprintf(stderr, "Packet number %d\n", np);
      if (debug)
	fprintf(stderr, "assolo_snd: write/sendto error, resetting\n");

      unconnect_so();
    }
}

/* Setting number of packets, packet interarrival times etc */
int compute_parameters()
{
  int count;
  int pars_ok = 1;
  int k;

  double thr;

  /* Received Data always in network byte order (Big Endian) */

  /* get data from packet
   * Integer Values - use ntonl/htonl to adjust byteorder (Little-/BigEndian)
   * for network transmission */
  jumbo			= (int) ntohl(rcvpkt->jumbo);
  num_interarrival	= (int) ntohl(rcvpkt->num_interarrival);
  pktsize		= (int) ntohl(rcvpkt->pktsize);
  request_num		= (int) ntohl(rcvpkt->request_num);

  /* 64 Bit Integer values
   * The received int64 values are recoded back into double. (IEEE-754)
   * This will mostly prevent the problem of different sizes and representation
   * of double on different platforms
   *  - Adjust Endianess to Host of the int64
   *  - Transform the unint64 into double (IEEE-754) */
  high_rate 		= ( unpack754_64( ntohll(rcvpkt->high_rate) ) );
  inter_chirp_time	= ( unpack754_64( ntohll(rcvpkt->inter_chirp_time) ) );
  low_rate		= ( unpack754_64( ntohll(rcvpkt->low_rate) ) );
  soglia		= ( unpack754_64( ntohll(rcvpkt->soglia) ) );
  spread_factor		= ( unpack754_64( ntohll(rcvpkt->spread_factor) ) );

  /* fprintf(stderr, "\n\nHR: %f\tIC: %f\tLR: %f\tT: %f\tSF: %f\n", high_rate, inter_chirp_time, low_rate, soglia, spread_factor); */

  /* Adjust received values for computing */
  inter_chirp_time = inter_chirp_time * 1000000.0; 	//TODO inter_chirp Adjustment for ... ???
  soglia	= soglia / 100.0;	// f.e 5% to 0.05 for Threshold calculation

  /* check if parameters ok */
  if (pktsize < 40 || spread_factor < 1.05 || inter_chirp_time < 0.0 || low_rate < 0.0 || num_interarrival < 1 || jumbo < 1 || jumbo > 20)
    pars_ok=0;

  chirp_duration=0;

  thr = soglia * ((high_rate - low_rate) / 2);

  k = 0;
  k = (num_interarrival - 1) / 2;

  double *rates_snd = (double *) calloc((int)(MAXCHIRPSIZE-1), sizeof(double));
  double *iat_snd = (double *) calloc((int)(MAXCHIRPSIZE-1), sizeof(double));

  rates_snd[k] = ((high_rate + low_rate) / 2);

  for (count = 0;count < k ;count++)
    {
      rates_snd[k+count+1]=(rates_snd[k+count]+(thr*pow(spread_factor,count)));
      rates_snd[k-count-1]=(rates_snd[k-count]-(thr*pow(spread_factor,count)));
    }

  for (count = 0; count < num_interarrival; count++)
    {
      iat_snd[count] = 8 * ((double) pktsize) / rates_snd[count];
      chirp_duration += iat_snd[count];
    }

  if(debug)
    fprintf(stderr, "chirp %f\n", chirp_duration);

  largest_inter_arrival = iat_snd[0];

  if(debug)
    fprintf(stderr, "largest %f\n", largest_inter_arrival);

  gap = inter_chirp_time - chirp_duration;

  if (gap <= 0.0)
    pars_ok=0;

  return(pars_ok);
}


/* takes care of requests  */
void handle_request(u_int32_t request_type)
{
  int	i;

  switch(request_type)
    {
    case REQ_CONN:		/* waiting for initial packet */
      if(debug)
	fprintf(stderr, "got REQ_conn\n");

      if (connected == 0)
	{
	  request_num = (int) ntohl(rcvpkt->request_num);
	  send_pkt();
	}
      break;

    case CHALL_REPLY:
      /* if checksum is ok then we only have to make sure that
       * the challenge number is present in the packet */
      if(debug)
	fprintf(stderr, "got challenge_reply\n");

      if (ntohl(rcvpkt->chal_no) == chal_no && connected == 0)
	{
	  if(compute_parameters())	/* if parameters not weird */
	    {
	      connect_so();
	    }
	}
      break;

    case UPDATE_RATES:
      /* if connected=1 and IP address matches that of receiver
       * then update rates*/
      if (connected == 1)
	compute_parameters();
      break;

    case STOP:
      if(debug)
	fprintf(stderr, "got STOP\n");

      if (connected == 1)
	{
	  for (i = 1; i <= 10; i++)
	    {
	      sendpkt->num = 0;
	      cc = write(soudp, data, pktsize);
	      if (cc < 0)
		break;
	      if (sleeptime < 10000)
		sleeptime = 10000;
	      usleep(sleeptime);
	    }
	  fprintf(stderr, "\nFinished sending chirps to client\n");

	  unconnect_so();
	}
      /* if connected=1 and current destination,
	 send np=0 packets and set connected=0, create new challenge number */
      break;

    case RECV_OK:
      /*only if packet number has incremented, record the OK packet*/
      if (ntohl(rcvpkt->num) > prev_rcv_pkt_num && connected == 1)
	{
	  recv_ok_count = 0;	/*if exceeds certain number we reset*/
	  if (debug)
	    fprintf(stderr, "Receiving OK packet\n");
	}
      break;

    default:
      if(debug)
	fprintf(stderr, "Invalid request type\n");
      break;

    }

  prev_rcv_pkt_num = (int) ntohl (rcvpkt->num);
}


/* receive packet and verify checksum*/
void recv_pkt()
{
  if(connected)
    cc = read(soudp, data_rcv, MAXMESG);
  else
    cc = recvfrom(soudp, data_rcv, MAXMESG, 0,
		  (struct sockaddr *) &dst, &fromlen);

  if (cc < 0)
    {
      fprintf(stderr, "assolo_snd: read,connected=%d", connected);
      unconnect_so();
      return;
    }

  if(debug)
    fprintf(stderr, "got packet,len=%d\n", cc);

  if(check_crc_rcv2snd(rcvpkt))		/* if packet good */
    {
      if(debug)
	fprintf(stderr, "crc ok\n");

      handle_request(ntohl(rcvpkt->request_type));
    }
  else
    {
      if(debug)
	fprintf(stderr, "crc BAD\n");
    }
}

/* be in select mode for receiving packet, wait only for "time" in usec */
void run_select(unsigned long time)
{
  int num_so;
  struct   timeval tp_select,tp_start;
  fd_set rset;

  tp_select.tv_sec=time/1000000;
  tp_select.tv_usec=time%1000000;

  FD_ZERO(&rset);
  FD_SET(soudp,&rset);

  gettimeofday(&tp_start, (struct timezone *) 0);

  num_so=soudp+1;
  select(num_so,&rset,NULL,NULL,&tp_select);

  if (FD_ISSET(soudp,&rset))
    {
      recv_pkt();
      /* Wait for remaining time. With this setup we only can receive
       * one packet between chirps. To receive more packets we must run
       * select again */
      smartwait(time, &tp_start);
    }

  recv_ok_count++;/* receiver must periodically send packets saying it is ok*/
  if (recv_ok_count > MAX_RECV_OK_COUNT)
    {
      unconnect_so();
      recv_ok_count=0;
    }

  return;
}


/* Send chirps */
void chirps_snd()
{
  int k;
  double thr;
  int count;

  fprintf(stderr, "\rChirp Numer: %d", nc);

  /********* BEGIN CHIRP ********/

  thr = 0.05 * ((high_rate - low_rate) / 2);
  
  k = 0;
  k = (num_interarrival - 1) / 2;

  double *rates_ch = (double *) calloc((int)(MAXCHIRPSIZE-1), sizeof(double));
  double *iat_ch = (double *) calloc((int)(MAXCHIRPSIZE-1), sizeof(double));

  rates_ch[k] = ((high_rate + low_rate) / 2);

  for (count = 0; count < k ; count++)
    {
      rates_ch[k+count+1] = (rates_ch[k+count]+(thr*pow(spread_factor,count)));
      rates_ch[k-count-1] = (rates_ch[k-count]-(thr*pow(spread_factor,count)));
    }

  for (count = 0; count < num_interarrival; count++)
    {
      iat_ch[count] = 8 * ((double) pktsize) / rates_ch[count];
    }

  sleeptime = iat_ch[0];

  if(debug)
    fprintf(stderr, "ST %.8f\n", sleeptime);

  /* Hack so smartwait doesn't wait on 1st packet Be careful, if you add
     too much, tv_usec will wrap around and result in a positive
     time difference */
  /* Hack because sleeptime gets divided before the first sleep period*/
  gettimeofday(&tp1, (struct timezone *) 0);
  tp1.tv_usec -= 100000;

  for (np = 1; np <= num_interarrival + 1; np++)
    {
      for (count = 1; count <= jumbo; count++)
      	{
	  /* Wait for smartwait-1+0.5
	   * The -1 is to account for gettimeofday, the +0.5 is for rounding */
	  smartwait((unsigned) (sleeptime - .5), &tp1);

	  send_pkt();
      	}
      if (connected == 0)
	return;

      /* Prepare for a shorter sleep next time */
      sleeptime = iat_ch[np];

      pktsend++;		/* number of packets sent */
    }
  /********* END CHIRP ********/

  nc++;
  /* gap between two successive packet trains */
  gettimeofday(&tp1, (struct timezone *) 0);
  if(debug)
    fprintf(stderr, "gap=%f\n", gap);

  run_select(gap);
  /* CHANGE GAP TO CORRECT UNITS
   * MAKE SURE WE WAIT FOR RIGHT TIME*/
}


/*setup socket and wait for packets*/
void setup_socket_and_wait()
{
  fprintf(stderr, "Waiting for receiver to setup connection\n");

  /* initial part of data is actually the log record */
  sendpkt = (struct udprecord *) data;
  bzero((char *) sendpkt, sizeof (struct udprecord));

  /* check if packet ok, then send challenge */
  rcvpkt=(struct control_rcv2snd *) data_rcv;

  /* create a socket to send and receive packets */
  soudp = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
  if (soudp < 0)
    {
      perror("assolo_snd: socket");
      exit(1);
    }

  /* initialize address/port number */
  bzero((char *) &dst, sizeof(dst));
  bzero((char *) &snd, sizeof(snd));
  snd.sin_family = AF_INET;
  snd.sin_addr.s_addr = htonl(INADDR_ANY);
  snd.sin_port = htons(sndPort);

  bind(soudp, (struct sockaddr *) &snd, sizeof(snd));
  connected=0;

  if(debug)
    fprintf(stderr, "Waiting for packet\n");

  if(connected)
    cc = read(soudp, data_rcv, MAXMESG);
  else
    cc = recvfrom(soudp, data_rcv, MAXMESG, 0,
		  (struct sockaddr *) &dst, &fromlen);
  create_challenge_number();

  while(1)
    {
      if(connected == 0)
	recv_pkt();
      else
	chirps_snd();
    }
  return;
}

/* real-time */
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



/* main function  */
int main(int argc, char *argv[])
{
  /* allocate space for local timestamp */
  tp = (struct timeval *) (malloc(sizeof(struct timeval)));
  fromlen = (socklen_t) sizeof(struct sockaddr);

  lockMe();

#ifdef RT_PROCESS
  set_real_time_priority();
#endif

  parse_cmd_line(argc,argv);

  setup_socket_and_wait();/*ideally we should not come out of this function*/

  return(0);
}




