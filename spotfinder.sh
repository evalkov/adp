#! /bin/bash

## checks if previous step resulted in error or it is a grid scan and exits
if [ -e ERROR.LP ] || [ -e GRID_SCAN ]; then
	exit
fi

inpfile=`wc -l XDS.INP | cut -c 1-3`
head -n $inpfile XDS.INP > XDS.INP.002
sed -i '/SPOT_RANGE= /d' XDS.INP.002
sed -i '/JOB= /d' XDS.INP.002
echo "JOB= COLSPOT" >> XDS.INP.002

lastimage=`awk '/DATA_RANGE= / {printf "%s", $3}' XDS.INP | xargs printf "%1.0f"`
if [[ "$lastimage" -gt "50" ]]; then
	firstwedge_firstimage=`awk '/DATA_RANGE= / {printf "%s", $2}' XDS.INP | xargs printf "%1.0f"`
	firstwedge_lastimage=`echo "$firstwedge_firstimage+4" | bc | xargs printf "%1.0f"`
	secondwedge_firstimage=`echo "$lastimage*0.5" | bc | xargs printf "%1.0f"`
	secondwedge_lastimage=`echo "$secondwedge_firstimage+5" | bc | xargs printf "%1.0f"`
	thirdwedge_firstimage=`echo "$lastimage*0.75" | bc | xargs printf "%1.0f"`
	thirdwedge_lastimage=`echo "$thirdwedge_firstimage+5" | bc | xargs printf "%1.0f"`
	fourthwedge_firstimage=`echo "$lastimage-5" | bc | xargs printf "%1.0f"`
	fourthwedge_lastimage=`echo $lastimage | bc | xargs printf "%1.0f"`
else
	firstwedge_firstimage=`awk '/DATA_RANGE= / {printf "%s", $2}' XDS.INP | xargs printf "%1.0f"`
	firstwedge_lastimage=`echo "$lastimage*0.25" | bc | xargs printf "%1.0f"`
	secondwedge_firstimage=`echo "$firstwedge_lastimage+1" | bc | xargs printf "%1.0f"`
	secondwedge_lastimage=`echo "$lastimage*0.5" | bc | xargs printf "%1.0f"`
	thirdwedge_firstimage=`echo "$secondwedge_lastimage+1" | bc | xargs printf "%1.0f"`
	thirdwedge_lastimage=`echo "$lastimage*0.75" | bc | xargs printf "%1.0f"`
	fourthwedge_firstimage=`echo "$thirdwedge_lastimage+1" | bc | xargs printf "%1.0f"`
	fourthwedge_lastimage=`echo $lastimage | bc | xargs printf "%1.0f"`
fi

echo "SPOT_RANGE= $firstwedge_firstimage $firstwedge_lastimage" >> XDS.INP.002
echo "SPOT_RANGE= $secondwedge_firstimage $secondwedge_lastimage" >> XDS.INP.002
echo "SPOT_RANGE= $thirdwedge_firstimage $thirdwedge_lastimage" >> XDS.INP.002
echo "SPOT_RANGE= $fourthwedge_firstimage $fourthwedge_lastimage" >> XDS.INP.002
cp XDS.INP.002 XDS.INP

echo -e "\
\n### REFLECTION POSITION ANALYSIS ###\n"

xds_par | awk '\
/SPOT_RANGE=/ {
	printf "[%s-%s] ", $2, $3
}
BEGIN {
	printf "Image range(s):		"
}
/NUMBER OF DIFFRACTION SPOTS LOCATED/ {
    sum1+=$6
}
    END {
    printf "\nReflections found:	%s\n", sum1
}
/IGNORED BECAUSE OF SPOT MAXIMUM OUT OF CENTER/ {
    sum2+=$9
}
    END {
    printf "Out-of-centre:		%s\n", sum2
}
/IGNORED BECAUSE OF SPOT CLOSE TO UNTRUSTED REGION/ {
    sum3+=$9
}
    END {
    printf "In untrusted region:	%s\n", sum3
}
/WEAK SPOTS OMITTED/ {
    sum4+=$4
}
    END {
    printf "Rejected as weak:	%s\n", sum4
}
/NUMBER OF DIFFRACTION SPOTS ACCEPTED/ {
    sum5+=$6
}
    END {
    printf "Reflections used:	%s\n", sum5
}
'

# This checks for errors during the spotfinding step and stops the script, if errors found
checkerror=`awk '/!!! ERROR /' COLSPOT.LP`
finish_check=`awk '/wall-clock/ { printf "%s", $1 }' COLSPOT.LP`

if [[ "$checkerror" && "$finish_check" ]]; then
    echo -e "\n*******************************************************************************"
    echo -e "*** XDS encountered a serious error during reflection analysis and stopped! ***"
    echo -e "*******************************************************************************\n"
    echo -e "$checkerror\n"
elif [[ "$checkerror" && ! "$finish_check" ]]; then
    echo -e "\n*******************************************************************************"
    echo -e "*** XDS encountered a serious error during reflection analysis and stopped! ***"
    echo -e "*******************************************************************************\n"
    echo -e "$checkerror\n"
	cat COLSPOT.LP > ERROR.LP
	exit
fi

