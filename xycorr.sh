#! /bin/bash

# checks if previous step resulted in error or it is a grid scan and exits
if [ -e ERROR.LP ] || [ -e GRID_SCAN ]; then
	exit
fi

inpfile=`wc -l XDS.INP | cut -c 1-3`
head -n $inpfile XDS.INP > XDS.INP.001
sed -i '/JOB= /d' XDS.INP.001
echo "JOB= XYCORR INIT" >> XDS.INP.001

cp XDS.INP.001 XDS.INP

echo -e "\
\n### POSITIONAL DETECTOR CORRECTIONS AND BACKGROUND ESTIMATE ###\n"

xds_par | awk '\
/BACKGROUND_RANGE=/ {
    printf "Processing images:	%s - %s\n", $2, $3
}
/MEAN GAIN VALUE/ {
    printf "Mean gain value:	%s\n", $4
}
/MINIMUM GAIN VALUE IN TABLE/ {
    printf "Min table gain: 	%s\n", $6
}
/MAXIMUM GAIN VALUE IN TABLE/ {
    printf "Max table gain: 	%s\n", $6
}
/AVERAGE BACKGROUND COUNTS/ {
    printf "Mean background: 	%s\n", $9
}
'
# This checks for errors during the xycorr step and stops the script, if errors found
checkerror=`awk '/!!! ERROR !!!/' XYCORR.LP`
checkerror1=`awk '/!!! ERROR !!!/' INIT.LP`

if [[ "$checkerror" || "$checkerror1" ]]; then
    echo -e "\n*********************************************************************************"
    echo -e "*** XDS encountered a serious error during backgroudn estimation and stopped! ***"
    echo -e "*********************************************************************************\n"
    echo -e "$checkerror\n" || echo -e "$checkerror1\n"
	cat XYCORR.LP > ERROR.LP
	cat INIT.LP >> ERROR.LP
	exit
fi
