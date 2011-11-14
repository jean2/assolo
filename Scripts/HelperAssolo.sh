#!/bin/bash

# Assolo Helper Pack Version 1.0
#
# This Script automates the generation of statistics and plotfiles for raw assolo instbw and debug files
# It was tested under Ubuntu 10.4 (2.6.32-31-generic - i686 GNU/Linux)
#
# More Information can be found in the README
#
# Licensed under "GNU GENERAL PUBLIC LICENSE Version 3"
# Sebastian.Wilken@uni-duesseldorf.de - Base Release 1.0 - 15.10.2011
#
Version=1.0

case $1 in
############################################################################################################################
Help|help)		# Syntax: Help COMMAND
	clear
	case $2 in
		AnalyzeAll|analyzeall|Analyzeall)
			echo -e '\E[1;37m' "------------------------------------";	tput sgr0
			echo -e '\E[1;37m' "- HelperAssolo Script Version "$Version" -";	tput sgr0
			echo -e '\E[1;37m' "------------------------------------";	tput sgr0
			echo -en '\E[1;31m' "Syntax: HelperAssolo.sh"
			echo -en '\E[1;33m' "AnalyzeAll";  		tput sgr0	# Pretty Coloring =)
			echo -e  '\E[1;32m' "ExperimentData_Directory";	tput sgr0	# Last Command reset the color
			echo " "	
			echo -n "	"
			echo -en '\E[1;32m' "ExperimentData_Directory";	tput sgr0	
			echo ": Directory where the*.instbw and *.debug files are stored"
			echo " "
			echo -e '\E[1;34m' "Purpose:";	tput sgr0
			echo -e '\E[1;37m'" Calculate experiment data and generate based on the calculated data plotfiles and statistics.";	tput sgr0
			echo " "
			echo -e '\E[1;34m' "Steps:";	tput sgr0
			echo " Check if all needed Programs are present."
			echo -n " Create a new folder with actual date and move ALL *.instbw and *.debug files from "
			echo -en '\E[1;32m' "ExperimentData_Directory";tput sgr0
			echo " to it."
			echo " Calculate/Generate statistics and plotfiles using the following order of steps:"
			echo -n "	1)"; echo -e '\E[1;33m' "Combine_instbw"			;tput sgr0
			echo -n "	1)"; echo -e '\E[1;33m' "Calculate_experiment"			;tput sgr0
			echo -n "	2)"; echo -e '\E[1;33m' "Calculate_debug"			;tput sgr0
			echo -n "	3)"; echo -e '\E[1;33m' "Calculate_stats"			;tput sgr0
			echo -n "	4)"; echo -e '\E[1;33m' "Generate_plot"				;tput sgr0
			echo -n "	5)"; echo -e '\E[1;33m' "Generate_plot_debug"			;tput sgr0
			echo -n "	5)"; echo -e '\E[1;33m' "Generate_estimate_difference_plot"		;tput sgr0
			echo " "
			echo -e '\E[1;34m' "Example: ";	tput sgr0
			echo "  cd /tmp/assolo/Scripts/" 
			echo "  ./HelperAssolo.sh AnalyzeAll /tmp/assolo/"
			echo " "
		;;
		Calculate_experiment|calculate_experiment)
			echo -e '\E[1;37m' "------------------------------------";	tput sgr0
			echo -e '\E[1;37m' "- HelperAssolo Script Version "$Version" -";	tput sgr0
			echo -e '\E[1;37m' "------------------------------------";	tput sgr0
			echo -en '\E[1;31m' "Syntax: HelperAssolo.sh"
			echo -en '\E[1;33m' "Calculate_experiment";  	tput sgr0	# Pretty Coloring =)
			echo -en '\E[1;32m' "ExperimentData_Directory";	tput sgr0	# Last Command reset the color
			echo -e  '\E[32m'   "Instbwizer_Binary_Location";	tput sgr0
			echo " "	
			echo -n "	"
			echo -en '\E[1;32m' "ExperimentData_Directory";	tput sgr0	
			echo "	: Directory where the *.instbw files are stored"
			echo -n "	"
			echo -en '\E[32m' "Instbwizer_Binary_Location";	tput sgr0	
			echo "	: Directory where the binary \"Instbwizer\" is located"
			echo " "
			echo -e '\E[1;34m' "Purpose:";	tput sgr0
			echo -e '\E[1;37m' " Start the Instbwizer to parse the assolo *.instbw file into *.instbw.data format.";	tput sgr0
			echo -e '\E[1;37m' " For more Information about the file format use:";tput sgr0
			echo                " 	\"./HelperAssolo.sh Info Instbw\""
			echo " "
			echo -e '\E[1;34m' "Example: ";	tput sgr0
			echo "  cd /tmp/assolo/Scripts/"
			echo "  ./HelperAssolo.sh Calculate_experiment /tmp/assolo/ /tmp/assolo/ScriptsC-Code/Instbwizer"
			echo " "
		;;
		Calculate_debug|calculate_debug)	
			echo -e '\E[1;37m' "------------------------------------";	tput sgr0
			echo -e '\E[1;37m' "- HelperAssolo Script Version "$Version" -";	tput sgr0
			echo -e '\E[1;37m' "------------------------------------";	tput sgr0
			echo -en '\E[1;31m' "Syntax: HelperAssolo.sh"
			echo -en '\E[1;33m' "Calculate_debug";  	tput sgr0	# Pretty Coloring =)
			echo -en '\E[1;32m' "ExperimentData_Directory";	tput sgr0	# Last Command reset the color
			echo -e  '\E[32m'   "Debugizer_Binary_Location";tput sgr0
			echo " "	
			echo -n "	"
			echo -en '\E[1;32m' "ExperimentData_Directory";	tput sgr0	
			echo "	: Directory where the *.debug files are stored"
			echo -n "	"
			echo -en '\E[32m' "Debugizer_Binary_Location";	tput sgr0	
			echo "	: Directory where the binary \"Debugizer\" is located"
			echo " "
			echo -e '\E[1;34m' "Purpose:";	tput sgr0
			echo -e '\E[1;37m' " Start the Debugizer to parse the assolo *.debug file into *.debug.data format.";	tput sgr0
			echo -e '\E[1;37m' " For more Information about the file format use:";tput sgr0
			echo                " 	\"./HelperAssolo.sh Info Debug\""
			echo " "
			echo -e '\E[1;34m' "Example: ";	tput sgr0
			echo "  cd /tmp/assolo/Scripts/"
			echo "  ./HelperAssolo.sh Calculate_debug /tmp/assolo/ /tmp/assolo/Scripts/C-Code/Debugizer"
			echo " "
		;;
		Calculate_stats|calculate_stats)
			echo -e '\E[1;37m' "------------------------------------";	tput sgr0
			echo -e '\E[1;37m' "- HelperAssolo Script Version "$Version" -";	tput sgr0
			echo -e '\E[1;37m' "------------------------------------";	tput sgr0
			echo -en '\E[1;31m' "Syntax: HelperAssolo.sh"
			echo -en '\E[1;33m' "Calculate_stats";  	tput sgr0	# Pretty Coloring =)
			echo -en '\E[1;32m' "ExperimentData_Directory";	tput sgr0	# Last Command reset the color
			echo -e  '\E[32m'   "Statsizer_Binary_Location";tput sgr0
			echo " "	
			echo -n "	"
			echo -en '\E[1;32m' "ExperimentData_Directory";	tput sgr0	
			echo "	: Directory where the *.instbw.data and *.debug.data files are stored"
			echo -n "	"
			echo -en '\E[32m' "Statsizer_Binary_Location";	tput sgr0	
			echo "	: Directory where the binary \"Statsizer\" is located"
			echo " "
			echo -e '\E[1;34m' "Purpose:";	tput sgr0
			echo -e '\E[1;37m' " Start the Statsizer to calculate statistics for the assolo *.debug.data/*.instbw.data files.";	tput sgr0
			echo -e '\E[1;37m' " For more Information about the file format use:";tput sgr0
			echo                " 	\"./HelperAssolo.sh Info Stats\""
			echo " "
			echo -e '\E[1;34m' "Example: ";	tput sgr0
			echo "  cd /tmp/assolo/Scripts/"
			echo "  ./HelperAssolo.sh Calculate_stats /tmp/assolo/ /tmp/assolo/Scripts/C-Code/Statsizer"
			echo " "
		;;
		Generate_plot|generate_plot)
			echo -e '\E[1;37m' "------------------------------------";	tput sgr0
			echo -e '\E[1;37m' "- HelperAssolo Script Version "$Version" -";	tput sgr0
			echo -e '\E[1;37m' "------------------------------------";	tput sgr0
			echo -en '\E[1;31m' "Syntax: HelperAssolo.sh"
			echo -en '\E[1;33m' "Generate_plot";  		tput sgr0	# Pretty Coloring =)
			echo -e  '\E[1;32m' "ExperimentData_Directory";	tput sgr0	# Last Command reset the color
			echo " "	
			echo -n "	"
			echo -en '\E[1;32m' "ExperimentData_Directory";	tput sgr0	
			echo ": Directory where *.instbw.data file(s) is/are located"
			echo " "
			echo -e '\E[1;34m' "Purpose:";	tput sgr0
			echo -en '\E[1;37m'"  Generates a Gnuplot-File (*.plot) for each *.instbw.data file in the";echo -e  '\E[1;32m' "ExperimentData_Directory.";	tput sgr0
			echo -e '\E[1;37m' " For more Information about the plot file use:";tput sgr0
			echo                " 	\"./HelperAssolo.sh Info Plot\""
			echo " "
			echo -e '\E[1;34m' "Example: ";	tput sgr0
			echo "  cd /tmp/assolo/Scripts/"
			echo "  ./HelperAssolo.sh Generate_plot /tmp/assolo/"
			echo " "
		;;
		Generate_plot_debug|generate_plot_debug)
			echo -e '\E[1;37m' "------------------------------------";	tput sgr0
			echo -e '\E[1;37m' "- HelperAssolo Script Version "$Version" -";	tput sgr0
			echo -e '\E[1;37m' "------------------------------------";	tput sgr0
			echo -en '\E[1;31m' "Syntax: HelperAssolo.sh"
			echo -en '\E[1;33m' "Generate_plot_debug";  	tput sgr0	# Pretty Coloring =)
			echo -e  '\E[1;32m' "ExperimentData_Directory";	tput sgr0	# Last Command reset the color
			echo " "	
			echo -n "	"
			echo -en '\E[1;32m' "ExperimentData_Directory";	tput sgr0	
			echo ": Directory where *.debug.data file(s) is/are located"
			echo " "
			echo -e '\E[1;34m' "Purpose:";	tput sgr0
			echo -en '\E[1;37m'"  Generates a Gnuplot-File (*.plot) for each *.debug.data file in the";echo -e  '\E[1;32m' "ExperimentData_Directory.";	tput sgr0
			echo -e '\E[1;37m' " For more Information about the plot file use:";tput sgr0
			echo                " 	\"./HelperAssolo.sh Info Plot\""
			echo " "
			echo -e '\E[1;34m' "Example: ";	tput sgr0
			echo "  cd /tmp/assolo/Scripts/"
			echo "  ./HelperAssolo.sh Generate_plot_debug /tmp/assolo/"
			echo " "
		;;
		Generate_estimate_difference_plot|Generate_estimate_difference_plot)
			echo -e '\E[1;37m' "------------------------------------";	tput sgr0
			echo -e '\E[1;37m' "- HelperAssolo Script Version "$Version" -";	tput sgr0
			echo -e '\E[1;37m' "------------------------------------";	tput sgr0
			echo -en '\E[1;31m' "Syntax: HelperAssolo.sh"
			echo -en '\E[1;33m' "Generate_estimate_difference_plot";  	tput sgr0	# Pretty Coloring =)
			echo -e  '\E[1;32m' "ExperimentData_Directory";	tput sgr0	# Last Command reset the color
			echo " "	
			echo -n "	"
			echo -en '\E[1;32m' "ExperimentData_Directory";	tput sgr0	
			echo ": Directory where *.debug.data file(s) is/are located"
			echo " "
			echo -e '\E[1;34m' "Purpose:";	tput sgr0
			echo -e '\E[1;37m'"  Generates a Gnuplot-File in which you can see the percentual difference from the last estimate to the actual.";	tput sgr0
			echo -e '\E[1;37m'"  This plot uses the multiplot command. If you want to refresh the plot you have to reload it";tput sgr0
			echo -e '\E[1;37m'"  with \"load './[FILENAME].instbw.data.difference_plot'\".";tput sgr0
			echo -e '\E[1;37m' " For more Information about the plot file use:";tput sgr0
			echo                " 	\"./HelperAssolo.sh Info Plot\""
			echo " "
			echo -e '\E[1;34m' "Example: ";	tput sgr0
			echo "  cd /tmp/assolo/Scripts/"
			echo "  ./HelperAssolo.sh Generate_estimate_difference_plot /tmp/assolo/"
			echo " "		
		;;
		Combine_instbw|combine_instbw)
			echo -e '\E[1;37m' "------------------------------------";	tput sgr0
			echo -e '\E[1;37m' "- HelperAssolo Script Version "$Version" -";	tput sgr0
			echo -e '\E[1;37m' "------------------------------------";	tput sgr0
			echo -en '\E[1;31m' "Syntax: HelperAssolo.sh"
			echo -en '\E[1;33m' "Combine_instbw";  	tput sgr0	# Pretty Coloring =)
			echo -e  '\E[1;32m' "Instbw_Files_Folder";			tput sgr0	# Last Command reset the color
			echo " "	
			echo -n "	"
			echo -en '\E[1;32m' "Instbw_Files_Folder";	tput sgr0	
			echo ": Location of a bunch of *.instbw files"
			echo " "
			echo -e '\E[1;34m' "Purpose:";	tput sgr0
			echo -en '\E[1;37m'"  Generates the \"summary_combined.instbw\". This file contain all datapoints from the *.instbw files in the"
			echo -e '\E[1;32m' "Instbw_Files_Folder".;			tput sgr0 
			echo -e '\E[1;37m' " Each file will be added the end of \"summary_combined.instbw\" until there is no unparsed file in the folder."; tput sgr0 
			echo -e '\E[1;37m' " The files will be added in alphabetic order and then sorted according to the timestamp.";	tput sgr0
			echo " "
			echo -e '\E[1;34m' "Example: ";	tput sgr0
			echo "  cd /tmp/assolo/Scripts/"
			echo "  ./HelperAssolo.sh Combine_instbw /tmp/assolo/"
			echo " "
		;;
		Generate_summary_bandwidth_estimation|generate_summary_bandwidth_estimation)
			echo -e '\E[1;37m' "------------------------------------";	tput sgr0
			echo -e '\E[1;37m' "- HelperAssolo Script Version "$Version" -";	tput sgr0
			echo -e '\E[1;37m' "------------------------------------";	tput sgr0
			echo -en '\E[1;31m' "Syntax: HelperAssolo.sh"
			echo -en '\E[1;33m' "Generate_summary_bandwidth_estimation";  	tput sgr0	# Pretty Coloring =)
			echo -e  '\E[1;32m' "ExperimentData_Directory";			tput sgr0	# Last Command reset the color
			echo " "	
			echo -n "	"
			echo -en '\E[1;32m' "ExperimentData_Directory";	tput sgr0	
			echo ": Location of a bunch of *.instbw.data files"
			echo " "
			echo -e '\E[1;34m' "Purpose:";	tput sgr0
			echo -e '\E[1;37m' " Generates the \"summary_bandwidthestimation.data\" and the \"summary_bandwidthestimation.plot\".";	tput sgr0
			echo -en '\E[1;31m'"  Warning:"
			echo -e '\E[1;37m' "The last bandwidth estimation of each '*.instbw.data' is used to generate the summary.";	tput sgr0
			echo -e '\E[1;37m' "          See statistics for exact values. File excluded in this function is 'summary_combined.instbw.data'";	tput sgr0
			echo " "
			echo -e '\E[1;34m' "Example: ";	tput sgr0
			echo "  cd /tmp/assolo/Scripts/"
			echo "  ./HelperAssolo.sh Generate_summary_bandwidth_estimation /tmp/assolo/"
			echo " "
		;;
		Gnuplot_folder|gnuplot_folder)
			echo -e '\E[1;37m' "------------------------------------";	tput sgr0
			echo -e '\E[1;37m' "- HelperAssolo Script Version "$Version" -";	tput sgr0
			echo -e '\E[1;37m' "------------------------------------";	tput sgr0
			echo -en '\E[1;31m' "Syntax: HelperAssolo.sh"
			echo -en '\E[1;33m' "Gnuplot_folder";  		tput sgr0	# Pretty Coloring =)
			echo -en '\E[1;32m' "Folder_to_plot";		tput sgr0	# Last Command reset the color
			echo -e  '\E[32m'   "Files_to_plot_filter";	tput sgr0
			echo " "	
			echo -n "	"
			echo -en '\E[1;32m' "Folder_to_plot";	tput sgr0	
			echo "		: Directory where *.plot files are located"
			echo -n "	"
			echo -en '\E[32m' "Files_to_plot_filter";	tput sgr0	
			echo "	: Filter to select which filestypes should be ploted. instbw-/debug/all Files)"
			echo " "
			echo -e '\E[1;34m' "Purpose:";	tput sgr0
			echo -e '\E[1;37m'"  This can help opening all instbw and/or debug plotfiles in one folder automaticly.";	tput sgr0
			echo -e '\E[1;37m'"  Please keep in mind not to strangle your computer with huge counts.";	tput sgr0
			echo " "
			echo -e '\E[1;34m' "Example: ";	tput sgr0
			echo "  cd /tmp/assolo/Scripts/"
			echo "  ./HelperAssolo.sh Gnuplot_folder /tmp/assolo/ instbw"
			echo " "
		;;
		*)
			$0 # Like ./Helperscript but with correct path.
	esac
	;;
