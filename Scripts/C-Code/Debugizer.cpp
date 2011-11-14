// Assolo Helper Pack Version 1.0
//
// This Script automates the generation of statistics and plotfiles for raw assolo instbw and debug files
// It was tested under Ubuntu 10.4 (2.6.32-31-generic - i686 GNU/Linux)
//
// More Information can be found in the README
//
// Licensed under "GNU GENERAL PUBLIC LICENSE Version 3"
// Sebastian.Wilken@uni-duesseldorf.de - Base Release 1.0 - 15.10.2011


// C++ Includes
#include <iostream>
#include <fstream>
#include <string>
#include <sstream>
#include <iomanip>
#include <cmath>
using namespace std;

// C includes
#include <stdio.h>
#include <string.h>


int main(int argc, char **argv)			// argv => Debugizer   FILE   TIMESTAMP_MINIMUM_SENDER   TIMESTAMP_MINIMUM_RECEIVER
{
	if(argc < 4)
	{
		cout << "./Debugizer \"DebugFile\" \"Minimum Timestamp from Sender\" \"Minimum Timestamp from Receiver\"" << endl;
		return(1);
	};

	// Generate OutputFile_Location
	int 	j = strlen(argv[1]) + 5;
	char 	OutputFile_Location[j];
	strcpy(OutputFile_Location,argv[1]);
	strcat(OutputFile_Location,".data");


	// Open Files
	ifstream InputFile_Debug(argv[1], ios::in);
	ofstream OutputFile_Debug(OutputFile_Location, ios::out);


	// Check if files are ready
	if( ! OutputFile_Debug.is_open() )
	{
		cout << "Cant open \""<< OutputFile_Location << "\" ... Exit" << endl;
		return(1);
	}
	if( InputFile_Debug.is_open() )
	{
		// Begin work ...
		string	line;
		string	separator(" ");

		size_t	field1_start, field2_start, field3_start, field4_start;
		size_t	field1_len, field2_len, field3_len, field4_len;

		int 	Chirp_Number;
		int		Chirp_Packet;
		double	Sender_Timestamp, Receiver_Timestamp = 0.0;
		double	Sender_Timestamp_Minimum , Receiver_Timestamp_Minimum;
		double	Sender_Time_Between_Chirp_Packet, Receiver_Time_Between_Chirp_Packet;

		// Set output Precision to 6 digit behind "."
		cout.setf(ios::fixed);
		cout << setprecision(6);
		OutputFile_Debug.setf(ios::fixed);
		OutputFile_Debug << setprecision(6);


		// Convert commandline input (min. snd & rcv) -> string to double
		stringstream minimum_sender_tmp(argv[2]);
		stringstream minimum_receiver_tmp(argv[3]);

		minimum_sender_tmp   >> Sender_Timestamp_Minimum;
		minimum_receiver_tmp >> Receiver_Timestamp_Minimum;


		// Parse File
		int i=0;
		field1_start = 0;
		while ( InputFile_Debug.good() )
	    {
			i++;

			getline (InputFile_Debug,line);
			field4_len = line.length();

			if(field4_len == 0)
			{
				break;
			}

			// Get Position for FieldSeparators
			// Add one to get the position of the data and not the separator
			field2_start = line.find(separator, field1_start) + 1;
			field3_start = line.find(separator, field2_start) + 1;
			field4_start = line.find(separator, field3_start) + 1;


			// Calculate length of each field
			field1_len = (field2_start - 1) - field1_start;
			field2_len = (field3_start - 1) - field2_start;
			field3_len = (field4_start - 1) - field3_start;
			field4_len = (field4_len   ) - field4_start;


				// Remember old values.
				Sender_Time_Between_Chirp_Packet   = (-1) * Sender_Timestamp;
				Receiver_Time_Between_Chirp_Packet = (-1) * Receiver_Timestamp;


			// Convert String to Datatype ...
			stringstream ss_tmp_1( line.substr(field1_start, field1_len) );
			stringstream ss_tmp_2( line.substr(field2_start, field2_len) );
			stringstream ss_tmp_3( line.substr(field3_start, field3_len) );
			stringstream ss_tmp_4( line.substr(field4_start, field4_len) );

			ss_tmp_1 >> Chirp_Number;
			ss_tmp_2 >> Chirp_Packet;
			ss_tmp_3 >> Sender_Timestamp;
			ss_tmp_4 >> Receiver_Timestamp;

			// Normalize Timestamps
			Sender_Timestamp   -= Sender_Timestamp_Minimum;
			Receiver_Timestamp -= Receiver_Timestamp_Minimum;

				// Calculate Delay between Packets of a chirp
				Sender_Time_Between_Chirp_Packet   += Sender_Timestamp;
				Receiver_Time_Between_Chirp_Packet += Receiver_Timestamp;

			if(Chirp_Packet == 1) // First Packet of Chirp has no Delay because of no reference
			{
				Sender_Time_Between_Chirp_Packet   = 0;
				Receiver_Time_Between_Chirp_Packet = 0;
			}

			double tmp;

			tmp = abs(Sender_Time_Between_Chirp_Packet - Receiver_Time_Between_Chirp_Packet);

			// Write to File
			OutputFile_Debug << i << "\t" << Chirp_Number << "\t" << Chirp_Packet << "\t" << Sender_Timestamp << "\t" << Receiver_Timestamp << "\t" << Sender_Time_Between_Chirp_Packet << "\t" << Receiver_Time_Between_Chirp_Packet << "\t" << tmp << endl;
			//cout << i << "\t" << Chirp_Number << "\t" << Chirp_Packet << "\t" << Sender_Timestamp << "\t" << Receiver_Timestamp << "\t" << Sender_Time_Between_Chirp_Packet << "\t" << Receiver_Time_Between_Chirp_Packet << endl;
	    }
	}
	else
	{
		cout << "Cant open \""<< argv[1] << "\" ... Exit" << endl;
		return(1);
	}

	InputFile_Debug.close();
	OutputFile_Debug.close();
 
	return(0);
};




