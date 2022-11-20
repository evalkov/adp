#! /bin/bash

# checks if previous step resulted in error or it is a grid scan and exits
if [ -e ERROR.LP ] || [ -e GRID_SCAN ]; then
	exit
fi

if [ -e IDXREF.LP ]; then
    rm -rf IDXREF.LP
fi

inpfile=`wc -l XDS.INP | cut -c 1-3`
head -n $inpfile XDS.INP > XDS.INP.003
sed -i '/TRUSTED_REGION= /d' XDS.INP.003

sed -i '/JOB= /d' XDS.INP.003
echo "JOB= IDXREF" >> XDS.INP.003
echo "TRUSTED_REGION= 0.0 0.98" >> XDS.INP.003

cp XDS.INP.003 XDS.INP

xds_par > /dev/null &

while [ 1 ]; do
    [ ! -e IDXREF.LP ] && sleep 1 || break
done

# The following routine will reset the beam centre to image centre - not normally needed????
#if [ -e IDXREF.LP ]; then
#    rm -rf IDXREF.LP
#fi

#sed -i '/ORGX= /d' XDS.INP.003
#nx=`awk '/NX=/ { printf "%s", $2 }' XDS.INP.003`
#ny=`awk '/NX=/ { printf "%s", $4 }' XDS.INP.003`
#new_orgx=`echo "scale=2; $nx/2" | bc | awk '{printf "%2.2f\n",$1}'`
#new_orgy=`echo "scale=2; $ny/2" | bc | awk '{printf "%2.2f\n",$1}'`
#echo "ORGX= $new_orgx ORGY= $new_orgy" >> XDS.INP.003
#cp XDS.INP.003 XDS.INP

#xds_par > /dev/null &
#while [ 1 ]; do
#    [ ! -e IDXREF.LP ] && sleep 1 || break
#done

# This checks for errors during the indexing step and stops the script, if errors found
while [ 1 ]; do
    checkerror=`awk '/!!! ERROR /' IDXREF.LP`
    badindexing=`awk '/!!! ERROR !!! INSUFFICIENT PERCENTAGE /' IDXREF.LP`
    # This checks if indexing has finished normally
    finish_check=`awk '/wall-clock/ { printf "%s", $1 }' IDXREF.LP`
    if [[ "$checkerror" && ! "$badindexing" ]]; then
        echo -e "\n********************************************************************"
        echo -e "*** XDS encountered a serious error during indexing and stopped! ***"
        echo -e "********************************************************************\n"
        echo -e "$checkerror\n"
	    cat IDXREF.LP > ERROR.LP
	    exit
    else
        [[ ! $finish_check == "elapsed" ]] && sleep 1 || break
    fi
done

if [[ "$badindexing" ]]; then
    echo -e "\n*********************************************************"
    echo -e "*** XDS indexing solution is unlikely to be accurate! ***"
    echo -e "*********************************************************\n"
fi

unitcelledges=`grep -B 15 "DETERMINATION OF LATTICE CHARACTER AND BRAVAIS LATTICE" IDXREF.LP | awk '/UNIT CELL PARAMETERS/ {printf "%4.2f %4.2f %4.2f", $4, $5, $6}'`
unitcellangles=`grep -B 15 "DETERMINATION OF LATTICE CHARACTER AND BRAVAIS LATTICE" IDXREF.LP | awk '/UNIT CELL PARAMETERS/ {printf "%4.2f %4.2f %4.2f", $7, $8, $9}'`
spacegroupnum=`tail -500 IDXREF.LP | grep -B 5 "DETERMINATION OF LATTICE CHARACTER AND BRAVAIS LATTICE" | awk '/SPACE GROUP/ {printf "%s",$4}'`
indexed_refs=`tail -500 IDXREF.LP | grep -B 10 "DIFFRACTION PARAMETERS USED AT START OF INTEGRATION" | awk '/SPOTS INDEXED/ {printf "%s", $1}'` 
total_refs=`tail -500 IDXREF.LP | grep -B 10 "DIFFRACTION PARAMETERS USED AT START OF INTEGRATION" | awk '/SPOTS INDEXED/ {printf "%s", $4}'`
percentage_indexed_refs=`echo "($indexed_refs/$total_refs)*100" | bc -l | awk '{ printf "%.2f",$0 }'`
# autoindexrefs=`tail -500 IDXREF.LP | grep -B 10 "DIFFRACTION PARAMETERS USED AT START OF INTEGRATION" | awk '/SPOTS INDEXED/ {printf "%s/%s (%3.1f%)\n", $1, $4, (100 * $1)/$4}'`
refesd=`tail -500 IDXREF.LP | grep -A 20 "DIFFRACTION PARAMETERS USED" | awk '/STANDARD DEVIATION OF SPOT    POSITION/ {printf "%s\n", $7}'`
spindleesd=`tail -500 IDXREF.LP | grep -A 20 "DIFFRACTION PARAMETERS USED" | awk '/STANDARD DEVIATION OF SPINDLE POSITION/ {printf "%s\n", $7}'`
beamcentrex=`tail -500 IDXREF.LP | awk '/ ORGX=/ {printf "%s", $2}'`
beamcentrey=`tail -500 IDXREF.LP | awk '/ ORGY=/ {printf "%s", $4}'`
shifted_beamcentrex=`tail -500 IDXREF.LP | grep -A 20 "DIFFRACTION PARAMETERS USED" | awk '/DETECTOR COORDINATES/ { printf "%s\n", $7}'`
shifted_beamcentrey=`tail -500 IDXREF.LP | grep -A 20 "DIFFRACTION PARAMETERS USED" | awk '/DETECTOR COORDINATES/ { printf "%s\n", $8}'`
shift_in_x=`echo $beamcentrex-$shifted_beamcentrex | bc`
shift_in_y=`echo $beamcentrey-$shifted_beamcentrey | bc`
qx=`tail -500 IDXREF.LP | awk '/QX=/ {printf "%s", $6}'`
qy=`tail -500 IDXREF.LP | awk '/QX=/ {printf "%s", $8}'`
shift_in_x_mm=`echo "scale=2; $shift_in_x*$qx" | bc | awk '{printf "%2.2f\n",$1}' | sed 's/-//g'`
shift_in_y_mm=`echo "scale=2; $shift_in_y*$qy" | bc | awk '{printf "%2.2f\n",$1}' | sed 's/-//g'`
total_beamshift=`echo "scale=2; $shift_in_x_mm+$shift_in_y_mm" | bc`
indexorigins=`sed -n '/INDEX_ /,/SELECTED/p' IDXREF.LP | grep -c [.]`
indexsolslist=`tail -500 IDXREF.LP | sed -n '/INDEX_ /,/SELECTED/p' | grep [.] | awk '/./ {printf "%3d %3d %3d  %9.1f  %9.1f  %8.2f %8.2f\n", $1, $2, $3, $4, $5, $6, $7}'`
selectedindex=`tail -500 IDXREF.LP | awk '/SELECTED:     INDEX_ORIGIN= / {printf "%1d, %1d, %1d\n", $1, $2, $3}'`
maxcelldev=`tail -500 IDXREF.LP | awk '/MAXIMUM_ALLOWED_CELL_AXIS_RELATIVE_ERROR=/ {printf "%4.2f\n", $2}'`
maxangleerorr=`tail -500 IDXREF.LP | awk '/MAXIMUM_ALLOWED_CELL_ANGLE_ERROR=/ {printf "%3.1f\n", $2}'`
possiblelattices=`sed -n '/LATTICE-/,/For/p' IDXREF.LP | awk '/[0-9]/' | grep '*' | awk '{ printf "   %s %9.1f %7.1f %7.1f %7.1f %7.1f %7.1f %7.1f\n", $3, $4, $5, $6, $7, $8, $9, $10 }'`