############################################################################################################################



############################################################################################################################
Info|info)		# Syntax: Info SUBCOMMAND
	clear
	case $2 in
		Instbw|instbw)
			echo -e '\E[1;37m' "----------------";	tput sgr0
			echo -e '\E[1;37m' "- Instbw files -";	tput sgr0
			echo -e '\E[1;37m' "----------------";	tput sgr0
			echo -e '\E[37m'   " This file is the standard output from assolo_run.";tput sgr0
			echo " "
			echo -e '\E[1;37m' " It contains:";					tput sgr0
			echo -en '\E[1;37m'"   (1)";						tput sgr0
			echo -e '\E[37m'   "A timestamp in seconds";				tput sgr0
			echo -en '\E[1;37m'"   (2)";						tput sgr0
			echo -e '\E[37m'   "A coresponding bandwidth estimation in mbps";	tput sgr0
			echo " "
			echo -en '\E[37m'   " The file itself is";	tput sgr0
			echo -en '\E[1;37m' "NOT sorted";		tput sgr0
			echo -e '\E[37m'   "according to timestamps.";	tput sgr0
			echo " "
			echo -e '\E[1;37m' " Example:";	tput sgr0
			echo -e '\E[37m'   "    1298972583.343630 9.089000";	tput sgr0
			echo -e '\E[37m'   "    1298972588.115450 9.168000";	tput sgr0
			echo -e '\E[37m'   "    1298972592.882190 9.247000";	tput sgr0
			echo -e '\E[37m'   "    1298972588.653840 9.211000";	tput sgr0
			echo -e '\E[37m'   "    1298972593.425700 9.228000";	tput sgr0
			echo " "
			echo " "
			echo -e '\E[1;37m' "---------------------";	tput sgr0
			echo -e '\E[1;37m' "- Instbw.data files -";	tput sgr0
			echo -e '\E[1;37m' "---------------------";	tput sgr0
			echo -e '\E[37m'   " This file is the output of the \"Instbwizer\".";	tput sgr0
			echo -e '\E[37m'   " It used for nicer plotting and generation of additional information.";			tput sgr0
			echo " "
			echo -e '\E[1;37m' " It contains:";					tput sgr0
			echo -en '\E[1;37m'"   (1)";						tput sgr0
			echo -e '\E[37m'   "A normalized timestamp in seconds";			tput sgr0
			echo -en '\E[1;37m'"   (2)";						tput sgr0
			echo -e '\E[37m'   "A coresponding bandwidth estimation in mbps";	tput sgr0
			echo -en '\E[1;37m'"   (3)";						tput sgr0
			echo -e '\E[37m'   "A moving average over 5 samples in mbps based on the bandwidth estimation";	tput sgr0
			echo -en '\E[1;37m'"   (4)";						tput sgr0
			echo -e '\E[37m'   "The absolut difference from the last estimate to the actual in mbps";	tput sgr0
			echo -en '\E[1;37m'"   (5)";						tput sgr0
			echo -e '\E[37m'   "The absolut difference in percent";	tput sgr0
			echo -en '\E[1;37m'"   (6)";						tput sgr0
			echo -e '\E[37m'   "The absolut difference as average over the count of estimates in mbps";	tput sgr0
			echo -en '\E[1;37m'"   (7)";						tput sgr0
			echo -e '\E[37m'   "The sum of the absolut difference in mbps";	tput sgr0
			echo " "
			echo -en '\E[37m'   " The file itself is";	tput sgr0
			echo -en '\E[1;37m' "sorted";			tput sgr0
			echo -e '\E[37m'   "according to timestamps.";	tput sgr0
			echo " "
			echo -e '\E[37m'   " The normalized timestamp is calculated with \"timestamp - minimum timestamp in the file\".";	tput sgr0
			echo -e '\E[37m'   " The moving average is calculated for the first 4 samples with \"summ / sample count\".";		tput sgr0
			echo -e '\E[37m'   " Assolo itself uses a moving average (Parameter -n | default 11). Keep this in mind.";		tput sgr0
			echo -e '\E[37m'   " The moving average from the instbw.data is used for a nicer plot.";				tput sgr0
			echo -e '\E[37m'   " Since the first estimate has no last the absolute difference will be set to 0.";				tput sgr0
			echo -e '\E[37m'   " The absolut difference as moving average uses the count of parsed estimates.";				tput sgr0
			echo -e '\E[37m'   " First absolut difference => count 1, 33th absolut difference => count = 33";				tput sgr0
			echo " "
			echo -e '\E[1;37m' " Example:";	tput sgr0
			echo -e '\E[37m'   "    5.461240	902.847000	961.288200	76.527000	7.813869	16.073714	112.516000";	tput sgr0
			echo -e '\E[37m'   "    5.496470	909.872000	947.692400	7.025000	0.778094	14.942625	119.541000";	tput sgr0
			echo -e '\E[37m'   "    7.211840	982.156000	949.956400	72.284000	7.944414	21.313889	191.825000";	tput sgr0
			echo -e '\E[37m'   "    7.253000	920.353000	938.920400	61.803000	6.292585	25.362800	253.628000";	tput sgr0
			echo -e '\E[37m'   "    7.282950	950.109000	933.067400	29.756000	3.233107	25.762182	283.384000";	tput sgr0
			echo " "
		;;
		Debug|debug)
			echo -e '\E[1;37m' "---------------";	tput sgr0
			echo -e '\E[1;37m' "- Debug files -";	tput sgr0
			echo -e '\E[1;37m' "---------------";	tput sgr0
			echo -e '\E[37m'   " This file is the debug output from assolo_run.";		tput sgr0
			echo " "
			echo -e '\E[1;37m' " It contains:";						tput sgr0
			echo -en '\E[1;37m'"   (1)";							tput sgr0
			echo -e '\E[37m'   "Chirp number";						tput sgr0
			echo -en '\E[1;37m'"   (2)";							tput sgr0
			echo -e '\E[37m'   "Packet number in a Chirp";			tput sgr0
			echo -en '\E[1;37m'"   (3)";							tput sgr0
			echo -e '\E[37m'   "Timestamp of sending in seconds (sender's clock)";		tput sgr0
			echo -en '\E[1;37m'"   (4)";							tput sgr0
			echo -e '\E[37m'   "Timestamp of receiving in seconds (receiver's clock)";	tput sgr0
			echo " "
			echo -e '\E[1;37m' " Example:";	tput sgr0
			echo -e '\E[37m'   "    111 3 1298972602.103666 1298972602.580931";	tput sgr0
			echo -e '\E[37m'   "    111 4 1298972602.105007 1298972602.582314";	tput sgr0
			echo -e '\E[37m'   "    111 5 1298972602.106187 1298972602.583467";	tput sgr0
			echo -e '\E[37m'   "    111 6 1298972602.107257 1298972602.584540";	tput sgr0
			echo -e '\E[37m'   "    111 7 1298972602.108252 1298972602.585543";	tput sgr0
			echo " "
			echo " "
			echo -e '\E[1;37m' "--------------------";	tput sgr0
			echo -e '\E[1;37m' "- Debug.data files -";	tput sgr0
			echo -e '\E[1;37m' "--------------------";	tput sgr0
			echo -e '\E[37m'   " This file is the output of the \"Debugizer\".";	tput sgr0
			echo -e '\E[37m'   " It used for nicer plotting.";			tput sgr0
			echo " "
			echo -e '\E[1;37m' " It contains:";							tput sgr0
			echo -en '\E[1;37m'"   (1)";								tput sgr0
			echo -e '\E[37m'   "Packet number";							tput sgr0
			echo -en '\E[1;37m'"   (2)";								tput sgr0
			echo -e '\E[37m'   "Chirp number";							tput sgr0
			echo -en '\E[1;37m'"   (3)";								tput sgr0
			echo -e '\E[37m'   "Packet number in a Chirp";				tput sgr0
			echo -en '\E[1;37m'"   (4)";								tput sgr0
			echo -e '\E[37m'   "Normalized timestamp of sending in seconds (sender's clock)";	tput sgr0
			echo -en '\E[1;37m'"   (5)";								tput sgr0
			echo -e '\E[37m'   "Normalized timestamp of receiving in seconds (receiver's clock)";	tput sgr0
			echo -en '\E[1;37m'"   (6)";								tput sgr0
			echo -e '\E[37m'   "Difference of normalized timestamp of sending: i - (i-1)";		tput sgr0
			echo -en '\E[1;37m'"   (7)";								tput sgr0
			echo -e '\E[37m'   "Difference of normalized timestamp of receiving: i - (i-1)";	tput sgr0
			echo -en '\E[1;37m'"   (8)";								tput sgr0
			echo -e '\E[37m'   "Absolute value of the difference between (7) and (8)";		tput sgr0
			echo " "
			echo -e '\E[37m'   " The normalized timestamp for (4),(5) is calculated with \"timestamp - minimum timestamp in the file\".";	tput sgr0
			echo " "
			echo -e '\E[1;37m' " Example:";	tput sgr0
			echo -e '\E[37m'   "    1987  111  7   52.484696  52.487532  0.000995  0.001000  0.000005";tput sgr0
			echo -e '\E[37m'   "    1988  111  8   52.485636  52.488532  0.000940  0.001000  0.000060";tput sgr0
			echo -e '\E[37m'   "    1989  111  9   52.486534  52.489532  0.000898  0.001000  0.000102";tput sgr0
			echo -e '\E[37m'   "    1990  111  10  52.487394  52.490282  0.000860  0.000750  0.000110";tput sgr0
			echo -e '\E[37m'   "    1991  111  11  52.488212  52.491032  0.000818  0.000750  0.000068";tput sgr0
			echo " "
		;;
		Plot|plot)
			case $3 in
				Instbw|instbw) 
					echo -e '\E[1;37m' "---------------";						tput sgr0
					echo -e '\E[1;37m' "- Instbw Plot -";						tput sgr0
					echo -e '\E[1;37m' "---------------";						tput sgr0
					echo -en '\E[1;37m' " x-Axis :";						tput sgr0
					echo -e  '\E[37m' "Time in seconds";						tput sgr0
					echo -en '\E[1;37m' " y-Axis :";						tput sgr0
					echo -e  '\E[37m' "Bandwidth in mbps";						tput sgr0
					echo -en '\E[1;37m' " Line   :";						tput sgr0
					echo -e  '\E[37m' "Moving average bandwidth estimation (5 samples) in mbps";	tput sgr0
					echo -en '\E[1;37m' " Points :";						tput sgr0
					echo -e  '\E[37m' "Bandwidth estimation from assolo";				tput sgr0
					echo " "
					echo -en '\E[37m' " Starting gnuplot (must be installed) ...";	tput sgr0
						cd ExampleFiles
						gnuplot -persist example.instbw.data.plot
						cd ..
					echo -e '\E[37m' "done";					tput sgr0
					echo " "
				;;
				Difference|difference)
					echo -e '\E[1;37m' "--------------------";	tput sgr0
					echo -e '\E[1;37m' "- Difference Plot -";	tput sgr0
					echo -e '\E[1;37m' "-------------------";	tput sgr0
					echo -en '\E[1;37m' " x-Axis 1&2      :";							tput sgr0
					echo -e  '\E[37m' "Time in seconds     ";								tput sgr0
					echo -en '\E[1;37m' " y-Axis 1        :";							tput sgr0
					echo -e  '\E[37m' "Bandwith Estimate in mbps";						tput sgr0
					echo -en '\E[1;37m' " y-Axis 2        :";							tput sgr0
					echo -e  '\E[37m' "Absolut difference to last estimate in percent";	tput sgr0
					echo -en '\E[1;37m' " Blue Line       :";							tput sgr0
					echo -e  '\E[37m' "Bandwith Estimation  ";							tput sgr0
					echo -en '\E[1;37m' " Red Line (Steps):";							tput sgr0
					echo -e  '\E[37m' "Absolut difference in percent";							tput sgr0
					echo " "
					echo -en '\E[37m' " Starting gnuplot (must be installed) ...";	tput sgr0
						cd ExampleFiles
						gnuplot -persist example.instbw.data.difference_plot
						cd ..
					echo -e '\E[37m' "done";					tput sgr0
					echo " "
					echo " "
				;;
				Debug|debug) 
					echo -e '\E[1;37m' "--------------";	tput sgr0
					echo -e '\E[1;37m' "- Debug Plot -";	tput sgr0
					echo -e '\E[1;37m' "--------------";	tput sgr0
					echo -en '\E[1;37m' " x-Axis          :";							tput sgr0
					echo -e  '\E[37m' "Time in seconds";								tput sgr0
					echo -en '\E[1;37m' " y-Axis          :";							tput sgr0
					echo -e  '\E[37m' "Packet Count";								tput sgr0
					echo -en '\E[1;37m' " Gray line       :";							tput sgr0
					echo -e  '\E[37m' "Timestamp at which Packet was send (Sender's clock)";			tput sgr0
					echo -en '\E[1;37m' " Light gray line :";							tput sgr0
					echo -e  '\E[37m' "Timestamp at which Packet was received (Receiver's clock)";			tput sgr0
					echo -en '\E[1;37m' " Red bar         :";							tput sgr0
					echo -e  '\E[37m' "Delay caused by Network (not 100% exact), lined up with sender's time";	tput sgr0
					echo -en '\E[1;37m' " Blue bar        :";							tput sgr0
					echo -e  '\E[37m' "Delay caused by Network (not 100% exact), lined up with receiver's time";	tput sgr0
					echo " "
					echo -e '\E[37m' " The delay is not 100% exact since the clocks on both system can differ.";	tput sgr0
					echo -e '\E[37m' " The speed of the clocks can differ and its not a constant value.";		tput sgr0
					echo -e '\E[37m' " Keep in mind its a realworld system and not a perfect one from theory.";	tput sgr0
					echo " "
					echo -en '\E[37m' " Starting gnuplot (must be installed) ...";	tput sgr0
						cd ExampleFiles
						gnuplot -persist example.debug.data.plot
						cd ..
					echo -e '\E[37m' "done";					tput sgr0
					echo " "
				;;
				SBE|sbe) # Summary Bandwidth Estimation
					echo " "
					echo -e '\E[1;37m' "-------------------------------------";			tput sgr0
					echo -e '\E[1;37m' "- Summary Bandwidth Estimation Plot -";			tput sgr0
					echo -e '\E[1;37m' "-------------------------------------";			tput sgr0
					echo -en '\E[1;37m' " x-Axis :";						tput sgr0
					echo -e  '\E[37m' "Bandwidth in mbps";					tput sgr0
					echo -en '\E[1;37m' " y-Axis :";						tput sgr0
					echo -e  '\E[37m' "Test number";						tput sgr0
					echo -en '\E[1;37m' " Line   :";						tput sgr0
					echo -e  '\E[37m' "Last Bandwidth estimation in mbps of each single Test";	tput sgr0
					echo " "
					echo -en '\E[37m' " Starting gnuplot (must be installed) ...";	tput sgr0
						cd ExampleFiles
						gnuplot -persist summary_bandwidthestimation.plot
						cd ..
					echo -e '\E[37m' "done";					tput sgr0
					echo " "
				;;
				*)
				echo -e '\E[1;37m' "---------------";						tput sgr0
				echo -e '\E[1;37m' "- Instbw Plot -";						tput sgr0
				echo -e '\E[1;37m' "---------------";						tput sgr0
				echo -en '\E[1;37m' " x-Axis :";						tput sgr0
				echo -e  '\E[37m' "Time in seconds";						tput sgr0
				echo -en '\E[1;37m' " y-Axis :";						tput sgr0
				echo -e  '\E[37m' "Bandwidth in mbps";						tput sgr0
				echo -en '\E[1;37m' " Line   :";						tput sgr0
				echo -e  '\E[37m' "Moving average bandwidth estimation (5 samples) in mbps";	tput sgr0
				echo -en '\E[1;37m' " Points :";						tput sgr0
				echo -e  '\E[37m' "Bandwidth estimation from assolo";				tput sgr0
				echo " "
				echo -e '\E[37m' " For more information use	\"./HelperAssolo.sh Info Instbw\"";	tput sgr0
				echo -e '\E[37m' " For an example use		\"./HelperAssolo.sh Info Plot Instbw\"";tput sgr0
				echo " "
				echo " "
				echo -e '\E[1;37m' "--------------";	tput sgr0
				echo -e '\E[1;37m' "- Debug Plot -";	tput sgr0
				echo -e '\E[1;37m' "--------------";	tput sgr0
				echo -en '\E[1;37m' " x-Axis          :";							tput sgr0
				echo -e  '\E[37m' "Time in seconds";								tput sgr0
				echo -en '\E[1;37m' " y-Axis          :";							tput sgr0
				echo -e  '\E[37m' "Packet Count";								tput sgr0
				echo -en '\E[1;37m' " Gray line       :";							tput sgr0
				echo -e  '\E[37m' "Timestamp at which Packet was send (Sender's clock)";			tput sgr0
				echo -en '\E[1;37m' " Light gray line :";							tput sgr0
				echo -e  '\E[37m' "Timestamp at which Packet was received (Receiver's clock)";			tput sgr0
				echo -en '\E[1;37m' " Red bar         :";							tput sgr0
				echo -e  '\E[37m' "Delay caused by Network (not 100% exact), lined up with sender's time";	tput sgr0
				echo -en '\E[1;37m' " Blue bar        :";							tput sgr0
				echo -e  '\E[37m' "Delay caused by Network (not 100% exact), lined up with receiver's time";	tput sgr0
				echo " "
				echo -e '\E[37m' " The delay is not 100% exact since the clocks on both system can differ.";	tput sgr0
				echo -e '\E[37m' " The speed of the clocks can differ and its not a constant value.";		tput sgr0
				echo -e '\E[37m' " Keep in mind its a realworld system and not a perfect one from theory.";	tput sgr0
				echo " "
				echo -e '\E[37m' " For more information use	\"./HelperAssolo.sh Info Debug\"";		tput sgr0
				echo -e '\E[37m' " For an example use		\"./HelperAssolo.sh Info Plot Debug\"";		tput sgr0
				echo " "
				echo " "
				echo -e '\E[1;37m' "--------------------";	tput sgr0
				echo -e '\E[1;37m' "- Difference Plot -";	tput sgr0
				echo -e '\E[1;37m' "-------------------";	tput sgr0
				echo -en '\E[1;37m' " x-Axis 1&2      :";							tput sgr0
				echo -e  '\E[37m' "Time in seconds     ";							tput sgr0
				echo -en '\E[1;37m' " y-Axis 1        :";							tput sgr0
				echo -e  '\E[37m' "Bandwith Estimate in mbps";						tput sgr0
				echo -en '\E[1;37m' " y-Axis 2        :";							tput sgr0
				echo -e  '\E[37m' "Absolut difference to last estimate in percent";	tput sgr0
				echo -en '\E[1;37m' " Blue Line       :";							tput sgr0
				echo -e  '\E[37m' "Bandwith Estimation  ";							tput sgr0
				echo -en '\E[1;37m' " Red Line (Steps):";							tput sgr0
				echo -e  '\E[37m' "Absolut difference in percent  ";							tput sgr0
				echo " "
				echo -e '\E[37m' " The top plot is the estimated Bandwidth (blue) and the bottom plot the absolut difference (red).";	tput sgr0
				echo -e '\E[37m' " Steps is used instead of line so its easier to link it to the bandwidth. Steps goes directly up/down to the value ";	tput sgr0
				echo -e '\E[37m' " when the estimate begins to rise/fall and will only go up/down again with the next estimate.";	tput sgr0
				echo -e '\E[37m' " If you want to refresh the plot, open it in gnuplot with \"load './[FILENAME].instbw.data.difference_plot'\", to refresh use 'load' again";	tput sgr0
				echo -e '\E[37m' " The difference is calculated with |last estimate - actual estimate| in percent (based on last estimate).";	tput sgr0
				echo " "
				echo -e '\E[37m' " Example: ";	tput sgr0
				echo -e '\E[37m' "   Last_Estimate (100mbps), Actual_Estimate (90mbps)";	tput sgr0
				echo -e '\E[37m' "   => |100mbps - 90mbps| => |-10mbps| => 10mbps";	tput sgr0
				echo -e '\E[37m' "   => 10mbps/100mbps * 100 = 0.10 * 100 = 10%";	tput sgr0
				echo " "
				echo -e '\E[37m' " For more information use	\"./HelperAssolo.sh Info Instbw\"";	tput sgr0
				echo -e '\E[37m' " For an example use		\"./HelperAssolo.sh Info Plot Difference\"";tput sgr0
				echo " "
				echo " "
				echo -e '\E[1;37m' "-------------------------------------";			tput sgr0
				echo -e '\E[1;37m' "- Summary Bandwidth Estimation Plot -";			tput sgr0
				echo -e '\E[1;37m' "-------------------------------------";			tput sgr0
				echo -en '\E[1;37m' " x-Axis :";						tput sgr0
				echo -e  '\E[37m' "Bandwidth in mbps";						tput sgr0
				echo -en '\E[1;37m' " y-Axis :";						tput sgr0
				echo -e  '\E[37m' "Test number";						tput sgr0
				echo -en '\E[1;37m' " Line   :";						tput sgr0
				echo -e  '\E[37m' "Last Bandwidth estimation in mbps of each single Test";	tput sgr0
				echo " "
				echo -e '\E[37m' " For an example use		\"./HelperAssolo.sh Info Plot SBE\"";	tput sgr0
				echo " "
			esac
		;;
		Stats|stats)
			echo -e '\E[1;37m' "--------------";			tput sgr0
			echo -e '\E[1;37m' "- Statistics -";			tput sgr0
			echo -e '\E[1;37m' "--------------";			tput sgr0
			echo -e '\E[37m'   "The calculated statistics depend on two files (*.instbw.data/*.debug.data).";			tput sgr0
			echo -e '\E[37m'   "If one of the two is not presented then there will be a notice in the files.";			tput sgr0
			echo -e '\E[37m'   " ";													tput sgr0
			echo -e '\E[1;37m' "Remarks:";												tput sgr0
			echo -e '\E[37m'   "- Packets_per_Chirp should not change, if it has changed the will be a warning.";			tput sgr0
			echo -e '\E[37m'   "- Failed_Estimates need \"Smoothing over Estimates\" with a value of 11 (hardcoded in c++).";	tput sgr0
			echo -e '\E[37m'   "- Failed_Estimates is not 100% tested.";tput sgr0
			echo -e '\E[37m'   "- If Packet_Count != (Chirp_Count * Packets_per_Chirp), then the will be a warning with the count of missing packets.";tput sgr0
			echo -e '\E[37m'   "- Each name is unique in the file like \"Sum_of_Estimates\", so its possible to grep the values easly (summary.stats).";tput sgr0
			echo " "
			echo -e '\E[1;37m' "Example File:";															tput sgr0
			echo -e  '\E[37m' " 10_10_1298049208"; 	tput sgr0
			echo -e  '\E[37m' " -------------------------------------"; 	tput sgr0
			echo -e  '\E[37m' " Input InstbwFile         10_10_1298049208.instbw.data"; 	tput sgr0
			echo -e  '\E[37m' " Input DebugFile          10_10_1298049208.debug.data"; 	tput sgr0
			echo -e  '\E[37m' " Output File              10_10_1298049208.stats"; 	tput sgr0
			echo -e  '\E[37m' " "; 	tput sgr0
			echo -e  '\E[37m' " INSTBW"; 	tput sgr0
 			echo -e  '\E[37m' "  Sum_of_Estimates       5300.590000 MBit/s"; 	tput sgr0
 			echo -e  '\E[37m' "  Sum_of_Dif_Estimates   13.325000 MBit/s        => 0.251387%"; 	tput sgr0
 			echo -e  '\E[37m' "  Count_of_Estimates     615 Chirp(s)"; 	tput sgr0
 			echo -e  '\E[37m' "  Time_of_Experiment     883.780850 seconds"; 	tput sgr0
 			echo -e  '\E[37m' "  Estimates_per_second   1.437042"; 	tput sgr0
			echo -e  '\E[37m' " "; 	tput sgr0
 			echo -e  '\E[37m' "  Minimum_Estimate       8.408000 MBit/s @Time   193.695880 seconds"; 	tput sgr0
 			echo -e  '\E[37m' "  Average_Estimate       8.604854 MBit/s"; 	tput sgr0
 			echo -e  '\E[37m' "  Maximum_Estimate       8.683000 MBit/s @Time   326.332600 seconds"; 	tput sgr0
			echo -e  '\E[37m' " "; 	tput sgr0
 			echo -e  '\E[37m' "  Minimum_Dif_Estimate   0.000000 MBit/s 0.000000%       @Time   1.754520 seconds"; 	tput sgr0
 			echo -e  '\E[37m' "  Average_Dif_Estimate   0.021631 MBit/s"; 	tput sgr0
 			echo -e  '\E[37m' "  Maximum_Dif_Estimate   0.179000 MBit/s 2.105139%       @Time   204.194160 seconds"; 	tput sgr0
			echo -e  '\E[37m' " "; 	tput sgr0
			echo -e  '\E[37m' " DEBUG"; 	tput sgr0
 			echo -e  '\E[37m' "  Packet_Count           11286 Packet(s)"; 	tput sgr0
 			echo -e  '\E[37m' "  Chirp_Count            627 Chirp(s)"; 	tput sgr0
 			echo -e  '\E[37m' "  Packets_per_Chirp      18 Packet(s)"; 	tput sgr0
			echo -e  '\E[37m' " "; 	tput sgr0
 			echo -e  '\E[37m' "  Inter_Chirp_Time       (S)~ 1.419171s  (R)~ 1.417812s  (abs Dif)~ 0.001359s    (last measured values)"; 	tput sgr0
 			echo -e  '\E[37m' "  Lenght_of_Chirp        (S)~ 0.018520s  (R)~ 0.019891s  (abs Dif)~ 0.001371s    (last measured values)"; 	tput sgr0
 			echo -e  '\E[37m' "  Sum_LoC_ICT            (S)~ 1.437691s  (R)~ 1.437703s  (abs Dif)~ 0.000012s"; 	tput sgr0
			echo -e  '\E[37m' " "; 	tput sgr0
 			echo -e  '\E[37m' "  Time_of_Exp (S)        899.976912 seconds"; 	tput sgr0
 			echo -e  '\E[37m' "  Time_of_Exp (R)        899.985407 seconds"; 	tput sgr0
 			echo -e  '\E[37m' "  Absolute_Difference    0.008495 seconds"; 	tput sgr0
			echo -e  '\E[37m' " "; 	tput sgr0
			echo -e  '\E[37m' " INSTBW + DEBUG (ToDo)"; 	tput sgr0
 			echo -e  '\E[37m' "  Failed Estimates       1 Chirp(s) => 0%         (Smoothing over Estimates = 11, ? 1 Chirp extra ?)"; 	tput sgr0
			echo -e  '\E[37m' " -------------------------------------"; 	tput sgr0
			echo " "
		;;
		*)
			echo -e '\E[1;37m' "------------------------------------";	tput sgr0
			echo -e '\E[1;37m' "- HelperAssolo Script Version "$Version" -";	tput sgr0
			echo -e '\E[1;37m' "------------------------------------";	tput sgr0
			echo -en '\E[1;31m' "Syntax: HelperAssolo.sh";	tput sgr0
			echo -en '\E[1;35m' "Info";  			tput sgr0	
			echo -e  '\E[32m'   "SUBCOMMAND";		tput sgr0
			echo " "
			echo -n " "; echo -en '\E[32m' "Instbw";	tput sgr0;	echo "	*.instbw(.data) File Format"
			echo -n " "; echo -en '\E[32m' "Debug";	 	tput sgr0;	echo "		*.debug(.data) File Format"
			echo -n " "; echo -en '\E[32m' "Plot";  	tput sgr0;	echo "		Debug and Instbw plot Files"
			echo -n " "; echo -en '\E[32m' "Stats"; 	tput sgr0;	echo "		How are the statistics calculated"
			echo " "
	esac
	;;
