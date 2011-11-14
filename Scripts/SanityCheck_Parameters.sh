#!/bin/bash
#
# Assolo Helper Pack Version 1.0
#
# More Information can be found in the README
#
# Licensed under "GNU GENERAL PUBLIC LICENSE Version 3"
# Sebastian.Wilken@uni-duesseldorf.de - Base Release 1.0 - 15.10.2011


# ./SanityCheck_Parameters.sh BaseFolder SenderIP ReceiverIP Experiment_duration(seconds) LowerBorder(mbps) UpperBorder(mbps)
#
# This Script goal is to perform a SanityCheck on assolo. 
# It checks the following parameters:
#
# - AVG Probe Rate 			( 0.1 to  1.0 in 0.1 Steps [mbps])		/assolo_run -a
# - Busy Period 			( 3.0 to 7.5  in 0.5 Steps [s])			/assolo_run -b
# - Decrease Factor 		( 1.1 to 2.0  in 0.1 Steps [s])			/assolo_run -d
# - PacketSize 				( 150 to 1500 in 150 Steps [byte])		/assolo_run -p
# - SmoothingOverEstimates 	(   2 to 20   in   2 Steps [Packets])	/assolo_run -n
# - SpreadFactor 			( 1.1 to 2.0  in 0.1 Steps [Factor])	/assolo_run -s
# - Threshold 				( 5.0 to 9.5  in 0.5 Steps [Factor])	/assolo_run -e
#
# Parameter excluded
#
# - Filter			/assolo_run -f
# - Jumbo Packets	/assolo_run -J
# - Lower Border	/assolo_run -l
# - Upper Border	/assolo_run -u
#	 
# It was tested under Ubuntu 10.04 (2.6.32-31-generic - i686 GNU/Linux)


# Begin looking at the bottom, there you get the logic
# In the upper functions the how...



# Parameter and Variables
#############################################################################################################################################
experiment_name="SanityCheck_Parameters"		# Name of the Experiment
wait_for_rcv=2									# Wait for assolo_rcv to start/stop up ~2s


file_location_base=$1							# Working dir
senderIP=$2										# IP of assolo_snd
receiverIP=$3									# IP of assolo_rcv
exp_time=$4										# Time of each assolo run
lowerBorder=$5									# Lower Border for assolo
upperBorder=$6									# Upper Border for assolo

assolo_version="Assolo_unknown"					# No need to change - Used later for foldername if assolo version is unknown

# Remember the actual path 
Calling_path=$(pwd)

# Be sure the base location is the full named path
cd $file_location_base; file_location_base="$(pwd)/"

file_location_assolo=$file_location_base"assolo_run"
file_location_assolo_rcv=$file_location_base"assolo_rcv"
file_location_assolo_snd=$file_location_base"assolo_snd"
file_location_assolo_helper_sh=$file_location_base"Scripts/HelperAssolo.sh"
file_location_Debugizer=$file_location_base"Scripts/C-Code/Debugizer"
file_location_Instbwizer=$file_location_base"Scripts/C-Code/Instbwizer"
file_location_Statsizer=$file_location_base"Scripts/C-Code/Statsizer"
file_location_data=$file_location_base"Data/"

date=$(date "+%Y-%m-%d_%T")
date_begin=$(date +%s)
#############################################################################################################################################



