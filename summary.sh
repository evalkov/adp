#! /bin/bash

if [ -e GRID_SCAN ]; then
	cat GRID_SCAN
	exit
fi

if [ -e SUMMARY.LP ]; then
    rm -rf SUMMARY.LP
fi

scalalog=SCALA.LP
sumlog=SUMMARY.LP
datasetlog=DATASET_PARAMS.LP
xdslog=CORRECT.LP
trunclog=TRUNCATE.LP
integratelog=INTEGRATE.LP

dataset=`awk '/Project/ { print $4}' $datasetlog`

if [ ! -e XYCORR.LP ]; then
	echo -e "\
\n\n#########################################################################
Dataset $dataset could not be processed.				
Please examine all the logs carefully.					
#########################################################################\n"
	exit
elif [ ! -e INIT.LP ]; then
	echo -e "\
\n\n#########################################################################
Dataset $dataset could not be processed.				
Please examine all the logs carefully.					
#########################################################################\n"
	exit
elif [ ! -e IDXREF.LP ]; then
	echo -e "\
\n\n#########################################################################
Dataset $dataset could not be processed.				
Please examine all the logs carefully.					
#########################################################################\n"
	exit
elif [ ! -e DEFPIX.LP ]; then
	echo -e "\
\n\n#########################################################################
Dataset $dataset could not be processed.				
Please examine all the logs carefully.					
#########################################################################\n"
	exit
elif [ ! -e INTEGRATE.LP ]; then
	echo -e "\
\n\n#########################################################################
Dataset $dataset could not be processed.				
Please examine all the logs carefully.					
#########################################################################\n"
	exit
elif [ ! -e CORRECT.LP ]; then
	echo -e "\
\n\n#########################################################################
Dataset $dataset could not be processed.
Please examine all the logs carefully.
#########################################################################\n"
	exit
elif [ ! -e SCALA.LP ]; then
	echo -e "\
\n\n#########################################################################
Dataset $dataset could not be processed.
Please examine all the logs carefully.
#########################################################################\n"
	exit
elif [ ! -e TRUNCATE.LP ]; then
	echo -e "\
\n\n#########################################################################
Dataset $dataset could not be processed.
Please examine all the logs carefully.
#########################################################################\n"
	exit
elif [ ! -e UNIQUEIFY.LP ]; then
	echo -e "\
\n\n#########################################################################
Dataset $dataset could not be processed.
Please examine all the logs carefully.
#########################################################################\n"
	exit
fi

