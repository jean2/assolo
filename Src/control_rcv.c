#include "assolo_rcv.h"

double htonll(double input)
{
    // Test if Big or LittleEndian
    short int word = 0x0001;			// Works this way: word 16 byte char 8 byte
    char     *byte = (char *) &word;	// shortened => (0000) 0001 ... If BE => (0001) 0000 = 0 | if LE => (0000) 0001 = 1

    if(byte[0] == 1) // Little Endian - swap bits
    {// TODO Double values representation and sizeof can change on different system...
    	double output 	   = 0.0;
    	unsigned char *src = (unsigned char *)&input;
        unsigned char *dst = (unsigned char *)&output;

        dst[0] = src[7];
    	dst[1] = src[6];
    	dst[2] = src[5];
    	dst[3] = src[4];
    	dst[4] = src[3];
    	dst[5] = src[2];
    	dst[6] = src[1];
    	dst[7] = src[0];

    	return(output);
    }
    else // Big Endian - nothing to do here
    {
    	return(input);
    }
}

/* send control packet to sender*/
void send_pkt(int state)
{
  	struct timeval tp_snd;

  	(void) gettimeofday (&tp_snd, (struct timezone *) 0);

    pkt->timesec=htonl((u_int32_t) tp_snd.tv_sec);
  	pkt->timeusec=htonl((u_int32_t) tp_snd.tv_usec);

  	cur_num++;
  	pkt->num=htonl((u_int32_t) cur_num);
  	pkt->request_num=htonl((u_int32_t) request_num);

  	switch(state)
    {
    	case REQ_CONN:
      		if(debug) fprintf(stderr,"asking for REQ_CONN\n");

       		pkt->request_type=htonl((u_int32_t)REQ_CONN);
      	break;
    	case CHALL_REPLY:
     		if(debug) fprintf(stderr,"sending CHALL_REPLY\n");

	      	pkt->request_type=htonl((u_int32_t)CHALL_REPLY);

      		/*this must not change during the rest of the connection*/
      		pkt->chal_no=htonl((u_int32_t)chal_no);
      	break;
    	case UPDATE_RATES:
    		// Send always in network byte order (Big Endian) over the networklink

    		// Integer Values - use ntonl/htonl to adjust byteorder (Little-/BigEndian) for network transmission
    		pkt->request_type	  = htonl( (u_int32_t) UPDATE_RATES);
			pkt->filter			  = htonl( (u_int32_t) filter);
			pkt->jumbo			  = htonl( (u_int32_t) jumbo);
			pkt->num_interarrival = htonl( (u_int32_t) num_interarrival);
			pkt->pktsize		  = htonl( (u_int32_t) pktsize);

			// Double values - use own htonll function (defined in this file)
			// TODO Double values representation and sizeof can change on different system...
			pkt->high_rate		  = htonll(high_rate);
			pkt->inter_chirp_time = htonll(inter_chirp_time);
			pkt->low_rate		  = htonll(low_rate);
			pkt->soglia			  = htonll(soglia);
			pkt->spread_factor	  = htonll(spread_factor);

			fprintf(stderr,"\nHR: %f\tIC: %f\tLR: %f\tT: %f\tSF: %f\n", high_rate,inter_chirp_time,low_rate,soglia,spread_factor);

      	break;
    	case STOP:
    		pkt->request_type=htonl((u_int32_t)STOP);
      	break;
    	case RECV_OK:
      		pkt->request_type=htonl((u_int32_t)RECV_OK);
      	break;


    	default:
      		perror("assolo_rcv: error in case of send_pkt\n");
      		exit(0);
      		break;
    }

  	/* figure out checksum and write to buffer */
  	pkt->checksum=htonl(gen_crc_rcv2snd(pkt));
  	cc = write (soudp, (char *)pkt,sizeof(struct control_rcv2snd));

  	/*       cc = sendto (soudp,data_snd,sizeof(struct control_rcv2snd),0,(struct sockaddr *)&src,sizeof(src));*/

  	if (cc<0)
  	{
		fprintf(stderr,"write error,cc=%d, state=%d\n",cc,state);
  		exit(0);
  	}
  	if(debug) fprintf(stderr,"wrote packet,cc=%d\n",cc);
  	return;

}

/* receive the challenge packet and reply  */
void recv_chall_pkt()
{
  	int cc;
  	cc = read(soudp, data, MAXMESG);


  	if (cc < 0)
  	{
    	perror ("assolo_rcv: read");
    	remote_host_broken=1;
    	return;
  	}
  	else
    	if(debug) fprintf(stderr,"Got chall packet\n");

  	if (check_crc_snd2rcv(udprecord))
    {
    	if (ntohl(udprecord->request_num==request_num))
      	{
			chal_no=ntohl(udprecord->chal_no);
			if(debug) fprintf(stderr,"chal no=%u\n",chal_no);
			request_num++;
			send_pkt(CHALL_REPLY);
			ack_not_rec_count=0;
			state=CHALL_REPLY;

      	}
    	else
    	{
			if(debug) fprintf(stderr,"req num wrong\n");
		}
    }
  	else
  	{
		if(debug) fprintf(stderr,"crc wrong\n");
	}

  	return;
}

