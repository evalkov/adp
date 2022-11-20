#! /bin/bash

# obtain some description of the dataset

#### IMPORTANT ### must modify to cope with x_1_????.xxx and x_1_???.xxxxx type formats

#    image_extension=`echo $image | sed 's/.*\.//'`
#    image_number=`echo $image | sed 's/.*_\(.*\).*/\1/' | sed 's/\..\{3\}$//'`
#    image_prefix=`echo $image | sed "s/$image_number.$image_extension*$//" >> prefix_list`


# a good feature to have will be to extract information for processing if XDS.INP is provided
# make this a command line argument to be passed into the wrapper script?

image=`ls images | head -1`
extension=`echo $image | sed 's/.*\.//'`
extension_length=`printf $extension | wc -c`
totalframes=`ls images | awk 'BEGIN{FS="."} END {for (i=2; i<=NF; i++); print NR}'`
image_number=`echo $image | sed 's/.*_\(.*\).*/\1/' | sed 's/\..\{'$extension_length'\}$//'`
image_number_digits=`printf $image | sed 's/.*_\(.*\).*/\1/' | sed 's/\..\{'$extension_length'\}$//' | wc -c`
if [[ $image_number_digits == "3" ]]; then
	digits="???"
elif [[ $image_number_digits == "4" ]]; then
	digits="????"
elif [[ $image_number_digits == "5" ]]; then
    digits="?????"
fi
firstimage=`ls images | sort | head -1 | sed 's/.*_\(.*\).*/\1/' | sed 's/\..\{'$extension_length'\}$//'`
firstframe=` echo $firstimage | bc`
lastimage=`ls images | sort | tail -1 | sed 's/.*_\(.*\).*/\1/' | sed 's/\..\{'$extension_length'\}$//'`
lastframe=`echo $lastimage | bc`
imagename=`echo $image | sed "s/$image_number.$extension*$//"`
project=`echo $PWD | sed 's!.*/!!'`
lastbackground=`echo $firstimage+5 | bc`
background_first=`echo $firstimage | bc`
background_last=`echo $firstimage+4 | bc`

if [[ $extension == "mar1600" ]]; then
	detectortype=`head -n 50 images/"$imagename""$firstimage"."$extension" | awk '/PROGRAM/ {split($0,a," "); print a[2]}'`
	detectorsize="NX=1600 NY=1600 QX=0.15 QY=0.15"
	detector="MAR345"
	pixelsize="0.15"
	strongpix="7"
	polarisation="0.99"
	minvalidpixel="0"
	overload="130000"
	rotaxis="1 0 0"
	trustedpixels="7000 30000"
	trustedregion="0.0 1.42"
	beamcentrex=`head -n 50 images/"$imagename""$firstimage"."$extension" | awk '/CENTER/ {split($0,a," "); print a[3]}'`
	beamcentrey=`head -n 50 images/"$imagename""$firstimage"."$extension" | awk '/CENTER/ {split($0,a," "); print a[5]}'`
	beamcentrexmm=`echo "scale=2; $beamcentrex*$pixelsize" | bc | awk '{printf "%2.2f\n",$1}'`
	beamcentreymm=`echo "scale=2; $beamcentrey*$pixelsize" | bc | awk '{printf "%2.2f\n",$1}'`
	wavelength=`head -n 50 images/"$imagename""$firstimage"."$extension" | awk '/WAVELENGTH/ {split($0,a," "); print a[2]}'`
	deltaphi=`head -n 50 images/"$imagename""$firstimage"."$extension" | awk '/PHI/ {split($0,a," "); printf "%3.2f", a[7]}'`
	phi=`head -n 50 images/"$imagename""$firstimage"."$extension" | awk '/PHI/ {split($0,a," "); printf "%3.2f", a[3]}'`
	distance=`head -n 50 images/"$imagename""$firstimage"."$extension" | awk '/DISTANCE/ {split($0,a," "); print a[2]}'`
