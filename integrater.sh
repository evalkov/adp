#! /bin/bash

# checks if previous step resulted in error or it is a grid scan and exits
if [ -e ERROR.LP ] || [ -e GRID_SCAN ]; then
	exit
fi

inpfile=`wc -l XDS.INP | cut -c 1-3`
head -n $inpfile XDS.INP > XDS.INP.004
sed -i '/TRUSTED_REGION= /d' XDS.INP.004
sed -i '/JOB= /d' XDS.INP.004
echo "JOB= DEFPIX INTEGRATE" >> XDS.INP.004
echo "TRUSTED_REGION= 0.0 1.05" >> XDS.INP.004
cp XDS.INP.004 XDS.INP

echo -e "\
\n### INTEGRATION ###\n"

echo -e "  images     sng    ovd    rej     sca     mos     div     acc"  
echo -e "---------------------------------------------------------------"

xds_par | awk '\
/ACCEPTED/||/UNABLE/ {
	printf "%3d - %3d   %4d   %4d   %4d   %2.3f   %2.3f   %2.4f", x, y, int(tot/nb), int(tot1), int(tot2/nb), tot3/nb, tot5/nb, tot4/nb}
/IMAGE/{
getline;tot=nb=0;tot1=nb=0;tot2=nb=0;tot3=nb=0;tot4=nb=0;tot5=nb=0;x=$1}
$7>0 {
tot+=$7;tot1+=$5;tot2+=$8;tot3+=$3;tot4+=$9;tot5+=$10;nb++}
NF {
y=$1
}
/REFLECTIONS ACCEPTED FOR REFINEMENT/ {
	printf "   %3.1f\n", (100*$1)/$4
}
/UNABLE TO CARRY OUT REFINEMENT/ {
    	printf "   0\n"
}
'

finish_check=`awk '/wall-clock/ { printf "%s", $1 }' INTEGRATE.LP`

#what this does is attempt to repeat integration 'n' attempts, each time 
#truncating total number of images to process by 10% of the total images
total_attempts=5 
attempt=0
while [ ! -e INTEGRATE.HKL ]; do
	attempt=$((attempt+1))
	echo -e "\n		*** Integration failed. ***\n"
	rangestart=`awk '/DATA_RANGE/ {print $2}' XDS.INP`
	start=`echo $rangestart | bc`
	rangeend=`awk '/DATA_RANGE/ {print $3}' XDS.INP`
	fraction_removed=`echo "$rangeend*0.1" | bc | xargs printf "%1.0f"`
	newrangeend=`echo "$rangeend-$fraction_removed" | bc | xargs printf "%1.0f"`
	if [[ "$start" -eq "$newrangeend" ]]  || [[ "$attempt" -eq "6" ]] ; then
	    echo "Repeated integration attempts have failed." 
	    break
	fi
	sed -i '/DATA_RANGE= /d' XDS.INP
	echo "DATA_RANGE= $rangestart $newrangeend" >> XDS.INP
	echo -e "Will now try integration again with less images.\n"
	echo -e "Repeat attempt $attempt/$total_attempts. New image range: $start - $newrangeend\n"
	echo -e "\
\n### INTEGRATION ###\n"
	echo -e "  images     sng    ovd    rej     sca     mos     div     acc"  
	echo -e "---------------------------------------------------------------"
	xds_par | awk '\
	/ACCEPTED/||/UNABLE/ {
		printf "%3d - %3d   %4d   %4d   %4d   %2.3f   %2.3f   %2.4f", x, y, int(tot/nb), int(tot1), int(tot2/nb), tot3/nb, tot5/nb, tot4/nb}
	/IMAGE/{
	getline;tot=nb=0;tot1=nb=0;tot2=nb=0;tot3=nb=0;tot4=nb=0;tot5=nb=0;x=$1}
	$7>0 {
	tot+=$7;tot1+=$5;tot2+=$8;tot3+=$3;tot4+=$9;tot5+=$10;nb++}
	NF {
	y=$1
	}
	/REFLECTIONS ACCEPTED FOR REFINEMENT/ {
		printf "   %3.1f\n", (100*$1)/$4
	}
	/UNABLE TO CARRY OUT REFINEMENT/ {
	    	printf "   0\n"
	}
	'
done

# This checks for errors during the integration step and stops the script, if errors found
checkerror=`awk '/!!! ERROR/' INTEGRATE.LP`
checkerror1=`awk '/!!! ERROR/' DEFPIX.LP`

if [[ "$checkerror" ]]; then
    echo -e "\n***********************************************************************"
    echo -e "*** XDS encountered a serious error during integration and stopped! ***"
    echo -e "***********************************************************************\n"
    echo -e "$checkerror\n"
	cat INTEGRATE.LP > ERROR.LP
	exit
elif [[ "$checkerror1" ]]; then
    echo -e "\n***********************************************************************"
    echo -e "*** XDS encountered a serious error during integration and stopped! ***"
    echo -e "***********************************************************************\n"
    echo -e "$checkerror\n"
	cat DEFPIX.LP > ERROR.LP
	exit
fi

totalintensities=`awk '/REFLECTIONS SAVED/ {printf "\nIntegrated intensities:		%3d\n", $1}' INTEGRATE.LP`
echo -e "$totalintensities"
divergence=`awk '/BEAM_DIVERGENCE_E.S.D.=/ {printf "Beam divergence (deg):		%3.3f\n", $4}' INTEGRATE.LP | tail -1`
echo -e "$divergence"
mosaicity=`awk '/SUGGESTED/,/REFLECTING_RANGE_E.S.D.=/ {printf "Mosaicity (deg):  		%3.3f\n", $4}' INTEGRATE.LP | tail -1`
echo -e "$mosaicity"

exit
