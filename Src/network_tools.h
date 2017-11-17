/* FILE: network_tools.h */
#ifndef _network_tools_
#define _network_tools_	1

	#include "../config.h"
	#include <stdint.h>
	#include <sys/types.h>
	#include <netinet/in.h>
	#include <stdio.h>
	#include "assolo.h"

	#define pack754_32(f) (pack754((f), 32, 8))
	#define pack754_64(f) (pack754((f), 64, 11))
	#define unpack754_32(i) (unpack754((i), 32, 8))
	#define unpack754_64(i) (unpack754((i), 64, 11))


	int CheckIfLittleEndian(void);		// Check System Endianess: 0 => Big Endian, 1 => Little Endian
	void PrintToBinary(u_int64_t);
	void PrintToBinaryd(double);

	u_int64_t ntohll(u_int64_t);			// Network to Host Endian transformation for int (64 Bit)
	#define	htonll(i) ntohll(i)			// Host to Network Endian transformation for int (64 Bit)

	double ntohd(double);				// Network to Host Endian transformation for double
	#define	htond(i) ntohd(i)			// Host to Network Endian transformation for double

	u_int64_t 	pack754(double, unsigned, unsigned);	// Pack a double value into unsigned integer (64 Bit) to transfer over an network link (based on IEEE-754)
	long double unpack754(u_int64_t, unsigned, unsigned);	// Unpack the integer back to double

#endif
