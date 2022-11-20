#! /bin/bash

# running correct

rm -rf XDS_ASCII.HKL
rm -rf CORRECT.LP
rm -rf POINTLESS.LP
rm -rf XDS.INP.005
rm -rf XDS.INP.006

# checks if previous step resulted in error or it is a grid scan and exits
if [ -e ERROR.LP ] || [ -e GRID_SCAN ]; then
	exit
fi

# extracts basic info and waits for the integration step to finish

xtal=`awk '/Project/ { printf "%s", $4}' DATASET_PARAMS.LP`

inpfile=`wc -l XDS.INP | cut -c 1-3`
head -n $inpfile XDS.INP > XDS.INP.005

sed -i '/SPACE_GROUP_NUMBER=/d' XDS.INP.005
sed -i '/UNIT_CELL_CONSTANTS=/d' XDS.INP.005

while [ 1 ]
do
    PID=$(ls | grep "INTEGRATE.HKL" | awk '{print $1}')
    [ ! -n "$PID" ] && sleep 1 || break
done

# if symmetry has been provided then pointless simply converts INTEGRATE.HKL


if [ -e symm_def ]; then
    # if symmetry has been provided then runs CORRECT
    spacegroupnum=`awk '/SPACE_GROUP_NUMBER=/ { print $2 }' INTEGRATE.LP`
    cell=`awk '/UNIT_CELL_CONSTANTS=/ { print $2, $3, $4, $5, $6, $7 }' INTEGRATE.LP`
    echo "SPACE_GROUP_NUMBER=$spacegroupnum" >> XDS.INP.005
    echo "UNIT_CELL_CONSTANTS=$cell" >> XDS.INP.005
    sed -i '/JOB= /d' XDS.INP.005
    echo "JOB= CORRECT" >> XDS.INP.005
    cp XDS.INP.005 XDS.INP
    xds_par > /dev/null &

    while [ 1 ]; do
        PID=$(ls | grep "CORRECT.LP" | awk '{print $1}')
        [ ! -n "$PID" ] && sleep 1 || break
    done

    # This checks for errors during the scaling step and stops the script, if errors found
    while [ CORRECT.tmp ]; do
        checkerror=`awk '/!!! ERROR/' CORRECT.LP`
        if [[ "$checkerror" ]]; then
            echo -e "\n*******************************************************************"
            echo -e "*** XDS encountered a serious error during scaling and stopped! ***"
            echo -e "*******************************************************************\n"
            echo -e "$checkerror\n"
            cat CORRECT.LP > ERROR.LP
            exit
        fi
        PID=$(ls | grep "CORRECT.tmp" | awk '{print $1}')
        [ -n "$PID" ] && sleep 1 || break
    done

    # This waits for CORRECT to produce XDS_ASCII.HKL
    while [ 1 ]; do
        PID=$(ls | grep "XDS_ASCII.HKL" | awk '{print $1}')
        [ ! -n "$PID" ] && sleep 1 || break
    done

    # This runs Pointless to simply convert XDS_ASCII.HKL to an MTZ file
    pointless -copy xdsin XDS_ASCII.HKL hklout $xtal.indexed.mtz > POINTLESS.LP 2>/dev/null

    while [ 1 ]; do
        PID=$(ls | grep "POINTLESS.LP" | awk '{print $1}')
        [ ! -n "$PID" ] && sleep 1 || break
    done
else
    # if symmetry has been not been provided then runs Pointless to analyse the data without outputting an MTZ
    pointless xdsin INTEGRATE.HKL > POINTLESS.LP 2>/dev/null
    while [ 1 ]; do
        PID=$(ls | grep "POINTLESS.LP" | awk '{print $1}')
        [ ! -n "$PID" ] && sleep 1 || break
    done
fi