############################################################################################################################



############################################################################################################################
AnalyzeAll|Analyzeall|analyzeall)	# Syntax: AnaylzeAll ExperimentData_Directory 

	# Check ParameterCount
	if [ -z $2 ] ; then
		$0 Help AnalyzeAll
		exit
	elif [ $3 ] ; then
		$0 Help AnalyzeAll
		exit
	fi

	# Remember Values
    date=`date "+%Y-%m-%d_%T"`
    Exp_Dir=$2
	Calling_Dir=`pwd`	
	
	# Get HelperAssolo_Location 
	if [ "$0" == "./HelperAssolo.sh" ] ; then
		HelperAssolo_Dir=$Calling_Dir		# HelperAssolo.sh has been called from here (pwd)
	else
		echo "Please execute the script in folder where it is located."
		exit
	fi

	# Guess Locations	
	Location_Debugizer=$HelperAssolo_Dir"/C-Code/Debugizer"
	Location_Instbwizer=$HelperAssolo_Dir"/C-Code/Instbwizer"
	Location_Statsizer=$HelperAssolo_Dir"/C-Code/Statsizer"

	clear
	echo " "
	echo -en '\E[1;31m' "HelperAssolo.sh";tput sgr0;echo -en '\E[1;33m' "AnalyzeAll ";tput sgr0; echo $Exp_Dir
	echo " @ "$date
	echo " "
	echo -e '\E[1;37m' "Checking if all tools are present:";tput sgr0

	echo -n " - Debugizer ..."
	if [ -f $Location_Debugizer ] ; then
		echo " present"
	else
		echo $Location_Debugizer
		echo -e '\E[1;31m' "not present";tput sgr0
		echo " "
		echo " Please move the Debugizer binary into the folder of HelperAssolo.sh"
		echo " You may have to compile the C++ file which should be located in \"C-Code/Debugizer.cpp\""
		echo " "
		echo " cd [HelperAssolo.sh DIRECTORY]"
		echo " g++ -Wall C-Code/Debugizer.cpp -o Debugizer"
		echo " "

		exit
	fi

	echo -n " - Instbwizer ..."
	if [ -f $Location_Instbwizer ] ; then
		echo " present"
	else
		echo -e '\E[1;31m' "not present";tput sgr0
		echo " "
		echo " Please move the Debugizer binary into the folder of HelperAssolo.sh"
		echo " You may have to compile the C++ file which should be located in \"C-Code/Instbwizer.cpp\""
		echo " "
		echo " cd [HelperAssolo.sh DIRECTORY]"
		echo " g++ -Wall C-Code/Instbwizer.cpp -o Instbwizer"
		echo " "

		exit
	fi

	echo -n " - Statsizer ..."
	if [ -f $Location_Statsizer ] ; then
		echo " present"
	else
		echo -e '\E[1;31m' "not present";tput sgr0
		echo " "
		echo " Please move the Debugizer binary into the folder of HelperAssolo.sh"
		echo " You may have to compile the C++ file which should be located in \"C-Code/Statsizer.cpp\""
		echo " "
		echo " cd [HelperAssolo.sh DIRECTORY]"
		echo " g++ -Wall C-Code/Statsizer.cpp -o Statsizer"
		echo " "

		exit
	fi

	echo " "
	echo -e '\E[1;37m' "Creating new Subfolder and store the Data";tput sgr0
	echo -n " - mkdir ";echo -e '\E[35m' $Exp_Dir$date;tput sgr0
	mkdir $Exp_Dir$date

	# be sure files are not present
	rm tmp1.tmp > /dev/null 2>&1
	rm tmp2.tmp > /dev/null 2>&1

	echo -n " - mv	 ";echo -en '\E[35m' $Exp_Dir"*.instbw	";tput sgr0;echo -e '\E[32m' $Exp_Dir$date"/";tput sgr0
	cd $Exp_Dir
	mv *.instbw $date"/" > $Calling_Dir"/"tmp1.tmp 2>&1
	cd $Calling_Dir

	echo -n " - mv	 ";echo -en '\E[35m' $Exp_Dir"*.debug	";tput sgr0;echo -e '\E[32m' $Exp_Dir$date"/";tput sgr0
	cd $Exp_Dir
	mv *.debug $date"/" > $Calling_Dir"/"tmp2.tmp 2>&1
	cd $Calling_Dir
	echo " "


	# Check if move was successfull
	if [ -s tmp2.tmp ] ; then
		
		# No Debug Files are present
		if [ -s tmp1.tmp ] ; then
			# No Instbw Files are present
			echo -e '\E[1;31m' "No Debug-/Instbw-files where found in";tput sgr0
			echo -e '\E[35m' "  " $Exp_Dir;tput sgr0
			echo " "
			echo " Since there is no work to do ... exit"
			echo " "
			rm -rf $Exp_Dir$date

			rm tmp1.tmp > /dev/null 2>&1
			rm tmp2.tmp > /dev/null 2>&1

			exit
		else
			# Only Instbw present - skip debug part
			echo -e '\E[1;33m' "No Debug-files where found in";tput sgr0
			echo -e '\E[35m' "  " $Exp_Dir;tput sgr0
			echo " "
			echo " Skipping Debug Part"
			$0 Combine_instbw $Exp_Dir$date"/"
			$0 Calculate_experiment $Exp_Dir$date"/" $Location_Instbwizer
			$0 Calculate_stats $Exp_Dir$date"/" $Location_Statsizer
			$0 Generate_plot $Exp_Dir$date"/"
			$0 Generate_estimate_difference_plot $Exp_Dir$date"/"
		fi

		
	elif [ -s tmp1.tmp ] ; then
		# No Instbw Files are present
		echo -e '\E[1;31m' "No Instbw-files where found in";tput sgr0
		echo -e '\E[35m' "  " $Exp_Dir;tput sgr0
		echo " "
		echo " Since there is no work to do ... exit"
		echo " "

		rm tmp1.tmp > /dev/null 2>&1
		rm tmp2.tmp > /dev/null 2>&1

		exit
	else
		# Instbw and Debug Files are present
		$0 Combine_instbw $Exp_Dir$date"/"
		$0 Calculate_experiment $Exp_Dir$date"/" $Location_Instbwizer
		$0 Calculate_debug $Exp_Dir$date"/" $Location_Debugizer
		$0 Calculate_stats $Exp_Dir$date"/" $Location_Statsizer
		$0 Generate_plot $Exp_Dir$date"/"
		$0 Generate_plot_debug $Exp_Dir$date"/"
		$0 Generate_estimate_difference_plot $Exp_Dir$date"/"
	fi

	rm tmp1.tmp > /dev/null 2>&1
	rm tmp2.tmp > /dev/null 2>&1

	;;
