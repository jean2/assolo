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


int main(int argc, char **argv)			// argv => Instbwrizer  FILE   TIMESTAMP_MINIMUM
{
	if(argc < 3)
	{
		cout << "./Instbwizer \"InstbwFile\" \"Minimum Timestamp\"" << endl;
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

		size_t	field1_start, field2_start;
		size_t	field1_len, field2_len;

		double	Timestamp;
		double	Timestamp_Minimum;
	   	double  Estimated_Bandwidth;
	    double	Estimated_Bandwidth_avg5 = 0.0;
	    double	Estimated_Bandwidth_avg5_tmp[5] = { 0.0, 0.0, 0.0, 0.0, 0.0 };
	    
	    double  Sum_of_Difference = 0;
	    double  Difference_to_last_Estimate = 0;
	    double  Last_estimate = 0;
		double 	Difference_avg_over_count = 0;
		double  Difference_in_Percent = 0;


		// Set output Precision to 6 digit behind "."
		cout.setf(ios::fixed);
		cout << setprecision(6);
		OutputFile_Debug.setf(ios::fixed);
		OutputFile_Debug << setprecision(6);


		// Convert commandline input (min. snd & rcv) -> string to double
		stringstream minimum_tmp(argv[2]);
		minimum_tmp   >> Timestamp_Minimum;

		// Parse File
		int i=0;
		field1_start = 0;
		while ( InputFile_Debug.good() )
	    {
			getline (InputFile_Debug,line);
			field2_len = line.length();

			if(field2_len == 0)
			{
				break;
			}


			// Get Position for FieldSeparators
			// Add one to get the position of the data and not the separator
			field2_start = line.find(separator, field1_start) + 1;


			// Calculate length of each field
			field1_len = (field2_start - 1) - field1_start;
			field2_len = (field2_len)       - field2_start;


			// Convert String to Datatype ...
			stringstream ss_tmp_1( line.substr(field1_start, field1_len) );
			stringstream ss_tmp_2( line.substr(field2_start, field2_len) );

			ss_tmp_1 >> Timestamp;
			ss_tmp_2 >> Estimated_Bandwidth;
			
			
			// Calculate Average over 5 samples
			Estimated_Bandwidth_avg5_tmp[i%5] = Estimated_Bandwidth;
			Estimated_Bandwidth_avg5 = 0.0;
			for(int j=0; j < 5; j++)
			{
				Estimated_Bandwidth_avg5 += Estimated_Bandwidth_avg5_tmp[j];
			}
			if(i < 5)
			{
				Estimated_Bandwidth_avg5 /= (i+1);
			}
			else
			{
				Estimated_Bandwidth_avg5 /= 5;
			}

			// Normalize Timestamps
			Timestamp   -= Timestamp_Minimum;
			
			// Esitmate Difference
			if ( i != 0 )
			{
				Difference_to_last_Estimate = abs(Estimated_Bandwidth - Last_estimate);
				Sum_of_Difference += Difference_to_last_Estimate;
				Difference_avg_over_count = Sum_of_Difference / (double)(i + 1);
				Difference_in_Percent = 100.0 * Difference_to_last_Estimate / Last_estimate;
			}
			Last_estimate = Estimated_Bandwidth;

			// Write to File
			OutputFile_Debug << Timestamp << "\t" << Estimated_Bandwidth << "\t" << Estimated_Bandwidth_avg5 << "\t" << Difference_to_last_Estimate << "\t" << Difference_in_Percent << "\t" << Difference_avg_over_count << "\t" << Sum_of_Difference << endl;
			//cout << Timestamp << "\t" << Estimated_Bandwidth << "\t" << Estimated_Bandwidth_avg5 << "\t" << Difference_to_last_Estimate << "\t" << Difference_in_Percent << "\t" << Difference_avg_over_count << "\t" << Sum_of_Difference << endl;

			i++;
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