#spacegroup=`awk -F '[(|)]' '/ * Space group = / { print $1 }' POINTLESS.LP | awk -F\' '{print $2}'`
newcell=`awk '/Unit cell:/ {print $3, $4, $5, $6, $7, $8}' POINTLESS.LP`
#newcell=`awk '/Unit cell:/ {printf "%3.1f %3.1f %3.1f %3.1f %3.1f %3.1f\n",$3,$4,$5,$6,$7,$8}' POINTLESS.LP`
spacegroupnum=`awk '/TotProb/&&/SysAbsProb/ {getline;getline;split($0,a,"(");split(a[2],b,")");printf "%3d",b[1] }' POINTLESS.LP`
#sysabsprob=`awk '/TotProb/&&/SysAbsProb/ {getline;getline;split($0,a,"(");split(a[2],b," ");print b[2] }' POINTLESS.LP`
#laueprob=`awk '/Laue group probability:/ {printf "%4.3f",$4}' POINTLESS.LP`
#spacegroupprob=`awk '/Space group confidence:/ {printf "%4.3f",$4}' POINTLESS.LP`
#reindexop=`awk '/Reindexing operator/ { print $3}' POINTLESS.LP | sed 's/\[//g;s/\]//g'`
#realspacetransform=`awk '/Real space transformation/ { print $4}' POINTLESS.LP | sed 's/(//g;s/)//g'`

pointless_analysis=`sed -n '/Best Solution:/,/Unit/p' POINTLESS.LP`

spacegroup=`echo "$pointless_analysis" | awk '/space group/' | awk 'BEGIN {FS="p "}; { print $2 }'`
newcell=`echo "$pointless_analysis" | awk '/Unit cell:/ { printf "%3.1f, %3.1f, %3.1f, %3.1f, %3.1f, %3.1f", $3, $4, $5, $6, $7, $8 }'`
spacegroupnum=`awk '/TotProb/&&/SysAbsProb/ {getline;getline;split($0,a,"(");split(a[2],b,")");printf "%3d",b[1] }' POINTLESS.LP`
reindexop=`echo "$pointless_analysis" | awk '/Reindex operator/ { print $3}' | sed 's/\[//g;s/\]//g'`
laueprob=`echo "$pointless_analysis" | awk '/Laue group probability:/ {printf "%4.3f",$4}'`
spacegroupprob=`echo "$pointless_analysis" | awk '/Space group confidence:/ {printf "%4.3f",$4}'`