elif  [[ $extension == "mar2300" ]]; then
	detectortype=`head -n 50 images/"$imagename""$firstimage"."$extension" | awk '/PROGRAM/ {split($0,a," "); print a[2]}'`
	detectorsize="NX=2300 NY=2300 QX=0.15 QY=0.15"
	detector="MAR345"
	pixelsize="0.15"
	strongpix="7"
	polarisation="0.5"
	minvalidpixel="0"	
	overload="130000"
	rotaxis="1 0 0"
	trustedpixels="7000 30000"
	trustedregion="0.0 1.2"
	beamcentrex=`head -n 50 images/"$imagename""$firstimage"."$extension" | awk '/CENTER/ {split($0,a," "); print a[3]}'`
	beamcentrey=`head -n 50 images/"$imagename""$firstimage"."$extension" | awk '/CENTER/ {split($0,a," "); print a[5]}'`
	beamcentrexmm=`echo "scale=2; $beamcentrex*$pixelsize" | bc | awk '{printf "%2.2f\n",$1}'`
	beamcentreymm=`echo "scale=2; $beamcentrey*$pixelsize" | bc | awk '{printf "%2.2f\n",$1}'`
	wavelength=`head -n 50 images/"$imagename""$firstimage"."$extension" | awk '/WAVELENGTH/ {split($0,a," "); print a[2]}'`
	deltaphi=`head -n 50 images/"$imagename""$firstimage"."$extension" | awk '/PHI/ {split($0,a," "); print a[7]}'`
	phi=`head -n 50 images/"$imagename""$firstimage"."$extension" | awk '/PHI/ {split($0,a," "); print a[3]}'`
	distance=`head -n 50 images/"$imagename""$firstimage"."$extension" | awk '/DISTANCE/ {split($0,a," "); print a[2]}'`
