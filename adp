#! /bin/bash

revision=12-Mar-2014

#############################################
### DO NOT ALTER ANYTHING BELOW THIS LINE ###
#############################################

if [ -e processing.log ]
	[ -e SUMMARY ]	
then
	rm SUMMARY
fi

log=processing.log
sumlog=SUMMARY
fail=FAILED

echo -e "\
\n
   ##############################################################
   ##                                                          ##
   ##                           AutoDP                         ##
   ##                                                          ##
   ##    A collection of shell script routines for automated   ##
   ##  processing of X-ray diffraction data with XDS and CCP4  ##
   ##                                                          ##
   ##                         Ver. 0.8.0                       ##
   ##                                                          ##
   ##                     Build: $revision                   ##
   ##                                                          ##
   ##         Please send comments and bug reports to:         ##
   ##                                                          ##
   ##                   eugene.valkov@gmail.com                ##
   ##                                                          ##
   ##############################################################"

# check for required software - currently XDS, aimless and pointless
command -v xds_par >/dev/null 2>&1 || { echo "Requires XDS but it's not installed. Aborting." >&2; exit 1; }
command -v aimless >/dev/null 2>&1 || { echo "Requires AIMLESS but it's not installed. Aborting." >&2; exit 1; }
command -v pointless >/dev/null 2>&1 || { echo "Requires POINTLESS but it's not installed. Aborting." >&2; exit 1; }

#Run with only minimal summary output for each dataset
echo -e "\nRun in quiet mode? [y/N]: \c"
read yesno
if [[ $yesno == "y" || $yesno == "Y" || $yesno == "yes" ]]; then
	echo -e "\nProcessing with minimal output..."
	mode=quiet	
elif [[ $yesno == "n" || $yesno == "N" || $yesno == "no" || $yesno == "" ]]; then
	echo -e "\nProcessing with verbose output..."
	mode=verbose
else 
	until [[ $yesno == "yes" || $yesno == "no" ]]; do
		echo -e "Please answer 'yes' or 'no': \c"
		read yesno; done
fi

echo -e "\nDo you want to impose symmetry for ALL datasets? [y/N]: \c"
read yesno
if [[ $yesno == "y" || $yesno == "Y" || $yesno == "yes" ]]; then
	bash $ADP_HOME/symm_check.sh
elif [[ $yesno == "n" || $yesno == "N" || $yesno == "no" || $yesno == "" ]]; then
	echo -e "\nWill use automated symmetry assignment."
else 
	until [[ $yesno == "yes" || $yesno == "no" ]]; do
		echo -e "Please answer 'yes' or 'no': \c"
		read yesno; done
fi

echo -e "\nDo you want to proceed [Y/n]: \c"
read yesno
if [[ $yesno == "y" || $yesno == "Y" || $yesno == "yes" || $yesno == "" ]]; then
	echo -e "\nOK, proceeding..."
elif [[ $yesno == "n" || $yesno == "N" || $yesno == "no" ]]; then
	echo -e "\nQuitting..."
	sleep 1
	exit
else 
	until [[ $yesno == "yes" || $yesno == "no" ]]; do
		echo -e "Please answer 'yes' or 'no': \c"
		read yesno; done
fi

if [ ! -e dataset_list ]; then
    # due to peculiarities of the naming convention for SLS data, i.e., identical filenames in separate subfolders, use data-analyser-sls.sh
    #bash $homedir/data_analyser.sh
    bash $ADP_HOME/adp.data_analyser
fi

datasets=`awk 'END { print NR }' dataset_list`

dataset=0
for datadir in `cat dataset_list`
do 
	dataset=$((dataset+1))
	xtal=$datadir
	workdir=$xtal
	original_dir=`grep $datadir data_list | tail -1 | sed 's/.[^/]*$//'`
	#check if full symmetry is imposed
	if [ -e symm_def ]; then
		cp symm_def $datadir/
	fi
	cd $datadir
    echo -e "$original_dir" > data_location
	if [[ $mode == "quiet" ]]; then
		echo -e "\nProcessing dataset $dataset of $datasets\c"
		bash $ADP_HOME/adp.prepare_xds > /dev/null 2>&1
		bash $ADP_HOME/adp.indexer > /dev/null 2>&1
		bash $ADP_HOME/adp.integrater > /dev/null 2>&1
		bash $ADP_HOME/adp.convert_xds_to_shelx > /dev/null 2>&1
		bash $ADP_HOME/adp.merger > /dev/null 2>&1  
	else
		echo -e "\nProcessing dataset $dataset of $datasets\n"
		bash $ADP_HOME/adp.prepare_xds
		bash $ADP_HOME/adp.indexer
		bash $ADP_HOME/adp.integrater
		bash $ADP_HOME/adp.convert_xds_to_shelx
		bash $ADP_HOME/adp.merger
	fi
	if [ -e processing_summary.log ]; then
		cat processing_summary.log >> ../processing_summary.txt
	fi

	#check if processing generated final mtz output
	#mtz_file=$(ls *.merged.freeR.mtz 2> /dev/null | wc -l)
	#if [ "$mtz_file" = "1" ] && [ ! -e GRID_SCAN ]; then
		#mkdir DATA_FILES > /dev/null 2>&1
		#mv *.mtz DATA_FILES/ > /dev/null 2>&1
		#mkdir LOG_FILES > /dev/null 2>&1
		#mv *.LP LOG_FILES/ > /dev/null 2>&1
	if [ -e 1-uniqueify.log ]; then
		merged_data_file_check=`awk '/merged.freeR.mtz/ {print $5}' 1-uniqueify.log`
		if [ ! -e "$merged_data_file_check" ] && [ ! -e GRID_SCAN ]; then
			#mkdir LOG_FILES > /dev/null 2>&1
			#mv *.LP LOG_FILES/ > /dev/null 2>&1
			echo -e "$datadir" >> FAILED
			cat FAILED >> ../ALL_FAILED
		fi
	fi
	cd ..
done

if [ -e ALL_FAILED ]; then
	echo -e "\nThe data in these directories could not be processed:\n"
	cat ALL_FAILED
	rm ALL_FAILED
fi

rm *_list

echo -e "\n		### PROCESSING COMPLETED! ###\n"

echo -e "Please acknowledge the use of software used by citing the following publications:

1. Evans P.R. (2006) Acta Cryst. D 62, 72-82.
2. Evans P.R. & Murshudov G.N. (2013) Acta Cryst. D 69, 1204-14.
3. Kabsch W. (2010) Acta Cryst. D 66, 125-132.
4. Winn M.D. et al. (2011) Acta. Cryst. D67 , 235-242.\n"