# Functions START
#############################################################################################################################################
function Print_Experiment_Summary()
{
	echo -e '\E[1;37m' " -------------------------------------------------------";	tput sgr0
	echo -e '\E[1;37m' " - Experiment Description ($experiment_name) ";	tput sgr0
	echo -e '\E[1;37m' " -------------------------------------------------------";	tput sgr0
	echo -e '\E[1;37m' " This script checks the following parameters";	tput sgr0
	echo "  - AVG Probe Rate 		 0.1 to 1.0	in 0.1 Steps [mbps]"
	echo "  - Busy Period 		 3.0 to 7.5	in 0.5 Steps [s]"
	echo "  - Decrease Factor 		 1.1 to 2.0	in 0.1 Steps [factor]"
	echo "  - PacketSize 			 150 to 1500	in 150 Steps [byte]"
	echo "  - SmoothingOverEstimates	   2 to 20	in   2 Steps [Packets]"
	echo "  - SpreadFactor 		 1.1 to 2.0	in 0.1 Steps [Factor]"
	echo "  - Threshold 			 5.0 to 9.5	in 0.5 Steps [Factor]"
	echo " "
	echo -e '\E[1;37m' " Parameter excluded";	tput sgr0
	echo "  - Filter"
	echo "  - Jumbo Packets"
	echo "  - Lower Border"
	echo "  - Upper Border"
	echo -e '\E[1;37m' " -------------------------------------------------------";	tput sgr0
	echo " "
}

	# Check ParameterCount - NOT A FUNCTION, placed here to use the function above
	########################################################################################################################################
	if [ -z $1 ] || [ -z $2 ] || [ -z $3 ] || [ -z $4 ] || [ -z $5 ] || [ -z $6 ] ; then
		clear
		echo " "
		Print_Experiment_Summary
		echo "  Assolo Receiver and Runner have to be located in \"../Scripts\" on the same computer where the script is located."
		echo " "
		echo -e '\E[1;37m' " Syntax";	tput sgr0
		echo "   \"./SanityCheck_Parameters.sh BaseFolder SenderIP ReceiverIP Experiment_duration(seconds) LowerBorder(mbps) UpperBorder(mbps)\"" 
		echo "   => \"./SanityCheck_Parameters.sh /tmp/assolo/ 192.168.1.7 192.168.1.8 30 5 15\""
		echo " "
		echo -e '\E[1;37m' " For extended logging use";	tput sgr0
		echo "   \"./SanityCheck_Parameters.sh ... 2>&1 | tee SanityCheck_Parameters.log\""
		echo "   => \"./SanityCheck_Parameters.sh /tmp/assolo/ 192.168.1.7 192.168.1.8 30 5 15 2>&1 | tee SanityCheck_Parameters.log\""
		echo " "

		exit
	fi
	########################################################################################################################################


function Check_Enviroment()
{

	echo -e '\E[1;37m' " Checking Setup ($file_location_base)";	tput sgr0
	echo -n "   -> assolo_run ..."	
	if [ -f $file_location_assolo ] ; then
	echo " "

		echo -n "   -> assolo_rcv ..."	
		if [ ! -f $file_location_assolo_rcv ] ; then
			echo " not found. Stopping Script"
			echo " "
			exit
		fi
		echo " "
		echo -n "   -> assolo_snd ..."	
		if [ ! -f $file_location_assolo_snd ] ; then
			echo " not found. Stopping Script"
			echo " "
			exit
		fi
		echo " "

		# Since Assolo is present get version number for later use	
		assolo_version=$(echo "Assolo_"$($file_location_assolo -v 2>&1 | awk '{print $3}'))

		#---------

		echo "   -> Scripts/"
		echo -n "      -> HelperAssolo.sh ..."
		if [ ! -f $file_location_assolo_helper_sh ] ; then
			echo " not found. Stopping Script"
			echo " "
			exit
		fi
		echo " "

		#---------
		
		echo    "      -> C-Code/"
		echo -n "         -> Debugizer ..."
		if [ ! -f $file_location_debugizer ] ; then
			echo " not found. Stopping Script"
			echo " "
			exit
		fi
		echo " "

		#---------	

		echo -n "         -> Instbwizer ..."
		if [ ! -f $file_location_Instbwizer ] ; then
			echo " not found. Stopping Script"
			echo " "
			exit
		fi
		echo " "
		
		#---------

		echo -n "         -> Statsizer ..."
		if [ ! -f $file_location_Statsizer ] ; then
			echo " not found. Stopping Script"
			echo " "
			exit
		fi
		echo " "
		
		echo " "
		
	else
		echo " not found. Stopping Script"
		echo " "

		exit
	fi
}



function Create_Folder()
{
	if [ ! -d $file_location_data$experiment_name/$assolo_version/$date/ ] ; then
		echo -e '\E[1;37m' " Creating folder structure ($file_location_data)";	tput sgr0
		echo "  -> $experiment_name/"
		echo "     -> $assolo_version/"
		echo "        -> $date/"
		
		if [ ! -d $file_location_data ] ; then
			mkdir $file_location_data
		fi
		if [ ! -d $file_location_data$experiment_name ] ; then
			mkdir $file_location_data$experiment_name
		fi
		if [ ! -d $file_location_data$experiment_name/$assolo_version ] ; then
			mkdir $file_location_data$experiment_name/$assolo_version
		fi
		if [ ! -d $file_location_data$experiment_name/$assolo_version/$date ] ; then
			mkdir $file_location_data$experiment_name/$assolo_version/$date
		fi
	fi

	echo "           -> $NAME_OF_TESTED_PARAMETER/"
	mkdir $file_location_data$experiment_name/$assolo_version/$date/$NAME_OF_TESTED_PARAMETER
}
		
		
		