elif [[ $extension == "img" ]]; then
	distance=` head -n 30 images/"$imagename""$firstimage".img | awk /DISTANCE/ | awk 'BEGIN {FS="="}; {printf "%3.2f\n",$2}'`
	wavelength=` head -n 30 images/"$imagename""$firstimage".img  | awk /WAVELENGTH/ | awk 'BEGIN {FS="="}; {printf "%3.6f\n",$2}'`
	deltaphi=` head -n 30 images/"$imagename""$firstimage".img  | awk /OSC_RANGE/ | awk 'BEGIN {FS="="}; {printf "%3.1f\n",$2}'`
	detectorserial=` head -n 30 images/"$imagename""$firstimage".img | awk /DETECTOR_SN/ | awk 'BEGIN {FS="="}; {printf "%3d\n",$2}'`
	phi=` head -n 30 images/"$imagename""$firstimage".img | awk /OSC_START/ | awk 'BEGIN {FS="="}; {printf "%3.1f\n",$2}'`
	if [ $detectorserial = 928 ]; then
		beamline="MX2 - Australian Synchrotron"
		detectortype="ADSC Quantum 315"
		detector="ADSC"
		detectorsize="NX=3072 NY=3072 QX=0.1024 QY=0.1024"
		pixelsize=`head -n 20 images/"$imagename""$firstimage".img | awk /PIXEL_SIZE/ | awk 'BEGIN {FS="="}; {printf "%3.6f\n",$2}'`
		strongpix="6"
		polarisation="0.99"
		minvalidpixel="1"	
		overload="65000"
		rotaxis="-1 0 0"
		trustedpixels="6000 90000"
		trustedregion="0.0 1.05"
		beamcentrex="1568"
		beamcentrexmm=`echo "scale=2; $beamcentrex*$pixelsize" | bc | awk '{printf "%2.2f\n",$1}'`
		beamcentrey="1517"
		beamcentreymm=`echo "scale=2; $beamcentrey*$pixelsize" | bc | awk '{printf "%2.2f\n",$1}'`
	elif [ $detectorserial = 457 ]; then
		beamline="MX1 - Australian Synchrotron"
		detectortype="ADSC Quantum 210r"
		detector="ADSC"
		detectorsize="NX=2048 NY=2048 QX=0.1024 QY=0.1024"
		pixelsize=`head -n 20 images/"$imagename""$firstimage".img | awk /PIXEL_SIZE/ | awk 'BEGIN {FS="="}; {printf "%3.6f\n",$2}'`
		strongpix="6"
		polarisation="0.99"
		minvalidpixel="1"	
		overload="65000"
		rotaxis="-1 0 0"
		trustedpixels="6000 90000"
		trustedregion="0.0 1.05"
		beamcentrex="1022.56" 
		beamcentrexmm=`echo "scale=2; $beamcentrex*$pixelsize" | bc | awk '{printf "%2.2f\n",$1}'`
		beamcentrey="1019.82"
		beamcentreymm=`echo "scale=2; $beamcentrey*$pixelsize" | bc | awk '{printf "%2.2f\n",$1}'`
	elif [ $detectorserial = 918 ]; then
		beamline="ID29 - ESRF"
		detectortype="ADSC Quantum 315"
		detector="ADSC"
		detectorsize="NX=3072 NY=3072 QX=0.1024 QY=0.1024"
		pixelsize=`head -n 20 images/"$imagename""$firstimage".img | awk /PIXEL_SIZE/ | awk 'BEGIN {FS="="}; {printf "%3.6f\n",$2}'`
		strongpix="6"
		polarisation="0.99"
		minvalidpixel="1"	
		overload="65000"
		rotaxis="1 0 0"
		trustedpixels="6000 90000"
		trustedregion="0.0 1.05"
		beamcentrex="1520.36"
		beamcentrexmm=`echo "scale=2; $beamcentrex*$pixelsize" | bc | awk '{printf "%2.2f\n",$1}'`
		beamcentrey="1544.76"
		beamcentreymm=`echo "scale=2; $beamcentrey*$pixelsize" | bc | awk '{printf "%2.2f\n",$1}'`
	elif [ $detectorserial = 917 ]; then	
		beamline="ID23-1 - ESRF"
		detectortype="ADSC Quantum 315r"
		detector="ADSC"
		detectorsize="NX=3072 NY=3072 QX=0.1026 QY=0.1026"
		pixelsize=`head -n 20 images/"$imagename""$firstimage".img | awk /PIXEL_SIZE/ | awk 'BEGIN {FS="="}; {printf "%3.6f\n",$2}'`
		strongpix="6"
		polarisation="0.98"
		minvalidpixel="1"	
		overload="65000"
		rotaxis="1 0 0"
		trustedpixels="7000 30000"
		trustedregion="0.0 1.40"
		beamcentrex="1556.76"
		beamcentrexmm=`echo "scale=2; $beamcentrex*$pixelsize" | bc | awk '{printf "%2.2f\n",$1}'`
		beamcentrey="1552.30"
		beamcentreymm=`echo "scale=2; $beamcentrey*$pixelsize" | bc | awk '{printf "%2.2f\n",$1}'`
	elif [ $detectorserial = 927 ]; then
		beamline="PROXIMA-1 - Soleil"
		detectortype="ADSC Quantum 315"
		detector="ADSC"
		detectorsize="NX=3072 NY=3072 QX=0.1024 QY=0.1024"
		pixelsize=`head -n 20 images/"$imagename""$firstimage".img | awk /PIXEL_SIZE/ | awk 'BEGIN {FS="="}; {printf "%3.6f\n",$2}'`
		strongpix="7"
		polarisation="0.99"
		minvalidpixel="1"	
		overload="65000"
		rotaxis="1 0 0"
		trustedpixels="6000 90000"
		trustedregion="0.0 1.05"
		beamcentrex="1540.04"
		beamcentrexmm=`echo "scale=2; $beamcentrex*$pixelsize" | bc | awk '{printf "%2.2f\n",$1}'`
		beamcentrey="1523.05"
		beamcentreymm=`echo "scale=2; $beamcentrey*$pixelsize" | bc | awk '{printf "%2.2f\n",$1}'`
	elif [ $detectorserial = 921 ]; then
		beamline="I04 - DLS"
		detectortype="ADSC Quantum 315"
		detector="ADSC"
		detectorsize="NX=3072 NY=3072 QX=0.1024 QY=0.1024"
		pixelsize=`head -n 20 images/"$imagename""$firstimage".img | awk /PIXEL_SIZE/ | awk 'BEGIN {FS="="}; {printf "%3.6f\n",$2}'`
		strongpix="7"
		polarisation="0.99"
		minvalidpixel="1"	
		overload="65000"
		rotaxis="1 0 0"
		trustedpixels="6000 90000"
		trustedregion="0.0 1.05"
		beamcentrex="1530"
		beamcentrexmm=`echo "scale=2; $beamcentrex*$pixelsize" | bc | awk '{printf "%2.2f\n",$1}'`
		beamcentrey="1530"
		beamcentreymm=`echo "scale=2; $beamcentrey*$pixelsize" | bc | awk '{printf "%2.2f\n",$1}'`
    fi