############################################################################################################################



############################################################################################################################
Calculate_experiment|calculate_experiment)		# Calculate_experiment ExperimentData_Directory Instbwizer_Binary_Location

	# Check ParameterCount
	if [ -z $2 ] ; then
		$0 Help Calculate_experiment
		exit
	elif [ -z $3 ] ; then
		$0 Help Calculate_experiment
		exit
	elif [ $4 ] ; then
		$0 Help Calculate_experiment
		exit
	fi
	
	Calling_Dir=$(pwd)
	
	# Prepare files for Plotting
	#################################
	echo " "
	echo -en '\E[1;33m' " Calculate_experiment ( ";tput sgr0; echo -n $2; echo -e '\E[1;33m' ")";tput sgr0

	files_in_directory=`ls $2 | grep .instbw$`
	
	# Check if needed files are present
	if [ "" == "$files_in_directory" ] ; then
		echo -e  '\E[1;31m' "  - Couldn't find any *.instbw files !";tput sgr0
		echo ""
		exit;
	fi
	
	for single_file in $files_in_directory
    do
        #########################################################
        # Check if File is not zero
    	if [ -s $2$single_file ] ; then
	    	
	        echo "  - $single_file"
	        
	        # Sort Assolo output with time as key 
	        sort $2$single_file > $2$single_file.tmp
	        
	        # Find Minimum time to normalize timevalues
	    	minimum=`awk 'min=="" || $1 < min {min=$1} END{ print min}' FS=" " $2$single_file.tmp`
	    	
	    	
	    	# Start of an extern Program (C++)
	    	# Instbwrizer  FILE   TIMESTAMP_MINIMUM
			$3 $2$single_file.tmp $minimum


		   	# cleanup and copy
			rm -f $2$single_file.tmp
			mv $2$single_file.tmp.data $2$single_file.data
			 
		else
			echo "  - $single_file - SKIPPED Size is ZERO"
		fi
		#########################################################        
   	 done
	
	echo " "

	cd $Calling_Dir
	;;