/* keep checking for initial handshake reply */
void run_select(unsigned long time)
{
  	int maxfd;
  	struct   timeval tp_select,tp_start;
  	fd_set rset;

  	tp_select.tv_sec=time/1000000;
  	tp_select.tv_usec=time%1000000;

  	FD_ZERO(&rset);
  	FD_SET(soudp,&rset);

  	(void) gettimeofday (&tp_start, (struct timezone *) 0);
  	if(debug) fprintf(stderr,"running select\n");
  	maxfd=soudp+1;

  	select(maxfd,&rset,NULL,NULL,&tp_select);

  	if (FD_ISSET(soudp,&rset))
   	{
    	if (state==REQ_CONN)
       		recv_chall_pkt();
     	else
       	{
	 		/* from now on we do not check for checksum at the receiver, ideally we should to eliminate packets from fake spoofed sender packets. In future we must perform a read here along with crc check. Also in receive_chirp_pkts().*/
	 		state=CHIRPS_STARTED;
	 		request_num++;
       	}
   	}
  	else
    {
      	switch(state)
		{
			case REQ_CONN:
		  		send_pkt(REQ_CONN);
	  		break;
			case CHALL_REPLY:
	  			send_pkt(CHALL_REPLY);
	  		break;
		}
      	ack_not_rec_count++;
      	if (ack_not_rec_count>3)
		{
	  		if(debug) fprintf(stderr,"ack not received, state=%d\n",state);

		  	fprintf(stderr,"Ack not received from sender\n");
	  		remote_host_broken=1;
		}

    }

  	return;
}

/* contact sender and request connection */
void initiate_connection()
{

  	int	rcv_size = MAXRCVBUF;	/* socket receive buffer size */

 	int flag_on_recv;/*flag for setting SO_REUSEADDR*/


  	/* create a socket to receive/send UDP packets */
  	soudp = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
  	if (soudp < 0)
  	{
    	perror("assolo_rcv: socket");
    	exit(1);
  	}

  	/* initialize socket address for connection */
  	src.sin_family = AF_INET;
  	src.sin_port = htons(sndPort);

  	/*the following is to use socket even if already bound */
  	flag_on_recv = YES;

  	if (setsockopt(soudp, SOL_SOCKET, SO_REUSEADDR,(char *) &flag_on_recv,sizeof(flag_on_recv))<0)
  	{
    	perror ("assolo_rcv: setsockopt failed");
      	(void) exit (1);
  	}

  	/* set the socket receive buffer to maximum possible.
  	 * this will minimize the chance of losses at the endpoint */
  	if(setsockopt(soudp, SOL_SOCKET, SO_RCVBUF, (char *)&rcv_size,sizeof (rcv_size)) < 0)
  	{
    	perror ("assolo_rcv: receive buffer option");
    	exit (1);
  	}

  	/* kernel timestamp option for solaris */
	#ifdef HAVE_SO_TIMESTAMP
  	if (setsockopt(soudp, SOL_SOCKET, SO_TIMESTAMP,&flag_on_recv, sizeof(flag_on_recv))<0)
  	{
    	perror ("assolo_rcv: setsockopt SO_TIMESTAMP failed");
      	(void) exit (1);
    }
	#endif

  	/* connect so that we only receive packets from sender */
    if (connect (soudp, (struct sockaddr *) &src, sizeof (src)) < 0)
    {
    	perror ("assolo_rcv: could not connect to the sender\n");
    	remote_host_broken=1;
    	return;
  	}
    else
    {
      	if(debug) fprintf(stderr,"Setup socket to sender\n");
    }

 	/* have send packet point to buffer and initialize fields*/
 	pkt=(struct control_rcv2snd *) data_snd;

 	bzero((char *)pkt,sizeof(struct control_rcv2snd));
  	request_num=0;
 	cur_num=(u_int32_t)(rand()/2);/*initial packet number is random*/

 	// Send always in network byte order (Big Endian) over the networklink

 	// Integer Values - use ntonl/htonl to adjust byteorder (Little-/BigEndian) for network transmission
	pkt->filter			  = htonl( (u_int32_t) filter);
	pkt->jumbo			  = htonl( (u_int32_t) jumbo);
	pkt->num_interarrival = htonl( (u_int32_t) num_interarrival);
	pkt->pktsize		  = htonl( (u_int32_t) pktsize);

	// Double values - use own htonll function (defined in this file)
	// TODO Double values representation and sizeof can change on different system...
	pkt->high_rate		  = htonll(high_rate);
	pkt->inter_chirp_time = htonll(inter_chirp_time);
	pkt->low_rate		  = htonll(low_rate);
	pkt->soglia			  = htonll(soglia);
	pkt->spread_factor	  = htonll(spread_factor);

	/* request connection */
   	state=REQ_CONN;
   	send_pkt(state);

   	while (state!=CHIRPS_STARTED && remote_host_broken!=1)
    	run_select((unsigned long)RTTUSEC);

   	return;
}