elif [[ $extension == "cbf" ]]; then
	distancem=`head -n 40 images/"$imagename""$firstimage".cbf | awk '/Detector_distance/ {printf "%3.3f\n",$3}'`
	distance=`echo "scale=2; $distancem*1000" | bc`
	wavelength=`head -n 40 images/"$imagename""$firstimage".cbf  | awk '/Wavelength/ {printf "%3.4f\n",$3}'`
	deltaphi=`head -n 40 images/"$imagename""$firstimage".cbf  | awk '/Angle_increment/ {printf "%3.2f\n",$3}'`
	detectorserial=`head -n 40 images/"$imagename""$firstimage".cbf  | awk -F "S/N" '/S\/N/ {printf "%s\n",$2}'  | sed 's/^[ \t]*//;s/[ \t]*$//' | cut -c 1-7` # | awk -F "," '{ printf "%s", $1}' | awk '{ sub(/^[ \t]+/, ""); print }'`
	phi=`head -n 40 images/"$imagename""$firstimage".cbf | awk '/Start_angle/ {printf "%3.2f\n",$3}'`
    coll_date=`head -n 40 images/"$imagename""$firstimage".cbf | grep "# 20" | cut -c 3-12`
    if [ $detectorserial = 60-0102 ]; then
        beamline="PXII/X10SA - SLS"
        detectortype="PILATUS 6M"
        detector="PILATUS"
        detectorsize="NX=2463 NY=2527 QX=0.172000 QY=0.172000"
        pixel=`head -n 40 images/"$imagename""$firstimage".cbf | awk '/Pixel_size / {printf "%3.6f\n",$3}'`
        pixelsize=`echo "scale=2; $pixel*1000" | bc`
        strongpix="6"
        polarisation="0.99"
        minvalidpixel="0"
        overload="1048500"
        rotaxis="1 0 0"
        trustedpixels="7000 30000"
        trustedregion="0.0 1.41"
        beamcentrex=`head -n 40 images/"$imagename""$firstimage".cbf | awk '/Beam_xy/' | awk 'BEGIN {FS="("}; {printf "%3.2f\n",$2}'`
        beamcentrexmm=`echo "scale=2; $beamcentrex*$pixelsize" | bc | awk '{printf "%2.2f\n",$1}'`
        beamcentrey=`head -n 40 images/"$imagename""$firstimage".cbf | awk '/Beam_xy/' | awk 'BEGIN {FS=","}; {printf "%3.2f\n",$2}'`
        beamcentreymm=`echo "scale=2; $beamcentrey*$pixelsize" | bc | awk '{printf "%2.2f\n",$1}'`
    elif [ $detectorserial = 60-0114 ]; then
		beamline="I02 - DLS"
		detectortype="PILATUS 6M-F"
		detector="PILATUS"
		detectorsize="NX=2463 NY=2527 QX=0.172000 QY=0.172000"
		pixel=`head -n 40 images/"$imagename""$firstimage".cbf | awk '/Pixel_size / {printf "%3.6f\n",$3}'`
		pixelsize=`echo "scale=2; $pixel*1000" | bc`
	    	strongpix="6"
		polarisation="0.99"
	   	minvalidpixel="0"
	    	overload="1048500"
	    	rotaxis="1 0 0"
		trustedpixels="7000 30000"
	    	trustedregion="0.0 1.41"
	   	beamcentrex=`head -n 40 images/"$imagename""$firstimage".cbf | awk '/Beam_xy/' | awk 'BEGIN {FS="("}; {printf "%3.2f\n",$2}'`
		beamcentrexmm=`echo "scale=2; $beamcentrex*$pixelsize" | bc | awk '{printf "%2.2f\n",$1}'`
		beamcentrey=`head -n 40 images/"$imagename""$firstimage".cbf | awk '/Beam_xy/' | awk 'BEGIN {FS=","}; {printf "%3.2f\n",$2}'`
		beamcentreymm=`echo "scale=2; $beamcentrey*$pixelsize" | bc | awk '{printf "%2.2f\n",$1}'`
	elif [ $detectorserial = 60-0100 ]; then
		beamline="I24 - DLS"
		detectortype="PILATUS 6M"
		detector="PILATUS"
		detectorsize="NX=2463 NY=2527 QX=0.172000 QY=0.172000"
		pixel=`head -n 40 images/"$imagename""$firstimage".cbf | awk '/Pixel_size / {printf "%3.6f\n",$3}'`
		pixelsize=`echo "scale=2; $pixel*1000" | bc`
	    	strongpix="6"
		polarisation="0.99"
	   	minvalidpixel="0"
	    	overload="1048500"
	    	rotaxis="1 0 0"
		trustedpixels="7000 30000"
	    	trustedregion="0.0 1.41"
	   	beamcentrex=`head -n 40 images/"$imagename""$firstimage".cbf | awk '/Beam_xy/' | awk 'BEGIN {FS="("}; {printf "%3.2f\n",$2}'`
		beamcentrexmm=`echo "scale=2; $beamcentrex*$pixelsize" | bc | awk '{printf "%2.2f\n",$1}'`
		beamcentrey=`head -n 40 images/"$imagename""$firstimage".cbf | awk '/Beam_xy/' | awk 'BEGIN {FS=","}; {printf "%3.2f\n",$2}'`
		beamcentreymm=`echo "scale=2; $beamcentrey*$pixelsize" | bc | awk '{printf "%2.2f\n",$1}'`
	elif [ $detectorserial = 60-0104 ]; then	
		beamline="ID29 - ESRF"
		detectortype="PILATUS 6M"
		detector="PILATUS"
		detectorsize="NX=2463 NY=2527 QX=0.17200 QY=0.17200"
		pixel=`head -n 40 images/"$imagename""$firstimage".cbf | awk '/Pixel_size / {printf "%3.6f\n",$3}'`
		pixelsize=`echo "scale=2; $pixel*1000" | bc`
	    	strongpix="6"
		polarisation="0.98"
	   	minvalidpixel="0"
	  	overload="1048500"
	    	rotaxis="1 0 0"
		trustedpixels="7000 30000"
	    	trustedregion="0.0 1.41"
	   	beamcentrex=`head -n 40 images/"$imagename""$firstimage".cbf | awk '/Beam_xy/' | awk 'BEGIN {FS="("}; {printf "%3.2f\n",$2}'`
		beamcentrexmm=`echo "scale=2; $beamcentrex*$pixelsize" | bc | awk '{printf "%2.2f\n",$1}'`
		beamcentrey=`head -n 40 images/"$imagename""$firstimage".cbf | awk '/Beam_xy/' | awk 'BEGIN {FS=","}; {printf "%3.2f\n",$2}'`
		beamcentreymm=`echo "scale=2; $beamcentrey*$pixelsize" | bc | awk '{printf "%2.2f\n",$1}'`
	elif [ $detectorserial = 24-0107 ]; then
		beamline="I04-1 - DLS"
		detectortype="PILATUS 2M"
		detector="PILATUS"
		detectorsize="NX=  1475 NY=  1679 QX= 0.17200 QY= 0.17200"
		pixel=`head -n 40 images/"$imagename""$firstimage".cbf | awk '/Pixel_size / {printf "%3.6f\n",$3}'`
		pixelsize=`echo "scale=2; $pixel*1000" | bc`
	    	strongpix="6"
		polarisation="0.99"
	   	minvalidpixel="0"
	    	overload="1048500"
	    	rotaxis="1 0 0"
		trustedpixels="6000 30000"
	    	trustedregion="0.0 1.41"
	   	beamcentrex=`head -n 40 images/"$imagename""$firstimage".cbf | awk '/Beam_xy/' | awk 'BEGIN {FS="("}; {printf "%3.2f\n",$2}'`
		beamcentrexmm=`echo "scale=2; $beamcentrex*$pixelsize" | bc | awk '{printf "%2.2f\n",$1}'`
		beamcentrey=`head -n 40 images/"$imagename""$firstimage".cbf | awk '/Beam_xy/' | awk 'BEGIN {FS=","}; {printf "%3.2f\n",$2}'`
		beamcentreymm=`echo "scale=2; $beamcentrey*$pixelsize" | bc | awk '{printf "%2.2f\n",$1}'`
	elif [ $detectorserial = 60-0105 ]; then
		beamline="I03 - DLS"
		detectortype="PILATUS 6M-F"
		detector="PILATUS"
		detectorsize="NX= 2463 NY= 2527 QX= 0.172  QY= 0.1720"
		pixel=`head -n 40 images/"$imagename""$firstimage".cbf | awk '/Pixel_size / {printf "%3.6f\n",$3}'`
		pixelsize=`echo "scale=2; $pixel*1000" | bc`
	    strongpix="6"
		polarisation="0.99"
	   	minvalidpixel="0"
		min_spot_pixels="3"
		sensor_thickness="0.32"
		rotaxis="1 0 0"
		overload="1048500"
		trustedregion="0.0 1.15"
		trustedpixels="7000 30000"
		beamcentrex=`head -n 40 images/"$imagename""$firstimage".cbf | awk '/Beam_xy/' | awk 'BEGIN {FS="("}; {printf "%3.2f\n",$2}'`
		beamcentrexmm=`echo "scale=2; $beamcentrex*$pixelsize" | bc | awk '{printf "%2.2f\n",$1}'`
		beamcentrey=`head -n 40 images/"$imagename""$firstimage".cbf | awk '/Beam_xy/' | awk 'BEGIN {FS=","}; {printf "%3.2f\n",$2}'`
		beamcentreymm=`echo "scale=2; $beamcentrey*$pixelsize" | bc | awk '{printf "%2.2f\n",$1}'`
	fi
