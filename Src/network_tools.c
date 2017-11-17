/* FILE: network_tools.c */

#include "network_tools.h"


/* Check if the System uses Little Endian or Big Endian
 * Returns 1 if Little Endian and 0 for Big Endian */
int CheckIfLittleEndian(void)
{
    short int Two_byte_size = 1;						// Works this way:
    char     *One_byte_size = (char *) &Two_byte_size;	// shortened => (0000) 0001 ... If BE => (0001) 0000 = 0 | if LE => (0000) 0001 = 1

    if(One_byte_size[0] == 1)
    	return(1); // True
    else
    	return(0);	// False
}

/* //TODO Comment Function */
void PrintToBinary(u_int64_t input)
{
	unsigned char *tmp = (unsigned char *)&input;
	int i,j;
	j=sizeof(input);
	for(i=0;i < j;i++)
	{
		if( (tmp[i] & 128) == 128)
			fprintf(stderr,"1");
		else
			fprintf(stderr,"0");

		if( (tmp[i] & 64) == 64)
			fprintf(stderr,"1");
		else
			fprintf(stderr,"0");

		if( (tmp[i] & 32) == 32)
			fprintf(stderr,"1");
		else
			fprintf(stderr,"0");

		if( (tmp[i] & 16) == 16)
			fprintf(stderr,"1");
		else
			fprintf(stderr,"0");

		fprintf(stderr," ");

		if( (tmp[i] & 8) == 8)
			fprintf(stderr,"1");
		else
			fprintf(stderr,"0");

		if( (tmp[i] & 4) == 4)
			fprintf(stderr,"1");
		else
			fprintf(stderr,"0");

		if( (tmp[i] & 2) == 2)
			fprintf(stderr,"1");
		else
			fprintf(stderr,"0");

		if( (tmp[i] & 1) == 1)
			fprintf(stderr,"1");
		else
			fprintf(stderr,"0");

		fprintf(stderr,"   ");

	}
	printf("\n");
}

/* //TODO Comment Function */
u_int64_t ntohll(u_int64_t input)
{
    if(CheckIfLittleEndian() == 1) // Little Endian - swap bytes
    {
    	u_int64_t       output    = 0.0;
    	unsigned char *sysEndian = (unsigned char *)&input;			// Assign Adress of input to sysEndian
        unsigned char *netEndian = (unsigned char *)&output;		// Now sysEndian is an array which contains the "value" of input
        int			   i,j;

        for(i=0,j=7; i < 8;i++,j--)
        {
        	netEndian[i] = sysEndian[j];	// swap the bytes ...
        }

    	return(output);
    }
    else // Big Endian - nothing to do here
    {
    	return(input);
    }
}

/* //TODO Comment Function */
void PrintToBinaryd(double input)
{
	unsigned char *tmp = (unsigned char *)&input;
	int i,j;
	j=sizeof(input);
	for(i=0;i < j;i++)
	{
		if( (tmp[i] & 128) == 128)
			fprintf(stderr,"1");
		else
			fprintf(stderr,"0");

		if( (tmp[i] & 64) == 64)
			fprintf(stderr,"1");
		else
			fprintf(stderr,"0");

		if( (tmp[i] & 32) == 32)
			fprintf(stderr,"1");
		else
			fprintf(stderr,"0");

		if( (tmp[i] & 16) == 16)
			fprintf(stderr,"1");
		else
			fprintf(stderr,"0");

		fprintf(stderr," ");

		if( (tmp[i] & 8) == 8)
			fprintf(stderr,"1");
		else
			fprintf(stderr,"0");

		if( (tmp[i] & 4) == 4)
			fprintf(stderr,"1");
		else
			fprintf(stderr,"0");

		if( (tmp[i] & 2) == 2)
			fprintf(stderr,"1");
		else
			fprintf(stderr,"0");

		if( (tmp[i] & 1) == 1)
			fprintf(stderr,"1");
		else
			fprintf(stderr,"0");

		fprintf(stderr,"   ");

	}
	printf("\n");
}

/* Network to Host Endian for Double with 64 Bits */
double ntohd(double input)
{
    if(CheckIfLittleEndian() == 1) // Little Endian - swap bytes
    {
    	double	       output    = 0.0;
    	unsigned char *sysEndian = (unsigned char *)&input;			// Assign Adress of input to sysEndian
        unsigned char *netEndian = (unsigned char *)&output;		// Now sysEndian is an array which contains the "value" of input
        int			   i,j;

        //fprintf(stderr,"1:Input=%f Output=%f\n",input,output);

		for(i=0,j=7; i < 8;i++,j--)
		{
			netEndian[i] = sysEndian[j];	// swap the bytes ...
			/*fprintf(stderr,"I-%i\t",i);PrintToBinaryd(input);
			fprintf(stderr,"O-%i\t",i);PrintToBinaryd(output);
			fprintf(stderr,"\n");*/
		}

		//fprintf(stderr,"2: Input=%f Output=%f\n",input,output);PrintToBinaryd(output);
    	return(output);
    }
    else // Big Endian - nothing to do here
    {
    	return(input);
    }
}


/* The following programm code is public domain and can be found in
 * 	  http://beej.us/guide/bgnet/output/html/singlepage/bgnet.html#serialization
 * Author: Brian “Beej Jorgensen” Hall
 ********************************************************************************************/

/* This Code packs an unsigned int64 back into an double for transmitting over the network. Standard IEEE-754 */
u_int64_t pack754(double f, unsigned bits, unsigned expbits)
{
	double fnorm;
	int shift;
	long long sign, exp, significand;
	unsigned significandbits = bits - expbits - 1; // -1 for sign bit

	if (f == 0.0) return 0; // get this special case out of the way

	// check sign and begin normalization
	if (f < 0) { sign = 1; fnorm = -f; }
	else { sign = 0; fnorm = f; }

	// get the normalized form of f and track the exponent
	shift = 0;
	while(fnorm >= 2.0) { fnorm /= 2.0; shift++; }
	while(fnorm < 1.0) { fnorm *= 2.0; shift--; }
	fnorm = fnorm - 1.0;

	// calculate the binary form (non-float) of the significand data
	significand = fnorm * ((1LL<<significandbits) + 0.5f);

	// get the biased exponent
	exp = shift + ((1<<(expbits-1)) - 1); // shift + bias

	// return the final answer
	return (sign<<(bits-1)) | (exp<<(bits-expbits-1)) | significand;
}


/* This Code unpacks an unsigned int64 back into a double value. Standard IEEE-754 */
long double unpack754(u_int64_t i, unsigned bits, unsigned expbits)
{
	long double result;
	long long shift;
	unsigned bias;
	unsigned significandbits = bits - expbits - 1; // -1 for sign bit

	if (i == 0) return 0.0;

	// pull the significand
	result = (i&((1LL<<significandbits)-1)); // mask
	result /= (1LL<<significandbits); // convert back to float
	result += 1.0f; // add the one back on

	// deal with the exponent
	bias = (1<<(expbits-1)) - 1;
	shift = ((i>>significandbits)&((1LL<<expbits)-1)) - bias;
	while(shift > 0) { result *= 2.0; shift--; }
	while(shift < 0) { result /= 2.0; shift++; }

	// sign it
	result *= (i>>(bits-1))&1? -1.0: 1.0;

	return result;
}
/********************************************************************************************/
