#!/bin/bash
#
# Assolo Helper Pack Version 1.0
#
# More Information can be found in the README
#
# Licensed under "GNU GENERAL PUBLIC LICENSE Version 3"
# Sebastian.Wilken@uni-duesseldorf.de - Base Release 1.0 - 15.10.2011
#

if [ "$1" = "compile" ] ; then
	cd C-Code
	
	echo " "
	echo "Compiling"
	
	echo "-> C-Code/Debugizer"
	g++ -Wall Debugizer.cpp -o Debugizer
	if [ "$?" != "0" ] ; then
		echo " "
		echo "Error occured with g++ -> exit"
		cd ..
		exit
	fi

	echo "-> C-Code/Instbwizer"
	g++ -Wall Instbwizer.cpp -o Instbwizer
	if [ "$?" != "0" ] ; then
		echo " "
		echo "Error occured with g++ -> exit"
		cd ..
		exit
	fi

	echo "-> C-Code/Statsizer"
	g++ -Wall Statsizer.cpp -o Statsizer
	if [ "$?" != "0" ] ; then
		echo " "
		echo "Error occured with g++ -> exit"
		cd ..
		exit
	fi
	echo " "
	echo "Done. You can try \"./HelperAssolo.sh\" for help"
	
	cd ..
else
	clear
	echo " "
	cat README | less
	echo " "
echo " "
cd ..
fi