elif [[ $extension == "mccd" ]]; then
	detector="CCDCHESS" 
	detectortype="Mar CCD"
	minvalidpixel="1" 
	overload="65500"
	rotaxis="1 0 0"
	strongpix="6"
	trustedregion="0.0 1.41"
	polarisation="0.99"
	trustedpixels="7000 30000"
	sensor_thickness="0.01"                                           
	# offsets are documented; values can be found in mccd_xdsparams.pl script
	# Thanks to Kay Diederichs' Generate XDS.INP script!
  	let SKIP=1024+80                                                        
  	NX=$(od -t dI -j $SKIP -N 4 images/"$imagename""$firstimage"."$extension" | head -1 | awk '{print $2}')
  	let SKIP=$SKIP+4                                                                         
  	NY=$(od -t dI -j $SKIP -N 4 images/"$imagename""$firstimage"."$extension" | head -1 | awk '{print $2}')
  	let SKIP=1720
  	distancem=$(od -t dI -j $SKIP -N 4 images/"$imagename""$firstimage"."$extension" | head -1 | awk '{print $2}')
  	distance=`echo "scale=3; $distancem/1000" | bc -l`                                                                                                                  
	let SKIP=1024+256+128+256+4                                                                             
  	ORGX=$(od -t dI -j $SKIP -N 4 images/"$imagename""$firstimage"."$extension" | head -1 | awk '{print $2}')             
  	ORGX=`echo "scale=2; $ORGX/1000" | bc -l `                                                              
  	let SKIP=$SKIP+4                                                                                        
  	ORGY=$(od -t dI -j $SKIP -N 4 images/"$imagename""$firstimage"."$extension" | head -1 | awk '{print $2}')             
  	ORGY=`echo "scale=2; $ORGY/1000" | bc -l `                                                              
 	let SKIP=1024+736
  	OSCILLATION_RANGE=$(od -t dI -j $SKIP -N 4 images/"$imagename""$firstimage"."$extension" | head -1 | awk '{print $2}') 
  	deltaphi=`echo "scale=3; $OSCILLATION_RANGE/1000" | bc -l`                                                                                            
  	let SKIP=1024+256+128+256+128+4                                                                
  	QX=$(od -t dI -j $SKIP -N 4 images/"$imagename""$firstimage"."$extension" | head -1 | awk '{print $2}')      
  	QX=`echo "scale=10; $QX/1000000" |bc -l `                                                      
  	let SKIP=$SKIP+4                                                                               
  	QY=$(od -t dI -j $SKIP -N 4 images/"$imagename""$firstimage"."$extension" | head -1 | awk '{print $2}')      
  	QY=`echo "scale=10; $QY/1000000" |bc -l ` 
	detectorsize="NX= $NX    NY= $NY    QX= $QX   QY= $QY"
  	let SKIP=1024+256+128+256+128+128+12
  	X_RAY_WAVELENGTH=$(od -t dI -j $SKIP -N 4 images/"$imagename""$firstimage"."$extension" | head -1 | awk '{print $2}')
  	wavelength=`echo "scale=5; $X_RAY_WAVELENGTH/100000" | bc -l | awk '{printf "%.5f", $0}'` 
	let SKIP=1024+256+128+256+44
	STARTING_ANGLE=$(od -t dI -j $SKIP -N 4 images/"$imagename""$firstimage"."$extension" | head -1 | awk '{print $2}')
	phi=`echo "scale=2; $STARTING_ANGLE/1000" | bc -l`  
	# if ORGX and ORGY are in mm convert to pixels
  	NXBYFOUR=`echo "scale=0; $NX/4" | bc -l `                               
  	ORGXINT=`echo "scale=0; $ORGX/1" | bc -l `                              
  	if [ $ORGXINT -lt $NXBYFOUR ]; then                                     
     		ORGX=`echo "scale=2; $ORGX/$QX" | bc | awk '{printf "%2.2f\n",$1}'`                             
     		ORGY=`echo "scale=2; $ORGY/$QY" | bc | awk '{printf "%2.2f\n",$1}'`                                             
  	fi 
	beamcentrex="$ORGX"
	beamcentrexmm=`echo "scale=2; $beamcentrex*$QX" | bc | awk '{printf "%2.2f\n",$1}'`
	beamcentrey="$ORGY"
	beamcentreymm=`echo "scale=2; $beamcentrey*$QY" | bc | awk '{printf "%2.2f\n",$1}'`