function Backup_Old_Data()
{
	# Check for old instbw, debug and log files and backup if needed
	cd $file_location_base
	Backup_Instbw=$(ls | grep .instbw$)
	Backup_Debug=$(ls | grep .debug$)
	Backup_Log=$(ls | grep .log$)
	
	if [ -n "$Backup_Instbw" ] || [ -n "$Backup_Debug" ] || [ -n "$Backup_Log" ] ; then
		echo -e '\E[1;33m' " Possible old assolo files found, moving them to ";tput sgr0; 
		echo "      "$file_location_base"Backup/"
		echo " "
		
		if [ ! -d $file_location_base"Backup/" ] ; then
			mkdir $file_location_base"Backup"
		fi
		
		mv *.instbw $file_location_base"Backup/" 2>> /dev/null
		mv *.instbw.data $file_location_base"Backup/" 2>> /dev/null
		mv *.instbw.data.plot $file_location_base"Backup/" 2>> /dev/null
		mv *.debug $file_location_base"Backup/" 2>> /dev/null
		mv *.debug.data $file_location_base"Backup/" 2>> /dev/null
		mv *.debug.data.plot $file_location_base"Backup/" 2>> /dev/null
		mv *.log $file_location_base"Backup/" 2>> /dev/null
		mv *.plot $file_location_base"Backup/" 2>> /dev/null
		mv *.stats $file_location_base"Backup/" 2>> /dev/null
	fi
}

	
	
function Finish_Preparations()
{
	echo -e '\E[1;37m' " Preparation finished, beginning experiment in (CRTL-C to cancel)";	tput sgr0
	echo -n "  "
	
	for i in {20..1}
	do
		echo -n "$i  "
		sleep 1
	done
	
	echo " "
}



function Do_a_magical_experiment()
{	# Every variable which is UPPER CASE is defined before the function call int the main function (see bottom)
	
	echo " "
	echo "  Preparing Assolo Test ("$NAME_OF_TESTED_PARAMETER") with "$exp_time" seconds each run:"
	cd $file_location_base

	# kill ALL instances of assolo before starting experiment	
	killall -9 assolo_rcv 2>&1 2>> /dev/null 
	killall -9 assolo_run 2>&1 2>> /dev/null
	sleep $wait_for_rcv
	
		
	count=1
	while [ $count -le $CYCLES ]
	do
		i=$count
		
		# Calculate Parameter value
		ParameterValue=$(echo "$i $PARAMETER_FORMULA" | calc -p)
		
		# Format the Calculated Parameter
		FormatedParamValue=$(printf "%.1f" $(echo $ParameterValue | tr . ,) | tr , .)
		
		# Generate Logfilenames
		Runner_Log=$NAME_OF_TESTED_PARAMETER"_"$FormatedParamValue"_"$UNIT_OF_TESTED_PARAMETER"-RUN.log"
		Receiver_Log=$NAME_OF_TESTED_PARAMETER"_"$FormatedParamValue"_"$UNIT_OF_TESTED_PARAMETER"-RCV.log"

		# Be sure log-files are empty
		rm -f $Runner_Log  ; touch $Runner_Log
		rm -f $Receiver_Log; touch $Receiver_Log
						
		# Start "assolo_rcv" on local PC
		bash -c "$(pwd)/assolo_rcv -D 2>> $(pwd)/$Receiver_Log &"
		sleep $wait_for_rcv

		# Start one cycle of assolo_run
 		echo -n "  - $NAME_OF_TESTED_PARAMETER ($(printf "%.1f" $(echo $ParameterValue | tr . ,) | tr , .) $UNIT_OF_TESTED_PARAMETER) ..." 

			echo "./assolo_run -S "$senderIP" -R "$receiverIP" -t "$exp_time" -l "$lowerBorder" -u "$upperBorder" "$ASSOLO_PARAMETER" "$ParameterValue >> $Runner_Log
			echo "__________________________________________________________________" >> $Runner_Log
			./assolo_run -S $senderIP -R $receiverIP -t $exp_time -l $lowerBorder -u $upperBorder $ASSOLO_PARAMETER $ParameterValue 2>> $Runner_Log

		echo " done"	

		# Stop all "assolo_rcv" on local PC
		killall -9 assolo_rcv 2>&1 2>> /dev/null
		sleep $wait_for_rcv
		
		
		# Get the names of instbw and debug
		Assolo_Instbw=$(ls | grep [0-9][0-9].instbw$)
		Assolo_Debug=$(ls | grep [0-9][0-9].debug$)
		
		echo "__________________________________________________________________" >> $Runner_Log
		echo " " >> $Runner_Log
		
		# Rename instbw/debug to a human readable name
		mv $Assolo_Instbw $NAME_OF_TESTED_PARAMETER"_"$FormatedParamValue"_"$UNIT_OF_TESTED_PARAMETER".instbw"
		mv $Assolo_Debug $NAME_OF_TESTED_PARAMETER"_"$FormatedParamValue"_"$UNIT_OF_TESTED_PARAMETER".debug"
		echo "mv "$Assolo_Instbw" "$NAME_OF_TESTED_PARAMETER"_"$FormatedParamValue"_"$UNIT_OF_TESTED_PARAMETER".instbw" >> $Runner_Log
		echo "mv "$Assolo_Debug" "$NAME_OF_TESTED_PARAMETER"_"$FormatedParamValue"_"$UNIT_OF_TESTED_PARAMETER".debug" >> $Runner_Log
		
		count=$[$count+1]
		
	done

	mv *.instbw $file_location_data$experiment_name/$assolo_version/$date/$NAME_OF_TESTED_PARAMETER/  
	mv *.debug  $file_location_data$experiment_name/$assolo_version/$date/$NAME_OF_TESTED_PARAMETER/ 
	mv *.log    $file_location_data$experiment_name/$assolo_version/$date/$NAME_OF_TESTED_PARAMETER/ 
	
	echo " "
}