echo -e "\
\n### INDEXING ###\n
Unit cell edges (A): 			$unitcelledges
Unit cell angles (deg):			$unitcellangles
Autoindexing reflections: 		$indexed_refs/$total_refs ($percentage_indexed_refs%)
Reflection prediction ESD (pixel): 	$refesd
Spindle position ESD (deg):		$spindleesd
Shift in beam position (mm):		$total_beamshift	
Number of origin index solutions:	$indexorigins
\nIndexing origin ranking:\n
    origin        score      shift     beam centre
-----------------------------------------------------
$indexsolslist
-----------------------------------------------------

Selected index origin (h,k,l): $selectedindex

Maximum allowed deviation in cell axis (A): 	$maxcelldev
Maximum allowed deviation in cell angles (deg): $maxangleerorr"

#Note that integration depends only on the orientation and metric of the lattice
#By default in XDS integration will be carried out in triclinic setting using all reflections

#here decide if started from interactive or automated procedure call this script by issuing "indexer.sh -i"

if [[ $1 == "" ]]; then
    if [ "$possiblelattices" ]; then
	    echo -e "\
\nLattices consistent with the observed reflections:

 lattice   score     a       b      c      alpha   beta    gamma
-----------------------------------------------------------------
$possiblelattices
-----------------------------------------------------------------\n" 
    else
        echo -e "	*** XDS failed to index the data. Have a look in IDXREF.LP ***"
        echo -e "\nNo lattices consistent with the observed locations of the diffraction spots."
    fi
else
	echo -e "Set the space group and cell dimensions at this stage? [y/N]: \c"
	read spacegroup
	if [[ $spacegroup == "N" || $spacegroup == "No" || $spacegroup == "no" || $spacegroup == "n" || $spacegroup == "" ]]; then
		echo -e "\nWill integrate in triclinic setting using all reflections.\n"
	else
	    if [ "$possiblelattices" ]; then
		    echo -e "\
\nLattices consistent with the observed reflections:

 lattice   score     a       b      c      alpha   beta    gamma
-----------------------------------------------------------------
$possiblelattices
-----------------------------------------------------------------\n"
   		else
            echo -e "	*** XDS failed to index the data. Have a look in IDXREF.LP ***"
            echo -e "\nNo lattices consistent with the observed locations of the diffraction spots."
        fi
   		echo -e "\nPlease specify the space group number e.g. 5: \c"
   		read sgnum 
   		echo -e "You have chosen $sgnum." | tee -a $log
   		echo -e "\
\nSpace group geometric constraints:\n
Monoclinic (unique b-axis; alpha/gamma = 90)
Orthorhombic (all angles are 90)
Tetragonal (a-axis = b-axis; all angles are 90)
Hexagonal (a-axis = b-axis; alpha/beta = 90; gamma = 120)
Rhombohedral (axis and angles all equal)
Cubic (all axis equal and all angles are 90)" | tee -a $log
   		echo -e "\nPlease enter the new cell parameters e.g. 80 80 60 90 90 90: \c"
		read newcell
   		echo -e "The new cell parameters are $newcell" | tee -a $log
	fi
fi