############################################################################################################################



############################################################################################################################
Calculate_debug|calculate_debug)			#calculate_debug ExperimentData_Directory Debugizer_Binary_Location

	# Check ParameterCount
	if [ -z $2 ] ; then
		$0 Help Calculate_debug
		exit
	elif [ -z $3 ] ; then
		$0 Help Calculate_debug
		exit
	elif [ $4 ] ; then
		$0 Help Calculate_debug
		exit
	fi
	
	Calling_Dir=$(pwd)

	# Prepare files for Plotting
	#################################
	echo " "
	echo -en '\E[1;33m' " Calculate_debug ( ";tput sgr0; echo -n $2; echo -e '\E[1;33m' ")";tput sgr0

	files_in_directory=`ls $2 | grep .debug$`
	
	# Check if needed files are present
	if [ "" == "$files_in_directory" ] ; then
		echo -e  '\E[1;31m' "  - Couldn't find any *.debug files !";tput sgr0
		echo ""
		exit;
	fi
	
	for single_file in $files_in_directory
   	do
        #########################################################
	 	# Check if File is not zero
    	if [ -s $2$single_file ] ; then
			echo "  - $single_file"
	        
	        # Find Minimum time to normalize timevalues
	    	minimum_snd=`awk 'min=="" || $3 < min {min=$3} END{ print min}' FS=" " $2$single_file`
	    	minimum_rcv=`awk 'min=="" || $4 < min {min=$4} END{ print min}' FS=" " $2$single_file`
	    	    
	    	# Start of an extern Program (C++)
	    	# ./Debugizer   FILE   TIMESTAMP_MINIMUM_SENDER   TIMESTAMP_MINIMUM_RECEIVER
			$3 $2$single_file $minimum_snd $minimum_rcv
					
		else
			echo "  - $single_file - SKIPPED Size is ZERO"
		fi
		#########################################################        
   	done

	echo " "
	
	cd $Calling_Dir
	;;
