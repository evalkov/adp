#! /bin/bash

# checks if previous step resulted in error or it is a grid scan and exits
if [ -e ERROR.LP ] || [ -e GRID_SCAN ]; then
	exit
fi

if [ ! "$1" = "" ]; then
    echo "HEAD" > MTZDUMP.INP
    mtzdump hklin $1 <MTZDUMP.INP > MTZDUMP.LP 2>&1
    xtal=`awk '/project/ { getline; getline; printf "%s", $2 }' MTZDUMP.LP`
    cp $1 $xtal.indexed.mtz
else
    xtal=`ls *.mtz | awk -F ".indexed.mtz" '{ printf "%s", $1 }'`
    while [ 1 ]
    do
        [ ! -e $xtal.indexed.mtz ] && sleep 1 || break
    done
    echo "HEAD" > MTZDUMP.INP
    mtzdump hklin $xtal.indexed.mtz <MTZDUMP.INP > MTZDUMP.LP 2>&1
fi

lores=`awk '/Resolution Range/,/Sort Order/' MTZDUMP.LP | grep -E '[0-9]' | awk '{ print $4 }'`
hires=`awk '/Resolution Range/,/Sort Order/' MTZDUMP.LP | grep -E '[0-9]' | awk '{ print $6 }'`
spacegroup=`awk -F '[(|)]' '/ * Space group = / { print $1 }' MTZDUMP.LP | awk -F\' '{print $2}'| sed 's/ //g'`
spacegroupnum=`awk -F '[(|)]' '/ * Space group = / { print $2 }' MTZDUMP.LP | awk '{ printf "%s", $2}'`

echo "\
name project $xtal crystal $xtal dataset $xtal
resolution low $lores high $hires
onlymerge
refine parallel 8
" > SCALA.INP

aimless hklin $xtal.indexed.mtz hklout $xtal.scaled.mtz < SCALA.INP > SCALA.LP 2>&1

while [ 1 ]
do
    [ ! -e SCALA.LP ] && sleep 1 || break
done

negativescales=`awk '/Negative scale/' SCALA.LP`
noobservations=`awk '/No observations/' SCALA.LP`

if [ "$negativescales" ]; then
	echo -e "Scaling failed due to 'negative scales' error! Will try scaling with damping level set to 0.1."
	echo "filter 1.0e-6, 0.1" >> SCALA.INP
	aimless hklin $xtal.indexed.mtz hklout $xtal.scaled.mtz < SCALA.INP > SCALA.LP 2>&1
elif
	[ "$noobservations" ]; then
	echo -e "Scaling failed due to 'no observations' error. Reducing the threshold for inclusion of weak reflections." 
	echo "exclude sdmin 2" >> SCALA.INP
	aimless hklin $xtal.indexed.mtz hklout $xtal.scaled.mtz < SCALA.INP > SCALA.LP 2>&1
fi

if [ ! -e $xtal.scaled.mtz ]; then
	echo -e "Scaling totally failed. Data must really suck... Have a look at the logs. " | tee -a $log
	exit
fi

checkrescc=`awk '/Estimates of resolution limits: overall/ {getline; printf "%3.2f\n", $9}' SCALA.LP`
checkressigi=`awk '/Estimates of resolution limits: overall/ {getline; getline; printf "%3.2f\n", $7}' SCALA.LP`

echo -e "New high resolution cut-off:	$checkrescc A."

#re-running scaling/merging with new resolution cutoff
mv SCALA.LP SCALA.LP.001
inpfile=`cat SCALA.INP | wc -l`
head -n $inpfile SCALA.INP > SCALA.INP.001
sed -i '/resolution/d' SCALA.INP.001
echo "resolution low $lores high $checkrescc " >> SCALA.INP.001
cp SCALA.INP.001 SCALA.INP

aimless hklin $xtal.indexed.mtz hklout $xtal.scaled.mtz < SCALA.INP > SCALA.LP   2>&1

while [ 1 ]
do
    [ ! -e SCALA.LP ] && sleep 1 || break
done

negativescales=`awk '/Negative scale/' SCALA.LP`
noobservations=`awk '/No observations/' SCALA.LP`

if [ "$negativescales" ]; then
	echo -e "Scaling failed due to 'negative scales' error! Will try scaling with damping level set to 0.1."
	echo "filter 1.0e-6, 0.1" >> SCALA.INP
	aimless hklin $xtal.indexed.mtz hklout $xtal.scaled.mtz < SCALA.INP > SCALA.LP 2>&1
elif
	[ "$noobservations" ]; then
	echo -e "Scaling failed due to 'no observations' error. Reducing the threshold for inclusion of weak reflections." 
	echo "exclude sdmin 2" >> SCALA.INP
	aimless hklin $xtal.indexed.mtz hklout $xtal.scaled.mtz < SCALA.INP > SCALA.LP 2>&1
fi

while [ 1 ]; do
    [ ! -e SCALA.LP ] && sleep 1 || break
done

aniso_deltab=`grep "Anisotropic deltaB" SCALA.LP | awk 'BEGIN {FS=":"}; {printf "%2.2f\n",$2}'`
approx_deltab=`grep "Anisotropic deltaB" SCALA.LP | awk 'BEGIN {FS=":"}; {printf "%2.0f\n",$2}'`

if [ "$approx_deltab" -gt "10" ] && [ "$approx_deltab" -lt "25" ] || [ "$approx_deltab" -eq "25" ]; then
    echo -e "\nWARNING: Data is mildly anisotropic with anisotropic delta B of $aniso_deltab Angstroms^2."
elif [ "$approx_deltab" -gt "25" ] && [ "$approx_deltab" -lt "50" ] || [ "$approx_deltab" -eq "50" ]; then
    echo -e "\nWARNING: Data is strongly anisotropic with anisotropic delta B of $aniso_deltab Angstroms^2."
    echo -e "Consider ellipsodal truncation and anisotropic scaling of the data."
elif [ "$approx_deltab" -gt "50" ]; then
    echo -e -e "\nWARNING: Data is severely anisotropic with anisotropic delta B of $aniso_deltab Angstroms^2."
    echo -e "Ellipsoidal truncation and anisotropic scaling of the data is strongly advised."
fi


echo "\
truncate -
    YES
end " > TRUNCATE.INP

while [ 1 ]
do
    [ ! -e $xtal.scaled.mtz ] && sleep 1 || break
done

truncate hklin $xtal.scaled.mtz hklout $xtal.$spacegroup.mtz < TRUNCATE.INP > TRUNCATE.LP 2>&1

uniqueify $xtal.$spacegroup.mtz $xtal.$spacegroup\_freeR.mtz > /dev/null 2>&1

if [ -e $xtal.$spacegroup\_freeR.log ]; then
	mv $xtal.$spacegroup\_freeR.log UNIQUEIFY.LP 2>&1
fi

if [ ! -e $xtal.$spacegroup.mtz ] ||  [ ! -e $xtal.$spacegroup\_freeR.mtz ]; then
	echo -e "Scaling totally failed. Data must really suck... Have a look at the logs. "
	exit
fi

scalastats=`awk '/InnerShell/,/anomalous signal/ { print}' SCALA.LP`

if [ ! "$1" = "" ]; then
    echo -e "\

\n               ### DATA PROCESSING STATISTICS ###
\n$scalastats\n"
fi

exit