else
	echo -e "Unknown detector type. Aborting."
	exit
fi

#check if dataset is a grid scan
grid_name_check=`echo $project |  awk -F "_" '/_gs_/ {printf "%s", $2 }'`
deltaphi_check=`echo $deltaphi | xargs printf "%1.0f"`
if [ "$deltaphi_check" = "0" ] && [ "$grid_name_check" = "gs" ]; then
	echo -e "\n\nDataset $project is likely a diffraction grid scan." > GRID_SCAN
	exit
fi


image_dir=`ls -altr images | head -2 | tail -1 | awk 'BEGIN {FS="> "}; {print $2}' | sed 's%/[^/]*$%/%'`

if [ -e data_location ]; then
    image_dir2=`tail -1 data_location`
fi

first_frame=`echo $firstimage | bc`
last_frame=`echo $lastimage | bc`
detector_dist=`echo $distance | awk '{printf "%1d\n",$1}'`

# Reading and displaying setup parameters

echo -e "\
\n### DATASET CHARACTERISTICS ###\n
Project (image name):           $project" | tee -a DATASET_PARAMS.LP

if [ "$image_dir" ]; then
    echo -e "\
Image directory:                $image_dir" | tee -a DATASET_PARAMS.LP
elif [ "$image_dir2" ]; then
    echo -e "\
Image directory:                $image_dir2" | tee -a DATASET_PARAMS.LP
fi