############################################################################################################################



############################################################################################################################
Calculate_stats|calculate_stats)		#Syntax: HelperAssolo.sh Calculate_stats ExperimentData_Directory Statsizer_Binary_Location

	# Check ParameterCount
	if [ -z $2 ] ; then
		$0 Help Calculate_stats
		exit
	elif [ -z $3 ] ; then
		$0 Help Calculate_stats
		exit
	elif [ $4 ] ; then
		$0 Help Calculate_stats
		exit
	fi

	Calling_Dir=$(pwd)
	
	echo " "
	echo -en '\E[1;33m' " Calculate_stats ( ";tput sgr0; echo -n $2; echo -e '\E[1;33m' ")";tput sgr0
	
	cd $2
	files_in_directory=$(ls | grep .instbw.data$)
	
	# Check if needed files are present
	if [ "" == "$files_in_directory" ] ; then
		echo -e  '\E[1;31m' "  - Couldn't find any *.instbw.data files !";tput sgr0
		echo ""
		exit;
	fi
	
	# Be sure the File is empty
	rm -f summary.stats
	touch summary.stats
		
	i=0
	for single_file in $files_in_directory
    	do
			# Check if File is not zero
			if [ -s $single_file ] ; then
				echo -n "  - "
				echo $single_file | awk '{print substr($1, 0, index($1,".instbw.data")-1 )}'
				$3 $(echo $single_file | awk '{print substr($1, 0, index($1,".instbw.data")-1 )}')
				
				# Exclude summary_combined.instbw.data from summary.stats
				if [ ! "$single_file" == "summary_combined.instbw.data" ] ; then
					cat $(echo $single_file | awk '{print substr($1, 0, index($1,".instbw.data")-1 )}').stats >> summary.stats
				fi
			else
				echo "  - $single_file - SKIPPED Size is ZERO"
			fi
			
			i=`expr $i + 1`
	done
	echo " "
	
	cd $Calling_Dir
	;;
