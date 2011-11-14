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


int main(int argc, char **argv)			// argv => Statsizer  TESTNAME 	   (f.e 10Mbit_Stability_100_Run)
										// 10Mbit_Stability_100_Run.instbw.data
										// 10Mbit_Stability_100_Run.debug.data
										// will be analysed
{
	if(argc != 2)
	{
		cout << endl;
		cout << "./Statsizer \"TestName\" " << endl;
		cout << endl;
		cout << "     The following files should be present" << endl;
		cout << "     - \"TestName\".instbw.data" << endl;
		cout << "     - \"TestName\".debug.data" << endl;
		cout << endl;

		return(1);
	}

	// Prepare File Locations
	string argv_input		= argv[1];
	string InputInstbw_Location	= argv_input + ".instbw.data";
	string InputDebug_Location	= argv_input + ".debug.data";
	string OutputFile_Location 	= argv_input + ".stats";

	// Open Files
	ifstream InputFile_Instbw(InputInstbw_Location.c_str(), ios::in);
	ifstream InputFile_Debug(InputDebug_Location.c_str(), ios::in);
	ofstream OutputFile(OutputFile_Location.c_str(), ios::out);


	// Check if files are ready
	if( ! OutputFile.is_open() )
	{
		cout << "Cant open \""<< OutputFile_Location << "\" ... Exit" << endl;
		return(1);
	}

	string	line;
	string	separator("\t");
	string	Chirp_Packet_Changes;

	size_t	field1_start, field2_start, field3_start, field4_start, field5_start, field6_start, field7_start, field8_start;
	size_t	field1_len, field2_len, field3_len, field4_len, field5_len, field6_len, field7_len, field8_len;

	int Packet_Number;
	int Chirp_Number;
	int	Chirp_Packet;
	int	Chirp_Packet_Count_Has_Changed = 0;
	int	Chirp_Length = 0;
	int	Chirp_Packet_before = 0;
	int	Chirp_Number_before = 0;
	int Instbw_not_present = 0;
	int Debug_not_present = 0;
	int	ChirpCount_instbw = 0;

	double	Sender_Timestamp, Receiver_Timestamp;
	double	Sender_Timestamp_before, Receiver_Timestamp_before;
	double	Delta_Sender_Timestamp, Delta_Receiver_Timestamp, Delay_Network;
	double	Inter_Chirp_Time_Sender,Inter_Chirp_Time_Receiver;
	double	Timestamp;
	double	Timestamp_Minimum=99999999999999.0;
	double  Estimated_Bandwidth;
	double  Estimated_Minimum=9999999999999.0;
	double  Estimated_Minimum_Time=0;
	double  Estimated_Maximum=-9999999999999.0;
	double  Estimated_Maximum_Time=0;
	double  Sum_of_Estimates = 0;
	double  Chirp_Start_TimeStamp_Sender,Chirp_Start_TimeStamp_Receiver;
	double	Chirp_Time_Length_Sender, Chirp_Time_Length_Receiver;
	
	double  Sum_of_Difference = 0;
	double  Difference_to_last_Estimate = 0;
	double  Last_estimate = 0;
	double  Difference_in_Percent = 0;
	double  Estimated_Minimum_Difference=9999999999999.0;
	double  Estimated_Minimum_Difference_Percent=0;
	double  Estimated_Minimum_Difference_Time=0;
	double  Estimated_Average_Difference=0;
	double  Estimated_Maximum_Difference=-9999999999999.0;
	double  Estimated_Maximum_Difference_Percent=0;
	double  Estimated_Maximum_Difference_Time=0;

	// Set output Precision to 6 digit behind "."
	cout.setf(ios::fixed);
	cout << setprecision(6);
	OutputFile.setf(ios::fixed);
	OutputFile << setprecision(6);


	OutputFile << endl;
	OutputFile << argv_input << endl;
	OutputFile << "-------------------------------------" << endl;
	OutputFile << "Input InstbwFile\t " << InputInstbw_Location << endl;
	OutputFile << "Input DebugFile\t\t " << InputDebug_Location << endl;
	OutputFile << "Output File\t\t " << OutputFile_Location << endl;
	OutputFile << endl;

	if( InputFile_Instbw.is_open() )
	{
		// Parse File
		int i=0;
		field1_start = 0;
		while ( InputFile_Instbw.good() )
		{
			getline (InputFile_Instbw,line);
			field7_len = line.length();

			if(field7_len == 0)
			{
				break;
			}


			// Get Position for FieldSeparators
			// Add one to get the position of the data and not the separator
			field2_start = line.find(separator, field1_start) + 1;
			field3_start = line.find(separator, field2_start) + 1;
			field4_start = line.find(separator, field3_start) + 1;
			field5_start = line.find(separator, field4_start) + 1;
			field6_start = line.find(separator, field5_start) + 1;
			field7_start = line.find(separator, field6_start) + 1;


			// Calculate length of each field
			field1_len = (field2_start - 1) - field1_start;
			field2_len = (field3_start - 1) - field2_start;
			field3_len = (field4_start - 1) - field3_start;
			field4_len = (field5_start - 1) - field4_start;
			field5_len = (field6_start - 1) - field5_start;
			field6_len = (field7_start - 1) - field6_start;
			field7_len = (field7_len)       - field7_start;

			// Convert String to Datatype ...
			stringstream ss_tmp_1( line.substr(field1_start, field1_len) );
			stringstream ss_tmp_2( line.substr(field2_start, field2_len) );

			ss_tmp_1 >> Timestamp;
			ss_tmp_2 >> Estimated_Bandwidth;
			
			
			

			// Remember Value to calculate Sum_of_Estimates
			Sum_of_Estimates+=Estimated_Bandwidth;

			if(Timestamp < Timestamp_Minimum)
			{
				Timestamp_Minimum=Timestamp;
			}
			// Find Minimum
			if(Estimated_Bandwidth < Estimated_Minimum)
			{
				Estimated_Minimum=Estimated_Bandwidth;
				Estimated_Minimum_Time=Timestamp;

			}

			// Find Maximum
			if(Estimated_Bandwidth > Estimated_Maximum)
			{
				Estimated_Maximum=Estimated_Bandwidth;
				Estimated_Maximum_Time=Timestamp;
			}

			// Estimate Difference
			if ( i != 0 ) // The first value has no previous Estimate, dont calculate.
			{
				Difference_to_last_Estimate  = abs(Estimated_Bandwidth - Last_estimate);
				Sum_of_Difference 			+= Difference_to_last_Estimate;
				Difference_in_Percent 		 = 100.0 * Difference_to_last_Estimate / Last_estimate;
				
				// Find Minimum
				if(Difference_to_last_Estimate < Estimated_Minimum_Difference)
				{
					Estimated_Minimum_Difference=Difference_to_last_Estimate;
					Estimated_Minimum_Difference_Percent=Difference_in_Percent;
					Estimated_Minimum_Difference_Time=Timestamp;
				}

				// Find Maximum
				if(Difference_to_last_Estimate > Estimated_Maximum_Difference)
				{
					Estimated_Maximum_Difference=Difference_to_last_Estimate;
					Estimated_Maximum_Difference_Percent=Difference_in_Percent;
					Estimated_Maximum_Difference_Time=Timestamp;
				}
			}
			Last_estimate = Estimated_Bandwidth;
			
			i++;
		}

		ChirpCount_instbw = i;

		OutputFile << "INSTBW" << endl;
		OutputFile << " Sum_of_Estimates\t" << Sum_of_Estimates << " MBit/s" << endl;
		OutputFile << " Sum_of_Dif_Estimates\t" << Sum_of_Difference << " MBit/s";
			OutputFile << "\t=> " << (100.0 * Sum_of_Difference/Sum_of_Estimates) << "%" << endl;
		OutputFile << " Count_of_Estimates\t" << ChirpCount_instbw << " Chirp(s)" <<  endl;
		OutputFile << " Time_of_Experiment\t" << (Timestamp-Timestamp_Minimum) << " seconds" << endl;
		OutputFile << " Seconds_per_Estimate\t" << (Timestamp-Timestamp_Minimum)/i << endl;
		OutputFile << endl;

		Sum_of_Estimates/=(double)(i+1);
		OutputFile << " Minimum_Estimate\t" << Estimated_Minimum << " MBit/s";
			OutputFile <<	"\t@Time\t" << (Estimated_Minimum_Time-Timestamp_Minimum) << " seconds" << endl;
		OutputFile << " Average_Estimate\t" << Sum_of_Estimates << " MBit/s" << endl;
		OutputFile << " Maximum_Estimate\t" << Estimated_Maximum << " MBit/s";
			OutputFile <<	"\t@Time\t" << (Estimated_Maximum_Time-Timestamp_Minimum) << " seconds" << endl;
		OutputFile << endl;
		
		Estimated_Average_Difference = Sum_of_Difference / (double)(i+1);
		OutputFile << " Minimum_Dif_Estimate\t" << Estimated_Minimum_Difference << " MBit/s";
			OutputFile << "\t" << Estimated_Minimum_Difference_Percent << "%";
			OutputFile <<	"\t@Time\t" << Estimated_Minimum_Difference_Time << " seconds" << endl;
		OutputFile << " Average_Dif_Estimate\t" << Estimated_Average_Difference << " MBit/s" << endl;
		OutputFile << " Maximum_Dif_Estimate\t" << Estimated_Maximum_Difference << " MBit/s";
			OutputFile << "\t" << Estimated_Maximum_Difference_Percent << "%";
			OutputFile <<	"\t@Time\t" << Estimated_Maximum_Difference_Time << " seconds" << endl;
		OutputFile << endl;
 
	}
	else
	{
		OutputFile << "Instbw-file \""<< InputInstbw_Location << "\" not present" << endl;
		OutputFile << endl;

		Instbw_not_present = 1;
	}

	if( InputFile_Debug.is_open() )
	{
		string	Chirp_Length_str="";

		int i=0;
		field1_start=0;
		while ( InputFile_Debug.good() )
		{
			i++;

			getline (InputFile_Debug,line);
			field8_len = line.length();

			if(field8_len == 0)
			{
				break;
			}

			// Get Position for FieldSeparators
			// Add one to get the position of the data and not the separator
			field2_start = line.find(separator, field1_start) + 1;
			field3_start = line.find(separator, field2_start) + 1;
			field4_start = line.find(separator, field3_start) + 1;
			field5_start = line.find(separator, field4_start) + 1;
			field6_start = line.find(separator, field5_start) + 1;
			field7_start = line.find(separator, field6_start) + 1;
			field8_start = line.find(separator, field7_start) + 1;


			// Calculate length of each field
			field1_len = (field2_start - 1) - field1_start;
			field2_len = (field3_start - 1) - field2_start;
			field3_len = (field4_start - 1) - field3_start;
			field4_len = (field5_start - 1) - field4_start;
			field5_len = (field6_start - 1) - field5_start;
			field6_len = (field7_start - 1) - field6_start;
			field7_len = (field8_start - 1) - field7_start;
			field8_len = (field8_len)       - field8_start;

			Chirp_Packet_before			= Chirp_Packet;
			Chirp_Number_before			= Chirp_Number;
			Sender_Timestamp_before		= Sender_Timestamp;
			Receiver_Timestamp_before	= Receiver_Timestamp;

			// Convert String to Datatype ...
			stringstream ss_tmp_1( line.substr(field1_start, field1_len) );
			stringstream ss_tmp_2( line.substr(field2_start, field2_len) );
			stringstream ss_tmp_3( line.substr(field3_start, field3_len) );
			stringstream ss_tmp_4( line.substr(field4_start, field4_len) );
			stringstream ss_tmp_5( line.substr(field5_start, field5_len) );
			stringstream ss_tmp_6( line.substr(field6_start, field6_len) );
			stringstream ss_tmp_7( line.substr(field7_start, field7_len) );
			stringstream ss_tmp_8( line.substr(field8_start, field8_len) );

			ss_tmp_1 >> Packet_Number;
			ss_tmp_2 >> Chirp_Number;
			ss_tmp_3 >> Chirp_Packet;
			ss_tmp_4 >> Sender_Timestamp;
			ss_tmp_5 >> Receiver_Timestamp;
			ss_tmp_6 >> Delta_Sender_Timestamp;
			ss_tmp_7 >> Delta_Receiver_Timestamp;
			ss_tmp_8 >> Delay_Network;				// abs(Delta_Receiver_Timestamp - Delta_Sender_Timestamp)

			if(Chirp_Packet_before > Chirp_Packet)
			{
				// *_before =  last packet of the chirp before
				Chirp_Time_Length_Sender   = Sender_Timestamp_before - Chirp_Start_TimeStamp_Sender;
				Chirp_Time_Length_Receiver = Receiver_Timestamp_before - Chirp_Start_TimeStamp_Receiver;

				if(Chirp_Number_before == 1)
				{
					Chirp_Length = Chirp_Packet_before;
					stringstream ss_tmp;
					ss_tmp << Chirp_Packet_before;
					Chirp_Length_str = ss_tmp.str();
				}
				else if(Chirp_Packet_before != Chirp_Length && Chirp_Length != 0)
				{
					Chirp_Packet_Count_Has_Changed = 1;
					stringstream ss_tmp;
					ss_tmp << Chirp_Packet_before;
					Chirp_Length_str += "/" + ss_tmp.str();
				}
			}

			if(Chirp_Packet == 1) // First Packet of Chirp
			{
				Inter_Chirp_Time_Sender   = (Sender_Timestamp - Sender_Timestamp_before);
				Inter_Chirp_Time_Receiver = (Receiver_Timestamp - Receiver_Timestamp_before);

				Chirp_Start_TimeStamp_Sender   = Sender_Timestamp;
				Chirp_Start_TimeStamp_Receiver = Receiver_Timestamp;
			}
		}

		OutputFile << "DEBUG" << endl;
		OutputFile << " Packet_Count\t\t" << Packet_Number << " Packet(s)" << endl;
		OutputFile << " Chirp_Count\t\t" << Chirp_Number <<  " Chirp(s)" << endl;
		OutputFile << " Packets_per_Chirp\t" << Chirp_Length_str << " Packet(s)";
		if(Chirp_Packet_Count_Has_Changed == 1)
		{
			OutputFile << "\t !error! found more than one Chirp Length" << endl;
		}
		else
		{
			if( Packet_Number != (Chirp_Number*Chirp_Length) )
			{
				OutputFile << "\t!error! => | " << Packet_Number << " - " << (Chirp_Number*Chirp_Length) << " | = " << (int) abs( (double) ((Chirp_Number*Chirp_Length) - Packet_Number) ) << " Missing Packet(s)  ||  Packet_Count != (Chirp_Count*Packets_per_Chirp)";
			}

			OutputFile << endl;
		}
		OutputFile <<  endl;
		OutputFile << " Inter_Chirp_Time\t(S)~ " << Inter_Chirp_Time_Sender << "s";
		OutputFile << "\t(R)~ " << Inter_Chirp_Time_Receiver << "s";
		OutputFile << "\t(abs Dif)~ " << abs(Inter_Chirp_Time_Receiver-Inter_Chirp_Time_Sender) << "s\t(last measured values)" << endl;

		OutputFile << " Lenght_of_Chirp\t(S)~ " << Chirp_Time_Length_Sender << "s";
		OutputFile << "\t(R)~ " << Chirp_Time_Length_Receiver << "s";
		OutputFile << "\t(abs Dif)~ " << abs(Chirp_Time_Length_Receiver-Chirp_Time_Length_Sender) << "s\t(last measured values)" << endl;

		OutputFile << " Sum_LoC_ICT\t\t(S)~ " << Chirp_Time_Length_Sender+Inter_Chirp_Time_Sender << "s";
		OutputFile << "\t(R)~ " << Chirp_Time_Length_Receiver+Inter_Chirp_Time_Receiver << "s";
		OutputFile << "\t(abs Dif)~ " << abs((Chirp_Time_Length_Sender+Inter_Chirp_Time_Sender)-(Chirp_Time_Length_Receiver+Inter_Chirp_Time_Receiver)) << "s" << endl;

		OutputFile <<  endl;
		OutputFile << " Time_of_Exp (S)\t" << Sender_Timestamp << " seconds" <<  endl;
		OutputFile << " Time_of_Exp (R)\t" << Receiver_Timestamp << " seconds" <<  endl;
		OutputFile << " Absolute_Difference\t" << abs(Sender_Timestamp - Receiver_Timestamp) << " seconds" << endl;
	}
	else
	{
		OutputFile << "Debug-file \""<< InputDebug_Location << "\" not present" << endl;
		OutputFile << endl;
		Debug_not_present = 1;
	}


	if(Debug_not_present == 0 && Instbw_not_present == 0)
	{
		OutputFile << endl;
		OutputFile << "INSTBW + DEBUG (ToDo)" << endl;
		OutputFile << " Failed Estimates\t" << (Chirp_Number-ChirpCount_instbw) - 11 << " Chirp(s) => " << ((Chirp_Number-ChirpCount_instbw) - 11) / (Chirp_Number - 11) << "%\t (Smoothing over Estimates = 11, ? 1 Chirp extra ?)" << endl;
/*		cout << "   1] Debug - Instbw\t\t: " << Chirp_Number << " - " << ChirpCount_instbw << " = " << (Chirp_Number-ChirpCount_instbw) << endl;
		cout << "   2] Smoothing over Estimated\t: " << (Chirp_Number-ChirpCount_instbw) << " - 11 = " << (Chirp_Number-ChirpCount_instbw) - 11 << " (SoE default value 11)" << endl;
		cout << "   3] Unknown Cause\t\t:  " << (Chirp_Number-ChirpCount_instbw) - 11 << " - 1 = " << (Chirp_Number-ChirpCount_instbw) - 12 << endl;*/
	}

	OutputFile << "-------------------------------------" << endl;
	OutputFile << endl;


	InputFile_Instbw.close();
	InputFile_Debug.close();
	OutputFile.close();

	return(0);
};