echo -e "\
First and last images:		$first_frame, $last_frame
Total number of images:         $totalframes
Detector distance (mm):		$detector_dist
X-ray wavelength (A):		$wavelength
Detector:			$detectortype
Starting phi (deg):		$phi
Oscillation range (deg):	$deltaphi
Beam centre (mm):		$beamcentrexmm, $beamcentreymm" | tee -a DATASET_PARAMS.LP

if [ "$beamline" ]; then
	echo -e "\
Beamline:			$beamline" | tee -a DATASET_PARAMS.LP
fi

if [ "$coll_date" ]; then
    day=`echo $coll_date | awk 'BEGIN {FS="-"}; {printf "%1d\n",$3}'`
    month=`echo $coll_date | awk 'BEGIN {FS="-"}; {printf "%1d\n",$2}'`
    if [ $month = 1 ]; then month=January
    elif [ $month = 2 ]; then month=February
    elif [ $month = 3 ]; then month=March
    elif [ $month = 4 ]; then month=April
    elif [ $month = 5 ]; then month=May
    elif [ $month = 6 ]; then month=June
    elif [ $month = 7 ]; then month=July
    elif [ $month = 8 ]; then month=August
    elif [ $month = 9 ]; then month=September
    elif [ $month = 10 ]; then month=October
    elif [ $month = 11 ]; then month=November
    elif [ $month = 12 ]; then month=December
    fi
    year=`echo $coll_date | awk 'BEGIN {FS="-"}; {printf "%1d\n",$1}'`
    echo -e "\
Experiment date:		$day $month $year" | tee -a DATASET_PARAMS.LP
fi



#for MacOSX use cpu_num=`/usr/sbin/sysctl -n hw.ncpu`
cpu_num=`cat /proc/cpuinfo | grep -c processor`
#jobs number can be increased to 4 but this will use up significant proportion of resources!
#however, for small datasets (<500 frames) number of jobs does not make much of difference but for larger ones it can reduce integration time by up to 40% so it is worth using
jobs_num=4