############################################################################################################################


	
############################################################################################################################
Generate_estimate_difference_plot|generate_estimate_difference_plot)			# Syntax: HelperAssolo.sh Generate_estimate_difference_plot ExperimentData_Directory

	# Check ParameterCount
	if [ -z $2 ] ; then
		$0 Help Generate_estimate_difference_plot
		#exit
	elif [ $3 ] ; then
		$0 Help Generate_estimate_difference_plot
		#exit
	fi
	
	Calling_Dir=$(pwd)
		 
	# Generate FILE.plot ($2) for GnuPlot
	######################################
	echo " "
	echo -en '\E[1;33m' " Generate_estimate_difference_plot ( ";tput sgr0; echo -n $2; echo -e '\E[1;33m' ")";tput sgr0
	
	cd $2
	
	files_in_directory=$(ls | grep .instbw.data$)
	plot_file_location=summary_difference.plot
	
	# Check if needed files are present
	if [ "" == "$files_in_directory" ] ; then
		echo -e  '\E[1;31m' "  - Couldn't find any *.instbw.data files !";tput sgr0
		echo ""
		exit;
	fi
		
	# Be sure the File is empty
	rm -f $plot_file_location
	touch $plot_file_location
	
	# Print into plotfile
	echo "set title \"$2\" " >> $plot_file_location
	echo "set xlabel \"Time (s)\"" >> $plot_file_location
	echo "set ylabel  \"Bandwith Difference to Last Estimate (%)\"" >> $plot_file_location
	
	echo -n "plot" >> $plot_file_location
	i=0
	 
	for single_file in $files_in_directory
    do
		
		# Check if File is not zero
		if [ -s $single_file ] ; then
		
			echo "  - $single_file"
			
			# Be sure the File is empty
			plot_file_location_2=$single_file".difference_plot"
			rm -f $plot_file_location_2
			touch $plot_file_location_2
			
			echo "set size 1.0,1.0" >> $plot_file_location_2
			echo "set origin 0.0,0.0" >> $plot_file_location_2
			echo "set multiplot" >> $plot_file_location_2
			echo "	set size 1.0,0.6" >> $plot_file_location_2
			echo "	set origin 0.0,0.0" >> $plot_file_location_2
			echo "	set title '|Last Estimate - Actual Estimate|'" >> $plot_file_location_2
			echo "	set xlabel 'Time (s)'" >> $plot_file_location_2
			echo "	set ylabel 'Bandwidth Difference (%)'" >> $plot_file_location_2
			
				echo "plot './"$single_file"' using 1:5 w fsteps notitle lt 1" >> $plot_file_location_2
				
			echo "	set size 1.0,0.4" >> $plot_file_location_2
			echo "	set origin 0.0,0.6" >> $plot_file_location_2
			echo "	set title 'Bandwidth Estimation'" >> $plot_file_location_2
			echo "	set ylabel 'Bandwith (mbps)'" >> $plot_file_location_2
				
				echo "plot './"$single_file"' using 1:2 w l notitle lt 3 lw 2" >> $plot_file_location_2
				
			echo "unset multiplot" >> $plot_file_location_2
		
			# Exclude summary_combined.instbw file
			if [ ! "$single_file" == "summary_combined.instbw.data" ] ; then			
				if [ $i -gt 0 ] ; then
					echo -n "," >> $plot_file_location
				fi
			
				echo -n " '$single_file'  using 1:5 title \"$single_file\" w l lt $i " >>  $plot_file_location
			fi
					
			i=`expr $i + 1`
			
		else
			echo "  - $single_file - SKIPPED Size is ZERO"
		fi
	done
	
	echo " " >> $plot_file_location
	echo " "
	
	cd $Calling_Dir
	;;
############################################################################################################################



############################################################################################################################
Generate_plot|generate_plot)			# Syntax: HelperAssolo.sh Generate_plot ExperimentData_Directory

	# Check ParameterCount
	if [ -z $2 ] ; then
		$0 Help Generate_plot
		exit
	elif [ $3 ] ; then
		$0 Help Generate_plot
		exit
	fi
	
	Calling_Dir=$(pwd)
		 
	# Generate FILE.plot ($2) for GnuPlot
	######################################
	echo " "
	echo -en '\E[1;33m' " Generate_plot ( ";tput sgr0; echo -n $2; echo -e '\E[1;33m' ")";tput sgr0
	
	cd $2
	
	files_in_directory=$(ls | grep .instbw.data$)
	plot_file_location=summary_instbw.plot
	
	# Check if needed files are present
	if [ "" == "$files_in_directory" ] ; then
		echo -e  '\E[1;31m' "  - Couldn't find any *.instbw.data files !";tput sgr0
		echo ""
		exit;
	fi
		
	# Be sure the File is empty
	rm -f $plot_file_location
	touch $plot_file_location
	
	# Print into plotfile
	echo "set title \"$2\" " >> $plot_file_location
	echo "set xlabel \"Time (s)\"" >> $plot_file_location
	echo "set ylabel  \"Bandwith (Mbps)\"" >> $plot_file_location
	
	
	echo -n "plot " >> $plot_file_location
	i=0
	 
	for single_file in $files_in_directory
    do
	
		# Check if File is not zero
		if [ -s $single_file ] ; then
		
			echo "  - $single_file"
			
			# Be sure the File is empty
			plot_file_location_2=$single_file".plot"
			rm -f $plot_file_location_2
			touch $plot_file_location_2
			
			echo "set title \"$single_file\" " >> $plot_file_location_2
			echo "set xlabel \"Time (s)\"" >> $plot_file_location_2
			echo "set ylabel  \"Bandwith (Mbps)\"" >> $plot_file_location_2
			
			
			echo -n " plot '$single_file' using 1:2 title \"$single_file\" w points lt $i" >>  $plot_file_location_2
			echo    ", '$single_file' using 1:3 title \"$single_file (avg 5 samples)\" w lines lt $i" >>  $plot_file_location_2


			# Exclude summary_combined.instbw file
			if [ ! "$single_file" == "summary_combined.instbw.data" ] ; then				
				if [ $i -gt 0 ] ; then
					echo -n ", " >> $plot_file_location
				fi
				
				echo -n " '$single_file'  using 1:2 notitle w dots lt $i" >>  $plot_file_location
				echo -n ", '$single_file' using 1:3 title \"$single_file\" w lines lt $i" >>  $plot_file_location
			else
				i=`expr $i - 1`		# dont countß i up for summary_combined.instbw file
			fi
			
			i=`expr $i + 1`
		else
			echo "  - $single_file - SKIPPED Size is ZERO"
		fi
	done
	
	echo " " >> $plot_file_location
	echo " "
	
	cd $Calling_Dir
	;;
############################################################################################################################


############################################################################################################################
Generate_plot_debug|generate_plot_debug)			# Syntax: HelperAssolo.sh Generate_plot_debug ExperimentData_Directory

	# Check ParameterCount
	if [ -z $2 ] ; then
		$0 Help Generate_plot_debug
		exit
	elif [ $3 ] ; then
		$0 Help Generate_plot_debug
		exit
	fi
 
	Calling_Dir=$(pwd)
 
	# Generate FILE.plot ($2) for GnuPlot
	######################################
	echo " "
	echo -en '\E[1;33m' " Generate_plot_debug ( ";tput sgr0; echo -n $2; echo -e '\E[1;33m' ")";tput sgr0
	
	cd $2
	files_in_directory=`ls | grep .debug.data$`
	
	# Check if needed files are present
	if [ "" == "$files_in_directory" ] ; then
		echo -e  '\E[1;31m' "  - Couldn't find any *.debug.data files !";tput sgr0
		echo ""
		exit;
	fi

	for single_file in $files_in_directory
    	do
    	# Check if File is not zero
    	if [ -s $2$single_file ] ; then
    	
	    	echo "  - $single_file"
	    	
	    	plot_file_location=$single_file".plot"
	    	
	    	# Be sure the File is empty
			rm -f $plot_file_location
			touch $plot_file_location
	    	
	    	# Print into plotfile
	    	echo "set title \"$single_file\" " >> $plot_file_location
			echo "set xlabel \"Time\"" >> $plot_file_location
			echo "set ylabel \"Packet\"" >> $plot_file_location
			echo " " >> $plot_file_location
			echo "set style line 1 lt 2 lw 0.5 linecolor rgb \"black\"" >> $plot_file_location
			echo "set style line 2 lt 2 lw 0.5 linecolor rgb \"gray\"" >> $plot_file_location
			echo "set style line 3 lt 1 lw 1   linecolor rgb \"green\"" >> $plot_file_location
			echo "set style line 4 lt 1 lw 1   linecolor rgb \"orange\"" >> $plot_file_location
			echo "set style line 5 lt 1 lw 1   linecolor rgb \"red\"" >> $plot_file_location
			echo "set style line 6 lt 1 lw 1   linecolor rgb \"blue\"" >> $plot_file_location
			echo " " >> $plot_file_location
			echo -n "plot \""$single_file"\" using 4:1 title 'Packet send' w l ls 1" >>  $plot_file_location
			echo -n ", \""$single_file"\" using 5:1 title 'Packet received' w l ls 2" >>  $plot_file_location
			echo -n ", \""$single_file"\" using 4:1:8 title 'Delay caused by Network (Sender)' w xerrorbars ls 5" >>  $plot_file_location
			echo -n ", \""$single_file"\" using 5:1:8 title 'Delay caused by Network (Receiver)' w xerrorbars ls 6" >>  $plot_file_location
			echo " " >> $plot_file_location
				
		else
			echo "  - $single_file - SKIPPED Size is ZERO"
		fi
	done

	echo " "
	
	cd $Calling_Dir
	;;