lores=`awk '/Low resolution limit/ {printf "%s", $4}' $scalalog`
hires=`awk '/High resolution limit/ {printf "%s", $4}' $scalalog`
outlores=`awk '/Low resolution limit/ {printf "%s", $6}' $scalalog`
outhires=`awk '/High resolution limit/ {printf "%s", $6}' $scalalog`
rmerge=`awk '/Summary/,/Maximum/' $scalalog | awk '/Rmerge  \(all/ {printf "%s", $6}'`
rmergepercent=`echo "scale=2; $rmerge*100" | bc | awk '{printf "%2.1f%",$1}'`
rmergeout=`awk '/Summary/,/Maximum/' $scalalog | awk '/Rmerge  \(all/ {printf "%s", $8}'`
rmergeoutpercent=`echo "scale=2; $rmergeout*100" | bc | awk '{printf "%2.1f%",$1}'`
rmeas=`awk '/Summary/,/Maximum/' $scalalog | awk '/Rmeas \(all/ {printf "%s", $6}'`
rmeasout=`awk '/Summary/,/Maximum/' $scalalog | awk '/Rmeas \(all/ {printf "%s", $8}'`
rmeaspercent=`echo "scale=2; $rmeas*100" | bc | awk '{printf "%2.1f%",$1}'`
rmeasoutpercent=`echo "scale=2; $rmeasout*100" | bc | awk '{printf "%2.1f%",$1}'`
rpim=`awk '/Summary/,/Maximum/' $scalalog | awk '/Rpim \(all/ {printf "%s", $6}'`
rpimout=`awk '/Summary/,/Maximum/' $scalalog | awk '/Rpim \(all/ {printf "%s", $8}'`
rpimpercent=`echo "scale=2; $rpim*100" | bc | awk '{printf "%2.1f%",$1}'`
rpimoutpercent=`echo "scale=2; $rpimout*100" | bc | awk '{printf "%2.1f%",$1}'`
totalobs=`awk '/Summary/,/Maximum/' $scalalog | awk '/Total number of observations/ {printf "%s", $5}'`
totalobsout=`awk '/Summary/,/Maximum/' $scalalog | awk '/Total number of observations/ {printf "%s", $7}'`
unique=`awk '/Summary/,/Maximum/' $scalalog | awk '/Total number unique/ {printf "%s", $4}'`
uniqueout=`awk '/Summary/,/Maximum/' $scalalog | awk '/Total number unique/ {printf "%s", $6}'`
signal=`awk '/Summary/,/Maximum/' $scalalog | awk '/Mean/ {printf "%s", $2}'`
signalout=`awk '/Summary/,/Maximum/' $scalalog | awk '/Mean/ {printf "%s", $4}'`
halfsetcc=`awk '/half-set correlation CC/ {printf "%s", $5}' $scalalog`
halfsetccout=`awk '/half-set correlation CC/ {printf "%s", $6}' $scalalog`
completeness=`awk '/Summary/,/Maximum/' $scalalog | awk '/Completeness/ {printf "%s", $2}'`
completenessout=`awk '/Summary/,/Maximum/' $scalalog | awk '/Completeness/ {printf "%s", $4}'`
multiplicity=`awk '/Summary/,/Maximum/' $scalalog | awk '/Multiplicity/ {printf "%s", $2}'`
multiplicityout=`awk '/Summary/,/Maximum/' $scalalog | awk '/Multiplicity/ {printf "%s", $4}'`
siganototal=`awk '/ STATISTICS OF SAVED DATA SET/,/total/' $xdslog | grep "total" | tail -1 | awk '/[0-9]+$/ {printf "%3.2f\n", $13}'`
siganoouter=`awk '/ STATISTICS OF SAVED DATA SET/,/total/' $xdslog | grep -B 1 "total" | head -1 | awk '/[0-9]+$/ {printf "%3.2f\n", $13}'`
anomcorrtotal=`awk '/ STATISTICS OF SAVED DATA SET/,/total/' $xdslog | grep "total" | tail -1 | awk '/[0-9]+$/ {printf "%s\n", $12}'`
anomcorrouter=`awk '/ STATISTICS OF SAVED DATA SET/,/total/' $xdslog | grep -B 1 "total" | head -1 | awk '/[0-9]+$/ {printf "%s\n", $12}'`
anompairstotal=`awk '/ STATISTICS OF SAVED DATA SET/,/total/' $xdslog | grep "total" | tail -1 | awk '/[0-9]+$/ {printf "%s\n", $14}'`
anompairsouter=`awk '/ STATISTICS OF SAVED DATA SET/,/total/' $xdslog | grep -B 1 "total" | head -1 | awk '/[0-9]+$/ {printf "%s\n", $14}'`
anomcompleteness=`awk '/Summary/,/Maximum/' $scalalog | awk '/Anomalous completeness/ {printf "%s", $3}'`
anomcompletenessout=`awk '/Summary/,/Maximum/' $scalalog | awk '/Anomalous completeness/ {printf "%s", $5}'`
anommultiplicity=`awk '/Summary/,/Maximum/' $scalalog | awk '/Anomalous multiplicity/ {printf "%s", $3}'`
anommultiplicityout=`awk '/Summary/,/Maximum/' $scalalog | awk '/Anomalous multiplicity/ {printf "%s", $5}'`
wilsonb=`awk '/TABLE: Wilson Plot - Suggested Bfactor/' $trunclog | sed 's/.[^:]*$//' | awk -F "Bfactor" '{ printf "%3.1f", $2 }'`
mosaicity=`awk '/SUGGESTED/,/REFLECTING_RANGE_E.S.D.=/ {printf "%3.3f\n", $4}' $integratelog | tail -1`
refinedcell=`grep "UNIT_CELL_CONSTANTS" $xdslog | tail -1 | awk '/[0-9]+$/ {printf "%4.1f %4.1f %4.1f %4.1f %4.1f %4.1f\n", $2, $3, $4, $5, $6, $7}'`
aaxis=`grep "UNIT_CELL_CONSTANTS" $xdslog | tail -1 | awk '/[0-9]+$/ {printf "%4.1f\n", $2}'`
baxis=`grep "UNIT_CELL_CONSTANTS" $xdslog | tail -1 | awk '/[0-9]+$/ {printf "%4.1f\n", $3}'`
caxis=`grep "UNIT_CELL_CONSTANTS" $xdslog | tail -1 | awk '/[0-9]+$/ {printf "%4.1f\n", $4}'`
alpha=`grep "UNIT_CELL_CONSTANTS" $xdslog | tail -1 | awk '/[0-9]+$/ {printf "%4.1f\n", $5}'`
beta=`grep "UNIT_CELL_CONSTANTS" $xdslog | tail -1 | awk '/[0-9]+$/ {printf "%4.1f\n", $6}'`
gamma=`grep "UNIT_CELL_CONSTANTS" $xdslog | tail -1 | awk '/[0-9]+$/ {printf "%4.1f\n", $7}'`
spacegroup=`awk -F '[(|)]' '/ * Space group = / { print $1 }' MTZDUMP.LP | awk -F\' '{print $2}'| sed 's/ //g'`
spacegroupnum=`awk -F '[(|)]' '/ * Space group = / { print $2 }' MTZDUMP.LP | awk '{ printf "%s", $2}'`
aniso_deltab=`grep "Anisotropic deltaB" $scalalog | awk 'BEGIN {FS=":"}; {printf "%2.2f\n",$2}'`
#spacegroupnum=`awk -F '[(|)]' '/ * Space group = / { print $2 }' MTZDUMP.LP | awk '{ printf "%s", $2}'`
#spacegroup=`awk -v s=$spacegroupnum 's {gsub(/\[|\]/,"");for (i=1; i<=NF; i++) {split($i,a,","); if (a[1]==s) printf "%s", a[2]}}' CORRECT.LP | sed 's/(//g;s/)//g'`
#check for rhombohedral/hexagonal setting in space groups 146 and 155 and print the PDB standard
if [ $spacegroupnum == "146" ] && [ $alpha == "$beta" ] && [ $alpha == "$gamma" ]; then
	spacegroup=R3