#Making the input file for XDS
echo "\
DATA_RANGE= $firstimage $lastimage
SPOT_RANGE= $firstimage $lastimage
BACKGROUND_RANGE= $background_first $background_last
SPOT_MAXIMUM-CENTROID= 2.0     
STRONG_PIXEL= $strongpix
OSCILLATION_RANGE= $deltaphi
STARTING_ANGLE= $phi
STARTING_FRAME= $firstimage  
X-RAY_WAVELENGTH= $wavelength 
NAME_TEMPLATE_OF_DATA_FRAMES= images/"$imagename""$digits".$extension !SMV DIRECT
DETECTOR_DISTANCE= $distance
DETECTOR= $detector        MINIMUM_VALID_PIXEL_VALUE=$minvalidpixel  OVERLOAD= $overload
DIRECTION_OF_DETECTOR_X-AXIS= 1.0 0.0 0.0
DIRECTION_OF_DETECTOR_Y-AXIS= 0.0 1.0 0.0
$detectorsize
ORGX=$beamcentrex ORGY=$beamcentrey
ROTATION_AXIS= $rotaxis
INCIDENT_BEAM_DIRECTION= 0.0 0.0 1.0
FRACTION_OF_POLARIZATION= $polarisation
POLARIZATION_PLANE_NORMAL= 0.0 1.0 0.0
VALUE_RANGE_FOR_TRUSTED_DETECTOR_PIXELS= $trustedpixels
REFINE(INTEGRATE)= BEAM ORIENTATION CELL   
DELPHI= 4.0   
MAXIMUM_NUMBER_OF_PROCESSORS= $cpu_num   
MAXIMUM_NUMBER_OF_JOBS= $jobs_num   
RESOLUTION_SHELLS= 15.0 8.0 5.0 3.0   
TOTAL_SPINDLE_ROTATION_RANGES= 15.0 180.0 15.0   
STARTING_ANGLES_OF_SPINDLE_ROTATION= -95.0 95.0 5.0   
TRUSTED_REGION= $trustedregion
PROFILE_FITTING= TRUE   
STRICT_ABSORPTION_CORRECTION= TRUE   
NUMBER_OF_PROFILE_GRID_POINTS_ALONG_ALPHA/BETA= 9   
NUMBER_OF_PROFILE_GRID_POINTS_ALONG_GAMMA= 9   
REFINE(IDXREF)= BEAM AXIS ORIENTATION CELL   
REFINE(CORRECT)= DISTANCE BEAM AXIS ORIENTATION CELL   
TEST_RESOLUTION_RANGE= 20 4.5     
SENSOR_THICKNESS= 0   
MINIMUM_ZETA=0.05
FRIEDEL'S_LAW=FALSE
" > XDS.INP

# Additonal XDS specific parameters

if [ "$sensor_thickness" ]; then
	echo  "SENSOR_THICKNESS= $sensor_thickness" >> XDS.INP
elif [ "$min_spot_pixels" ]; then
	echo  "MINIMUM_NUMBER_OF_PIXELS_IN_A_SPOT= $min_spot_pixels" >> XDS.INP
fi

if [ -e symm_def ]; then
	spacegroup=`cat symm_def | head -1`
	echo "SPACE_GROUP_NUMBER= $spacegroup" >> XDS.INP
	cell=`cat symm_def | tail -1`
	echo "UNIT_CELL_CONSTANTS= $cell" >> XDS.INP
fi

#if command line arguments -spacegroup, -cell, -resolution, -anomalous and -beam are passed in the wrapper script
#if [[ ! $spacegroup ]]; then
#	sed -i '/SPACE_GROUP_NUMBER= /d' XDS.INP
#else
#	echo "SPACE_GROUP_NUMBER= $spacegroup" >> XDS.INP
#fi

#if [[ ! $cell ]]; then
#	sed -i '/UNIT_CELL_CONSTANTS= /d' XDS.INP
#else
#	echo "UNIT_CELL_CONSTANTS= $cell" >> XDS.INP
#fi

#if [[ ! $resolution ]]; then
#    sed -i '/INCLUDE_RESOLUTION_RANGE= /d' XDS.INP
#else
#    echo "INCLUDE_RESOLUTION_RANGE= $lores $hires" >> XDS.INP
#fi

#if [[ ! $anomalous ]]; then
#	sed -i '/FRIEDEL /d' XDS.INP
#	echo "FRIEDEL'S_LAW= FALSE" >> XDS.INP
#else
#	echo "FRIEDEL'S_LAW= TRUE" >> XDS.INP
#fi

#convert passed beam centre command line argument in mm eg. "153.5, 156.7" to pixels and pass as two separate variables
#if [[ ! $beam ]]; then
#	sed -i '/ORGX= /d' XDS.INP
#else
#	echo "ORGX=$beamcentrex ORGY=$beamcentrey" >> XDS.INP
#fi


echo -e "\nGenerated XDS input file.\n"
echo -e "Allocated $cpu_num processors with $jobs_num jobs for each.\n"

exit