echo -e "\
\n### SYMMETRY ANALYSIS ###\n
Space group:                    $spacegroup (# $spacegroupnum)
Unit cell:                      $newcell
Laue group confidence:          $laueprob
Space group confidence:         $spacegroupprob
Reindexing operator:            $reindexop"

# if symmetry has been not been provided then uses information from Pointless to run CORRECT
if [ ! -e symm_def ]; then
    inpfile=`wc -l XDS.INP | cut -c 1-3`
    head -n $inpfile XDS.INP > XDS.INP.006
    sed -i '/SPACE_GROUP_NUMBER=/d' XDS.INP.006
    sed -i '/UNIT_CELL_CONSTANTS=/d' XDS.INP.006
    sed -i '/JOB= /d' XDS.INP.006
    echo "SPACE_GROUP_NUMBER=$spacegroupnum" >> XDS.INP.006
    echo "UNIT_CELL_CONSTANTS=$newcell" >> XDS.INP.006
    echo "JOB= CORRECT" >> XDS.INP.006
    cp XDS.INP.006 XDS.INP
    xds_par > /dev/null &
fi

while [ 1 ]; do
    PID=$(ls | grep "CORRECT.LP" | awk '{print $1}')
    [ ! -n "$PID" ] && sleep 1 || break
done

# This checks for errors during the scaling step and stops the script, if errors found
while [ CORRECT.tmp ]; do
    checkerror=`awk '/!!! ERROR/' CORRECT.LP`
    if [[ "$checkerror" ]]; then
        echo -e "\n*******************************************************************"
        echo -e "*** XDS encountered a serious error during scaling and stopped! ***"
        echo -e "*******************************************************************\n"
        echo -e "$checkerror\n"
        cat CORRECT.LP > ERROR.LP
        exit
    fi
    PID=$(ls | grep "CORRECT.tmp" | awk '{print $1}')
    [ -n "$PID" ] && sleep 1 || break
done

while [ 1 ]; do
    PID=$(ls | grep "XDS_ASCII.HKL" | awk '{print $1}')
    [ ! -n "$PID" ] && sleep 1 || break
done


# This runs Pointless to simply convert XDS_ASCII.HKL to an MTZ file
pointless -copy xdsin XDS_ASCII.HKL hklout $xtal.indexed.mtz > POINTLESS.LP 2>/dev/null

while [ 1 ]; do
    PID=$(ls | grep "POINTLESS.LP" | awk '{print $1}')
    [ ! -n "$PID" ] && sleep 1 || break
done

totaldataframes=`awk '/STATISTICS OF SAVED DATA SET/ {printf "%1d - %1d\n", $8, $9}' CORRECT.LP`
refinedcell=`grep "UNIT_CELL_CONSTANTS" CORRECT.LP | tail -1 | awk '/[0-9]+$/ {printf "%4.1f %4.1f %4.1f %4.1f %4.1f %4.1f\n", $2, $3, $4, $5, $6, $7}'`
aaxis=`grep "UNIT_CELL_CONSTANTS" CORRECT.LP | tail -1 | awk '/[0-9]+$/ {printf "%4.1f\n", $2}'`
baxis=`grep "UNIT_CELL_CONSTANTS" CORRECT.LP | tail -1 | awk '/[0-9]+$/ {printf "%4.1f\n", $3}'`
caxis=`grep "UNIT_CELL_CONSTANTS" CORRECT.LP | tail -1 | awk '/[0-9]+$/ {printf "%4.1f\n", $4}'`
alpha=`grep "UNIT_CELL_CONSTANTS" CORRECT.LP | tail -1 | awk '/[0-9]+$/ {printf "%4.1f\n", $5}'`
beta=`grep "UNIT_CELL_CONSTANTS" CORRECT.LP | tail -1 | awk '/[0-9]+$/ {printf "%4.1f\n", $6}'`
gamma=`grep "UNIT_CELL_CONSTANTS" CORRECT.LP | tail -1 | awk '/[0-9]+$/ {printf "%4.1f\n", $7}'`
spacegroupnum=`grep "SPACE_GROUP_NUMBER=" CORRECT.LP | tail -1 | awk '/[0-9]+$/ {printf "%s\n", $2}'`
spacegroup=`awk -v s=$spacegroupnum 's {gsub(/\[|\]/,"");for (i=1; i<=NF; i++) {split($i,a,","); if (a[1]==s) printf "%s", a[2]}}' CORRECT.LP | sed 's/(//g;s/)//g'`

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

##spacegroup=` sed -n '/\[155,/ s/.*155,\([^]]*\)].*/\1/p' XSCALE.LP`
loreslimit=`grep -B 5 "SUMMARY OF DATA SET STATISTICS FOR VARIOUS SUBSETS" CORRECT.LP | head -1 | awk '/[0-9]+$/ {printf "%4.2f", $1}'`
hireslimit=`awk '/ STATISTICS OF SAVED DATA SET/,/total/' CORRECT.LP | tail -2 | head -1 | awk '{print $1}'`
outshellhigh=`awk '/ STATISTICS OF SAVED DATA SET/,/total/' CORRECT.LP | grep -B 2 "total" | head -2 | tail -1 | awk '/[0-9]+$/ {printf "%4.2f\n", $1}'`
outshelllow=`awk '/ STATISTICS OF SAVED DATA SET/,/total/' CORRECT.LP | grep -B 2 "total" | head -1 | tail -1 | awk '/[0-9]+$/ {printf "%4.2f\n", $1}'`
completenesstotal=`awk '/ STATISTICS OF SAVED DATA SET/,/total/' CORRECT.LP | grep "total" | tail -1 | awk '/[0-9]+$/ {printf "%s\n", $5}'`
completenessouter=`awk '/ STATISTICS OF SAVED DATA SET/,/total/' CORRECT.LP | grep -B 1 "total" | head -1 | awk '/[0-9]+$/ {printf "%s\n", $5}'`	
isigmatotal=`awk '/ STATISTICS OF SAVED DATA SET/,/total/' CORRECT.LP | grep "total" | tail -1 | awk '/[0-9]+$/ {printf "%3.1f\n", $9}'`
isigmaouter=`awk '/ STATISTICS OF SAVED DATA SET/,/total/' CORRECT.LP | grep -B 1 "total" | head -1 | awk '/[0-9]+$/ {printf "%3.1f\n", $9}'`
rmeastotal=`awk '/ STATISTICS OF SAVED DATA SET/,/total/' CORRECT.LP | grep "total" | tail -1 | awk '/[0-9]+$/ {printf "%s\n", $10}'`
rmeasouter=`awk '/ STATISTICS OF SAVED DATA SET/,/total/' CORRECT.LP | grep -B 1 "total" | head -1 | awk '/[0-9]+$/ {printf "%s\n", $11}'`
rmrgdftotal=`awk '/ STATISTICS OF SAVED DATA SET/,/total/' CORRECT.LP | grep "total" | tail -1 | awk '/[0-9]+$/ {printf "%s\n", $11}'`
rmrgdfouter=`awk '/ STATISTICS OF SAVED DATA SET/,/total/' CORRECT.LP | grep -B 1 "total" | head -1 | awk '/[0-9]+$/ {printf "%s\n", $11}'`
wilsonbfactor=`awk '/WILSON LINE/ {printf "%3.1f\n", $10}' CORRECT.LP`
comparedtotal=`awk '/ STATISTICS OF SAVED DATA SET/,/total/' CORRECT.LP | grep "total" | tail -1 | awk '/[0-9]+$/ {printf "%s\n", $8}'`
comparedouter=`awk '/ STATISTICS OF SAVED DATA SET/,/total/' CORRECT.LP | grep -B 1 "total" | head -1 | awk '/[0-9]+$/ {printf "%s\n", $8}'`
acceptedrefs=`awk /SAVED/,/WILSON/ CORRECT.LP | awk '/NUMBER OF ACCEPTED OBSERVATIONS/ {printf "%s\n", $5}'`
measuredrefs=`awk /SAVED/,/WILSON/ CORRECT.LP | awk '/NUMBER OF REFLECTIONS IN SELECTED SUBSET OF IMAGES/ {printf "%s\n", $9}'`
uniquerefs=`awk /SAVED/,/WILSON/ CORRECT.LP | awk '/NUMBER OF UNIQUE ACCEPTED REFLECTIONS/ {printf "%s\n", $6}'`
rejectedrefs=`awk /SAVED/,/WILSON/ CORRECT.LP | awk '/NUMBER OF REJECTED MISFITS/ {printf "%s\n", $5}'`
siganototal=`awk '/ STATISTICS OF SAVED DATA SET/,/total/' CORRECT.LP | grep "total" | tail -1 | awk '/[0-9]+$/ {printf "%3.2f\n", $13}'`
siganoouter=`awk '/ STATISTICS OF SAVED DATA SET/,/total/' CORRECT.LP | grep -B 1 "total" | head -1 | awk '/[0-9]+$/ {printf "%3.2f\n", $13}'`
anomcorrtotal=`awk '/ STATISTICS OF SAVED DATA SET/,/total/' CORRECT.LP | grep "total" | tail -1 | awk '/[0-9]+$/ {printf "%s\n", $12}'`
anomcorrouter=`awk '/ STATISTICS OF SAVED DATA SET/,/total/' CORRECT.LP | grep -B 1 "total" | head -1 | awk '/[0-9]+$/ {printf "%s\n", $12}'`
anompairstotal=`awk '/ STATISTICS OF SAVED DATA SET/,/total/' CORRECT.LP | grep "total" | tail -1 | awk '/[0-9]+$/ {printf "%s\n", $14}'`
anompairsouter=`awk '/ STATISTICS OF SAVED DATA SET/,/total/' CORRECT.LP | grep -B 1 "total" | head -1 | awk '/[0-9]+$/ {printf "%s\n", $14}'`
multiplicity=$(echo "scale=1;$measuredrefs / $uniquerefs"|bc)
isa=`cat CORRECT.LP | awk '/     a        b          ISa/ {getline; printf "%s", $3}'`

echo -e "\
\n### INTEGRATION STATISTICS ###\n
Image range processed:		$totaldataframes
ISa quality statistic:		$isa
Measured intensities:		$measuredrefs
Accepted intensities:		$acceptedrefs
Compared intensities:		$comparedtotal ($comparedouter)
Unique intensities:		$uniquerefs
Rejected intensities:		$rejectedrefs\n"

if [[ $anom == "yes" ]]; then
	echo -e "\
Mean anom difference:		$siganototal ($siganoouter)
Mean anom correlation:		$anomcorrtotal ($anomcorrouter)
Friedel pairs:			$anompairstotal ($anompairsouter)\n"
fi

exit