elif [ $spacegroupnum == "155" ] && [ $alpha == "$beta" ] && [ $alpha == "$gamma" ]; then
	spacegroup=R32
elif [ $spacegroupnum == "146" ] && [ ! $alpha == "$gamma" ]; then
	spacegroup=H3
elif [ $spacegroupnum == "155" ] && [ ! $alpha == "$gamma" ]; then
	spacegroup=H32
fi
anom=`awk '/anomalous flag/&&/OFF/' SCALA.LP`
frames=`cat INTEGRATE.LP | awk '/DATA_RANGE= / { printf "%s", $3}'`
wavelength=`cat INTEGRATE.LP | awk '/WAVELENGTH= / { printf "%1.5f", $2}'`
oscillation=`cat INTEGRATE.LP | awk '/OSCILLATION_RANGE= / { printf "%1.2f", $2}'`
#specify data and processing directories

datafile=`ls $dataset.$spacegroup.mtz`
datafile_free=`ls $dataset.$spacegroup"_"freeR.mtz`

echo -e "\

\n### DATA PROCESSING STATISTICS ###\n" | tee -a $sumlog


echo -e "Dataset:			$dataset" | tee -a $sumlog

exp_date=`grep "Experiment date" $datasetlog | awk '{print $3, $4, $5}'`
if [[ $exp_date ]]; then
    echo -e "\
Experiment date:                $exp_date" | tee -a $sumlog
fi

image_dir=`awk '/Image directory:/ {print $3}' $datasetlog`

echo -e "\
Processing directory:		$PWD
Image directory:                $image_dir
Structure factor amplitudes:	$datafile_free				
Wavelength:			$wavelength							
Oscillation range (deg):        $oscillation					
Number of frames:		$frames					
Unit cell parameters:		$refinedcell		
Space group:			$spacegroup (# $spacegroupnum)				
Resolution:			$hires - $lores ($outhires - $outlores)		
R-merge:			$rmergepercent ($rmergeoutpercent)				
R-meas:				$rmeaspercent ($rmeasoutpercent)				
R-pim:				$rpimpercent ($rpimoutpercent)				
Total observations:		$totalobs ($totalobsout)				
Unique observations:		$unique ($uniqueout)				
Mean ((I)/sd(I)):		$signal ($signalout)
Mean half-set correlation:	$halfsetcc ($halfsetccout)				
Mosaicity (deg):		$mosaicity					
Completeness:			$completeness ($completenessout)				
Multiplicity:			$multiplicity ($multiplicityout)				
Anisotropic delta B:            $aniso_deltab
Wilson B-factor:		$wilsonb" | tee -a $sumlog

if [ "$anom" = "" ]; then
	echo -e "\
Anomalous completeness:		$anomcompleteness ($anomcompletenessout)	
Anomalous multiplicity:		$anommultiplicity ($anommultiplicityout)
Mean anomalous difference:	$siganototal ($siganoouter)
Mean anomalous correlation:	$anomcorrtotal ($anomcorrouter)
Friedel pairs:			$anompairstotal ($anompairsouter)" | tee -a $sumlog
fi

exit