function Calculate_Results()
{			
	# all *.instbw in one file
	###########################
	$file_location_assolo_helper_sh Combine_instbw $file_location_data$experiment_name/$assolo_version/$date/$NAME_OF_TESTED_PARAMETER/
	
	
	# *.instbw from assolo_run
	###########################
	$file_location_assolo_helper_sh Calculate_experiment $file_location_data$experiment_name/$assolo_version/$date/$NAME_OF_TESTED_PARAMETER/ $file_location_Instbwizer

			
	# *.debug from assolo_rcv
	###########################
	$file_location_assolo_helper_sh Calculate_debug $file_location_data$experiment_name/$assolo_version/$date/$NAME_OF_TESTED_PARAMETER/ $file_location_Debugizer

	
	# Calculate_stats
	######################
	$file_location_assolo_helper_sh Calculate_stats $file_location_data$experiment_name/$assolo_version/$date/$NAME_OF_TESTED_PARAMETER/ $file_location_Statsizer

					
	# *.instbw.data plotfile
	###########################
	$file_location_assolo_helper_sh Generate_plot $file_location_data$experiment_name/$assolo_version/$date/$NAME_OF_TESTED_PARAMETER/ 
	
	
	# *.debug.data plotfile
	###########################
	$file_location_assolo_helper_sh Generate_plot_debug $file_location_data$experiment_name/$assolo_version/$date/$NAME_OF_TESTED_PARAMETER/ 


	# *.instbw.data estimate difference plotfile
	###########################
	$file_location_assolo_helper_sh Generate_estimate_difference_plot $file_location_data$experiment_name/$assolo_version/$date/$NAME_OF_TESTED_PARAMETER/ 


    # Generate_Summary_Bandwidth_Estimation
	###########################
	$file_location_assolo_helper_sh Generate_summary_bandwidth_estimation $file_location_data$experiment_name/$assolo_version/$date/$NAME_OF_TESTED_PARAMETER/ 
}