############################################################################################################################




############################################################################################################################
Combine_instbw|combine_instbw)			# Syntax: HelperAssolo.sh Combine_instbw ExperimentData_Directory

	# Check ParameterCount
	if [ -z $2 ] ; then
		$0 Help Combine_instbw
		exit
	elif [ $3 ] ; then
		$0 Help Combine_instbw
		exit
	fi
	
	Calling_Dir=$(pwd)
		 
	# Generate a File which contains all single instbw datapoint in one file ($2) for GnuPlot
	######################################
	echo " "
	echo -en '\E[1;33m' " Combine_instbw ( ";tput sgr0; echo -n $2; echo -e '\E[1;33m' ")";tput sgr0
	
	cd $2
	
	files_in_directory=`ls | grep .instbw$`
	summary_file_location=summary_combined.instbw
	
	# Check if needed files are present
	if [ "" == "$files_in_directory" ] ; then
		echo -e  '\E[1;31m' "  - Couldn't find any *.instbw files !";tput sgr0
		echo ""
		exit;
	fi
		
	# Be sure the File is empty
	rm -f  $summary_file_location
		
	i=0
	 
	for single_file in $files_in_directory
		do
			# Exclude summary_combined.instbw file
			if [ ! "$single_file" == "summary_combined.instbw" ] ; then
				# Check if File is not zero
				if [ -s $single_file ] ; then
				
					echo "  - $single_file"
					
					cat $single_file >> $summary_file_location
							
					i=`expr $i + 1`
					
				else
					echo "  - $single_file - SKIPPED Size is ZERO"
				fi
			fi
	done
	
	# sort the file according to timestamps
	sort $summary_file_location > $summary_file_location.tmp
	mv $summary_file_location.tmp $summary_file_location
	
	echo " "
	
	
	cd $Calling_Dir
	;;
############################################################################################################################



############################################################################################################################
Gnuplot_folder|gnuplot_folder)				# Syntax: HelperAssolo.sh Gnuplot_folder folder_to_plot plot_file_filter(instbw, debug, all)

	# Check ParameterCount
	if [ -z $2 ] ; then
		$0 Help Gnuplot_folder
		exit
	elif [ -z $3 ] ; then
		$0 Help Gnuplot_folder
		exit
	fi

	Calling_Dir=$(pwd)
	
	echo " "
	echo -en '\E[1;33m' " Gnuplot_folder ( ";tput sgr0; echo -n $2; echo -e '\E[1;33m' ")";tput sgr0
		
	cd $2
	
	if [ $3 == "instbw" ] ; then
		files_in_directory=`ls | grep .instbw.data.plot$`
				
		# Check if needed files are present
		if [ "" == "$files_in_directory" ] ; then
			echo -e  '\E[1;31m' "  - Couldn't find any *.instbw.data.plot files !";tput sgr0
			echo ""
			exit;
		fi
	elif [ $3 == "debug" ] ; then
		files_in_directory=`ls | grep .debug.data.plot$`
		
		# Check if needed files are present
		if [ "" == "$files_in_directory" ] ; then
			echo -e  '\E[1;31m' "  - Couldn't find any *.debug.data.plot files !";tput sgr0
			echo ""
			exit;
		fi
	elif [ $3 == "all" ] ; then
		files_in_directory=`ls | grep .data.plot$`
		
		# Check if needed files are present
		if [ "" == "$files_in_directory" ] ; then
			echo -e  '\E[1;31m' "  - Couldn't find any *.data.plot files !";tput sgr0
			echo ""
			exit;
		fi
	else
		echo " "
		echo "  Please select a correct filter (instbw, debug, all)"
		echo "  You entered: \""$3"\""
		echo " "
	
		exit
	fi
					    						
	for single_file in $files_in_directory
	do
		echo "  - "$single_file
		gnuplot -persist $single_file 
	done	
	
	echo " "
	
	cd $Calling_Dir
	;;
############################################################################################################################



############################################################################################################################
Generate_summary_bandwidth_estimation|generate_summary_bandwidth_estimation)		#Syntax: HelperAssolo.sh Generate_summary_bandwidth_estimation ExperimentData_Directory

	# Check ParameterCount
	if [ -z $2 ] ; then
		$0 Help Generate_summary_bandwidth_estimation
		exit
	elif [ $3 ] ; then
		$0 Help Generate_summary_bandwidth_estimation
		exit
	fi

	Calling_Dir=$(pwd)

	echo " "
	echo -en '\E[1;33m' " Generate_summary_bandwidth_estimation ( ";tput sgr0; echo -n $2; echo -e '\E[1;33m' ")";tput sgr0
	
	cd $2
	
	files_in_directory=$(ls | grep .instbw.data$)
	
	# Check if needed files are present
	if [ "" == "$files_in_directory" ] ; then
		echo -e  '\E[1;31m' "  - Couldn't find any *.instbw.data files !";tput sgr0
		echo ""
		exit;
	fi
	
	# Be sure the File is empty
	rm -f summary_bandwidthestimation.tmp
	touch summary_bandwidthestimation.tmp

	i=0
	for single_file in $files_in_directory
    do
    	# Exclude summary_combined.instbw file
		if [ ! "$(echo $single_file)" == "summary_combined.instbw.data" ] ; then
		
			# Check if File is not zero
			if [ -s $single_file ] ; then
				echo "  - "$single_file
				cat $single_file | tail -1 | awk '{print $2}' >> summary_bandwidthestimation.tmp
			else
				echo "  - $single_file - SKIPPED Size is ZERO"
				echo "0.0" >> summary_bandwidthestimation.tmp
			fi
			
			i=`expr $i + 1`
		fi
	done

	nl summary_bandwidthestimation.tmp > summary_bandwidthestimation.data
    rm -f summary_bandwidthestimation.tmp
    
   	 # Be sure the File is empty	
	rm -f summary_bandwidthestimation.plot
	touch summary_bandwidthestimation.plot
	
	echo "set title \"Summary Bandwidth Estimation (Last Estimation of each Test)\" " >> summary_bandwidthestimation.plot
	echo "set xlabel \"Testnumber\"" >> summary_bandwidthestimation.plot
	echo "set ylabel \"Estimated Bandwidth (MBit/s)\"" >> summary_bandwidthestimation.plot
	echo " " >> summary_bandwidthestimation.plot
	echo "plot \"summary_bandwidthestimation.data\" w linespoints" >> summary_bandwidthestimation.plot
	
	cd $Calling_Dir
	;;
############################################################################################################################



############################################################################################################################
*) 
	clear
	echo -e '\E[1;37m' "------------------------------------";	tput sgr0
	echo -e '\E[1;37m' "- HelperAssolo Script Version "$Version" -";	tput sgr0
	echo -e '\E[1;37m' "------------------------------------";	tput sgr0
	echo -en '\E[1;31m' "Syntax: HelperAssolo.sh"	# Pretty Coloring =)
	echo -e  '\E[1;33m' "COMMAND";	tput sgr0	# Last Command reset the color
	echo -en '\E[1;31m' "        HelperAssolo.sh"
	echo -en '\E[1;35m' "Help";  	tput sgr0	
	echo -e  '\E[1;33m' "COMMAND";	tput sgr0	
	echo " "
	echo -e '\E[1;34m' "   Main Function";			tput sgr0
	echo -n "    -"; echo -e '\E[1;33m' "AnalyzeAll";	tput sgr0
	echo " "
	echo -e '\E[1;34m' "   SingleStep Functions";		tput sgr0
	echo -n "    -"; echo -en '\E[1;33m' "Calculate_experiment";			tput sgr0;	echo "			ExperimentData_Directory	Instbwizer_Binary_Location"
	echo -n "    -"; echo -en '\E[1;33m' "Calculate_debug";				tput sgr0;	echo "				ExperimentData_Directory 	Debugizer_Binary_Location"
	echo -n "    -"; echo -en '\E[1;33m' "Calculate_stats";				tput sgr0;	echo "				ExperimentData_Directory 	Statsizer_Binary_Location"
	echo -n "    -"; echo -en '\E[1;33m' "Generate_estimate_difference_plot";	tput sgr0;	echo "		ExperimentData_Directory "
	echo -n "    -"; echo -en '\E[1;33m' "Generate_plot";				tput sgr0;	echo "				ExperimentData_Directory "
	echo -n "    -"; echo -en '\E[1;33m' "Generate_plot_debug";				tput sgr0;	echo "			ExperimentData_Directory "
	
	
	echo " "
	echo -e '\E[1;34m' "   Helper Functions";		tput sgr0
	echo -n "    -"; echo -en '\E[1;33m' "Combine_instbw";				tput sgr0;	echo "				Instbw_Files_Folder"
	echo -n "    -"; echo -en '\E[1;33m' "Generate_summary_bandwidth_estimation";	tput sgr0;	echo "	ExperimentData_Directory 	(read Help before using)"
	echo -n "    -"; echo -en '\E[1;33m' "Gnuplot_folder";				tput sgr0;	echo "				Files_to_plot			Files_to_plot_filter(instbw, debug,all)"
	

	echo " "
	echo -e '\E[1;34m' "   Information";		tput sgr0
	echo -n "    -"; echo -en '\E[1;35m' "Info";tput sgr0;	 echo -e '\E[32m' "	SUBCOMMAND";tput sgr0
	echo -n "                -"; echo -en '\E[32m' "Instbw";tput sgr0;	echo "	*.instbw(.data) File Format"
	echo -n "                -"; echo -en '\E[32m' "Debug";tput sgr0;	echo "		*.debug(.data) File Format"
	echo -n "                -"; echo -en '\E[32m' "Plot";tput sgr0;	echo "		Debug and Instbw plot Files"
	echo -n "                -"; echo -en '\E[32m' "Stats";tput sgr0;	echo "		How are the statistics calculated"
	echo " "
esac 

