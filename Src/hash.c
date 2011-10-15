/* FILE: hash.c */

/* cryptographic hash function for authentication */

/* SECURITY: In this implementation assolo_snd will be on
continuously and wait for assolo_rcv to initiate the connection.
In addition assolo_rcv acts as a master telling assolo_snd
at what rates to send packets etc.

As the first step towards making assolo more secure we
add a crc to each control packet to ensure that a  malicious
receiver does not ask deployed senders to send out UDP storms.

NOTE: This is a cooked up, insecure, crc function for testing.
Feel free to replace hash with a better function (SHA-1, MD5 etc.).
 */

/*
TO USE THE SECURITY FEATURE
===========================

Set the values of XORMASK1/2/3 to different values of your choice.
They must be the same at sender and receiver and unknown to anyone else.
*/

#include "assolo_snd.h"

#define XORMASK1 0x7ab04793L
#define XORMASK2 0x02ef4c83L
#define XORMASK3 0x1e158321L

/* hash function, input two 32 bit words, output one 32 bit key*/
u_int32_t hash(u_int32_t crc, u_int32_t element)
{
	u_int32_t  tmp,tmp1;
	crc=((~crc) ^ XORMASK1);

	tmp=(((element & 0x0000ffff)<<16) ^ XORMASK2);
	tmp=tmp ^ (((element & 0xffff0000)>>16) ^ XORMASK3);
	tmp=tmp ^ (((element & 0x00ffff00)>>8) ^ XORMASK1);
  	tmp=tmp ^ (((element & 0x00ffff00)<<8) ^ XORMASK1);
	tmp = tmp ^ element;

	tmp1=(((crc & 0x0000ffff)<<16) ^ XORMASK2);
	tmp1=tmp1 ^ (((crc & 0xffff0000)>>16) ^ XORMASK3);
	tmp1=tmp1 ^ (((crc & 0x00ffff00)>>8) ^ XORMASK1);
	tmp=tmp ^ (((crc & 0x00ffff00)<<8) ^ XORMASK1);
	tmp1 = tmp1 ^ crc;

	crc= tmp ^ tmp1;

	return crc;

}


/* Split the 64 Bit into 2x 32Bit to generate the crc for each elememt and return it*/
u_int32_t gen_crc_unint64(u_int64_t value, u_int32_t crc)
{
  	u_int32_t 	   Split00_15 = 0;	// for double values (64Bit) we need 32Bit for our crc => splitting
  	u_int32_t 	   Split16_32 = 0;	// ...
  	unsigned char *HelperArray;		// Just a pointer for easy access of raw data, since double "should" be 8 byte we got 0-7 array elements

  	HelperArray = (unsigned char *) &(value);	// Assign the MemoryAdress of the double value to a pointer (HelperArray) so we can access it as an array ...

  	// Build lower 32 bits (Array 4-7 !)
  	Split00_15 = (u_int32_t) HelperArray[4];				// f.e. HelperArray 11 22 33 44 55 66 77 88 => Lower part 55 66 77 88
  	Split00_15 = Split00_15 << 1;							// Split00_15 = 00 00 55 00
  	Split00_15 = Split00_15 + (u_int32_t) HelperArray[5];	// Split00_15 = 00 00 55 66
  	Split00_15 = Split00_15 << 1;							// Split00_15 = 00 55 66 00
	Split00_15 = Split00_15 + (u_int32_t) HelperArray[6];	// Split00_15 = 00 55 66 77
	Split00_15 = Split00_15 << 1;							// Split00_15 = 55 66 77 00
	Split00_15 = Split00_15 + (u_int32_t) HelperArray[7];	// Split00_15 = 55 66 77 88 done :=)

	// Build higher 32 bits (Array 0-3 !)
	Split16_32 = (u_int32_t) HelperArray[0];				// Do the same for the higher part
	Split16_32 = Split16_32 << 1;
	Split16_32 = Split16_32 + (u_int32_t) HelperArray[1];
	Split16_32 = Split16_32 << 1;
	Split16_32 = Split16_32 + (u_int32_t) HelperArray[2];
	Split16_32 = Split16_32 << 1;
	Split16_32 = Split16_32 + (u_int32_t) HelperArray[3];

  	crc = hash(crc, ntohl(Split00_15));		// Be sure they are in HostOrder before CRC (Little Endian vs Big Endian)
  	crc = hash(crc, ntohl(Split16_32));		// CRC should be the same on Little and BigEndian System after networktransmit

  	return(crc);
}


/* given a rcv2snd control packet compute the checksum*/
u_int32_t gen_crc_rcv2snd(struct control_rcv2snd *pkt)
{
  	u_int32_t crc;

  	// Integer values - calculate ...
  	crc = ntohl(pkt->request_type);					// Starting value for crc, use ntohl to be sure the Endian is correct for each system.
  	crc = hash(crc, ntohl(pkt->request_num));		// CRC should be the same after the information traveled over the network
  	crc = hash(crc, ntohl(pkt->num) );
  	crc  =hash(crc, ntohl(pkt->timesec));
  	crc = hash(crc, ntohl(pkt->timeusec));
  	crc = hash(crc, ntohl(pkt->chal_no));
    crc = hash(crc, ntohl(pkt->num_interarrival));
  	crc = hash(crc, ntohl(pkt->filter));
  	crc = hash(crc, ntohl(pkt->pktsize));

  	// 64 Bit Integer values - Split the 64bit into 2x 32 Bit and build the crc over each element
  	crc = gen_crc_unint64(pkt->spread_factor, crc);
  	crc = gen_crc_unint64(pkt->soglia, crc);
  	crc = gen_crc_unint64(pkt->low_rate, crc);
  	crc = gen_crc_unint64(pkt->high_rate, crc);
  	crc = gen_crc_unint64(pkt->inter_chirp_time, crc);

  	return(crc);
}


/* Check if CRC is correct */
int check_crc_rcv2snd(struct control_rcv2snd *pkt)
{
  	u_int32_t crc;

  	crc=gen_crc_rcv2snd(pkt);

  	if (crc==ntohl(pkt->checksum))
    	return 1;
  	else
  		return 0;
}

/* given a snd2rcv packet compute the checksum*/
u_int32_t gen_crc_snd2rcv(struct udprecord *pkt)
{
  	u_int32_t crc;

  	crc = ntohl(pkt->num);						// Starting value for crc, use ntohl to be sure the Endian is correct for each system.
  	crc = hash(crc,ntohl(pkt->request_num));	// CRC should be the same after the information traveled over the network
  	crc = hash(crc,ntohl(pkt->chirp_num));
  	crc = hash(crc,ntohl(pkt->timesec));
  	crc = hash(crc,ntohl(pkt->timeusec));
  	crc = hash(crc,ntohl(pkt->chal_no));

  	return(crc);
}

/* Check if CRC is correct */
int check_crc_snd2rcv(struct udprecord *pkt)
{

  	u_int32_t crc;

  	crc=gen_crc_snd2rcv(pkt);
  	if (crc==ntohl(pkt->checksum))
    	return 1;
  	else
    	return 0;
}