function Print_Summary()
{	
	echo " "
	echo -e '\E[1;37m' " Summary of \"$(echo $experiment_name)\"";	tput sgr0	
	echo "  -> Location   : " $(echo   $file_location_data$experiment_name/$assolo_version/$date/)
	echo "  -> Directorys : " $(find   $file_location_data$experiment_name/$assolo_version/$date/ -type d | wc -l)
	echo "  -> Files      : " $(ls -R  $file_location_data$experiment_name/$assolo_version/$date/         | wc -l)
	echo "  -> Size       : " $(du -sh $file_location_data$experiment_name/$assolo_version/$date/         | awk {'print $1'})
	
	date_end=$(date +%s)
	date_dif=$(echo $date_end" - "$date_begin | calc -p)
	date_time=$(date -d @$date_dif)
	
	hours=$(echo "("${date_time:10:2}" - 1) + ("$(echo ${date_time:3:1}" - 1" | calc -p)" * 24)" | calc -p)
	minutes=${date_time:13:2}
	seconds=${date_time:16:2}
	
	echo "  -> Time       :  "$hours":"$minutes":"$seconds" [h:m:s]"
	echo " "
	echo " "
}
#############################################################################################################################################
# Functions END



# Main START
#############################################################################################################################################
clear

Print_Experiment_Summary
Check_Enviroment

# Create Folder Structure
NAME_OF_TESTED_PARAMETER="AverageProbingRate"		; Create_Folder
NAME_OF_TESTED_PARAMETER="BusyPeriod"				; Create_Folder
NAME_OF_TESTED_PARAMETER="DecreaseFactor"			; Create_Folder
NAME_OF_TESTED_PARAMETER="PacketSize"				; Create_Folder
NAME_OF_TESTED_PARAMETER="SmoothingOverEstimates"	; Create_Folder
NAME_OF_TESTED_PARAMETER="SpreadFactor"				; Create_Folder
NAME_OF_TESTED_PARAMETER="Threshold"				; Create_Folder
echo " "

Backup_Old_Data
Finish_Preparations

clear

# Run the Experiments
NAME_OF_TESTED_PARAMETER="AverageProbingRate"		; UNIT_OF_TESTED_PARAMETER="mbps"		; CYCLES=10;	PARAMETER_FORMULA="/ 10"			; ASSOLO_PARAMETER="-a"	; Do_a_magical_experiment
NAME_OF_TESTED_PARAMETER="BusyPeriod"				; UNIT_OF_TESTED_PARAMETER="s"			; CYCLES=10;	PARAMETER_FORMULA="* 0.5 + 2.5"		; ASSOLO_PARAMETER="-b"	; Do_a_magical_experiment
NAME_OF_TESTED_PARAMETER="DecreaseFactor"			; UNIT_OF_TESTED_PARAMETER="factor"		; CYCLES=10;	PARAMETER_FORMULA="* 0.1 + 1.0"		; ASSOLO_PARAMETER="-d"	; Do_a_magical_experiment
NAME_OF_TESTED_PARAMETER="PacketSize"				; UNIT_OF_TESTED_PARAMETER="byte"		; CYCLES=10;	PARAMETER_FORMULA="* 150"			; ASSOLO_PARAMETER="-p"	; Do_a_magical_experiment
NAME_OF_TESTED_PARAMETER="SmoothingOverEstimates"	; UNIT_OF_TESTED_PARAMETER="packets"	; CYCLES=10;	PARAMETER_FORMULA="* 2"				; ASSOLO_PARAMETER="-n"	; Do_a_magical_experiment
NAME_OF_TESTED_PARAMETER="SpreadFactor"				; UNIT_OF_TESTED_PARAMETER="factor"		; CYCLES=10;	PARAMETER_FORMULA="* 0.1 + 1"		; ASSOLO_PARAMETER="-s"	; Do_a_magical_experiment
NAME_OF_TESTED_PARAMETER="Threshold"				; UNIT_OF_TESTED_PARAMETER="factor"		; CYCLES=10;	PARAMETER_FORMULA="* 0.5 + 4.5"		; ASSOLO_PARAMETER="-e"	; Do_a_magical_experiment	


# Calculate Results
NAME_OF_TESTED_PARAMETER="AverageProbingRate"		; Calculate_Results
NAME_OF_TESTED_PARAMETER="BusyPeriod"				; Calculate_Results
NAME_OF_TESTED_PARAMETER="DecreaseFactor"			; Calculate_Results
NAME_OF_TESTED_PARAMETER="PacketSize"				; Calculate_Results
NAME_OF_TESTED_PARAMETER="SmoothingOverEstimates"	; Calculate_Results
NAME_OF_TESTED_PARAMETER="SpreadFactor"				; Calculate_Results
NAME_OF_TESTED_PARAMETER="Threshold"				; Calculate_Results


Print_Summary
#############################################################################################################################################
# Main END

cd $Calling_path
