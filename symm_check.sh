#! /bin/bash

echo -e "\nPlease specify the space group: \c"
read symm
sg=`echo "$symm" | sed -e 's/[^[:alnum:]]//g' | awk '{print toupper($0)}'`
if [[ $sg == "P1" || $sg == "1" ]]; then
	spacegroupnum=1
elif [[ $sg == "P2" || $sg == "3" ]]; then
	spacegroupnum=3
elif [[ $sg == "P21" || $sg == "4" ]]; then
	spacegroupnum=4
elif [[ $sg == "C2" || $sg == "5" ]]; then
	spacegroupnum=5
elif [[ $sg == "P222" || $sg == "16" ]]; then
	spacegroupnum=16
elif [[ $sg == "P2221" || $sg == "17" ]]; then
	spacegroupnum=17
elif [[ $sg == "P21212" || $sg == "18" ]]; then
	spacegroupnum=18
elif [[ $sg == "P212121" || $sg == "19" ]]; then
	spacegroupnum=19
elif [[ $sg == "C222" || $sg == "21" ]]; then
	spacegroupnum=21
elif [[ $sg == "C2221" || $sg == "20" ]]; then
	spacegroupnum=20
elif [[ $sg == "F222" || $sg == "22" ]]; then
	spacegroupnum=22
elif [[ $sg == "I222" || $sg == "23" ]]; then
	spacegroupnum=23
elif [[ $sg == "I212121" || $sg == "24" ]]; then
	spacegroupnum=24
elif [[ $sg == "P4" || $sg == "75" ]]; then
	spacegroupnum=75
elif [[ $sg == "P41" || $sg == "76" ]]; then
	spacegroupnum=76
elif [[ $sg == "P42" || $sg == "77" ]]; then
	spacegroupnum=77
elif [[ $sg == "P43" || $sg == "78" ]]; then
	spacegroupnum=78
elif [[ $sg == "P422" || $sg == "89" ]]; then
	spacegroupnum=89
elif [[ $sg == "P4212" || $sg == "90" ]]; then
	spacegroupnum=90
elif [[ $sg == "P4122" || $sg == "91" ]]; then
	spacegroupnum=91
elif [[ $sg == "P41212" || $sg == "92" ]]; then
	spacegroupnum=92
elif [[ $sg == "P4222" || $sg == "93" ]]; then
	spacegroupnum=93
elif [[ $sg == "P42212" || $sg == "94" ]]; then
	spacegroupnum=94
elif [[ $sg == "P4322" || $sg == "95" ]]; then
	spacegroupnum=95
elif [[ $sg == "P43212" || $sg == "96" ]]; then
	spacegroupnum=96
elif [[ $sg == "I4" || $sg == "79" ]]; then
	spacegroupnum=79
elif [[ $sg == "I41" || $sg == "80" ]]; then
	spacegroupnum=80
elif [[ $sg == "I422" || $sg == "97" ]]; then
	spacegroupnum=97
elif [[ $sg == "I4122" || $sg == "98" ]]; then
	spacegroupnum=98
elif [[ $sg == "P3" || $sg == "143" ]]; then
	spacegroupnum=143
elif [[ $sg == "P31" || $sg == "144" ]]; then
	spacegroupnum=144
elif [[ $sg == "P32" || $sg == "145" ]]; then
	spacegroupnum=145
elif [[ $sg == "P312" || $sg == "149" ]]; then
	spacegroupnum=149
elif [[ $sg == "P321" || $sg == "150" ]]; then
	spacegroupnum=150
elif [[ $sg == "P3112" || $sg == "151" ]]; then
	spacegroupnum=151
elif [[ $sg == "P3121" || $sg == "152" ]]; then
	spacegroupnum=152
elif [[ $sg == "P3212" || $sg == "153" ]]; then
	spacegroupnum=153
elif [[ $sg == "P3221" || $sg == "154" ]]; then
	spacegroupnum=154
elif [[ $sg == "P6" || $sg == "168" ]]; then
	spacegroupnum=168
elif [[ $sg == "P61" || $sg == "169" ]]; then
	spacegroupnum=169
elif [[ $sg == "P65" || $sg == "170" ]]; then
	spacegroupnum=170
elif [[ $sg == "P62" || $sg == "171" ]]; then
	spacegroupnum=171
elif [[ $sg == "P64" || $sg == "172" ]]; then
	spacegroupnum=172
elif [[ $sg == "P63" || $sg == "173" ]]; then
	spacegroupnum=173
elif [[ $sg == "P622" || $sg == "177" ]]; then
	spacegroupnum=177
elif [[ $sg == "P6122" || $sg == "178" ]]; then
	spacegroupnum=178
elif [[ $sg == "P6522" || $sg == "179" ]]; then
	spacegroupnum=179
elif [[ $sg == "P6222" || $sg == "180" ]]; then
	spacegroupnum=180
elif [[ $sg == "P6422" || $sg == "181" ]]; then
	spacegroupnum=181
elif [[ $sg == "P6322" || $sg == "182" ]]; then
	spacegroupnum=182
elif [[ $sg == "R3:H" || $sg == "H3" || $sg == "146" ]]; then
	spacegroupnum=146
elif [[ $sg == "R3:R" || $sg == "R3" || $sg == "146" ]]; then
	spacegroupnum=146
elif [[ $sg == "R32:H" || $sg == "H32" || $sg == "155" ]]; then
	spacegroupnum=155
elif [[ $sg == "R32:R" || $sg == "R32" || $sg == "155" ]]; then
	spacegroupnum=155	
elif [[ $sg == "P23" || $sg == "195" ]]; then
	spacegroupnum=195
elif [[ $sg == "P213" || $sg == "198" ]]; then
	spacegroupnum=198
elif [[ $sg == "P432" || $sg == "207" ]]; then
	spacegroupnum=207
elif [[ $sg == "P4232" || $sg == "208" ]]; then
	spacegroupnum=208
elif [[ $sg == "P4332" || $sg == "212" ]]; then
	spacegroupnum=212
elif [[ $sg == "P4132" || $sg == "213" ]]; then
	spacegroupnum=213
elif [[ $sg == "F23" || $sg == "196" ]]; then
	spacegroupnum=196
elif [[ $sg == "F432" || $sg == "209" ]]; then
	spacegroupnum=209
elif [[ $sg == "F4132" || $sg == "210" ]]; then
	spacegroupnum=210
elif [[ $sg == "I23" || $sg == "197" ]]; then
	spacegroupnum=197
elif [[ $sg == "I213" || $sg == "199" ]]; then
	spacegroupnum=199
elif [[ $sg == "I432" || $sg == "211" ]]; then
	spacegroupnum=211
elif [[ $sg == "I4132" || $sg == "214" ]]; then
	spacegroupnum=214
else 
	echo -e "Spacegroup you've entered was not recognised. Will use pointless for symmetry analysis."
	autosym=true
fi

if [[ $spacegroupnum == "1" ]]; then
	setting=triclinic
elif [[ $spacegroupnum == "3" || $spacegroupnum == "4" || $spacegroupnum == "5" ]]; then
	setting=monoclinic
elif [[ $spacegroupnum == "16" || $spacegroupnum == "17" || $spacegroupnum == "18" || $spacegroupnum == "19" || $spacegroupnum == "20" || $spacegroupnum == "21" || $spacegroupnum == "22" || $spacegroupnum == "23" || $spacegroupnum == "24" ]]; then
	setting=orthorhombic
elif [[ $spacegroupnum == "75" || $spacegroupnum == "76" || $spacegroupnum == "77" || $spacegroupnum == "78" || $spacegroupnum == "79" || $spacegroupnum == "80" || $spacegroupnum == "89" || $spacegroupnum == "90" || $spacegroupnum == "91" || $spacegroupnum == "92" || $spacegroupnum == "93" || $spacegroupnum == "94" || $spacegroupnum == "95" || $spacegroupnum == "96" || $spacegroupnum == "97" || $spacegroupnum == "98" ]]; then
	setting=tetragonal
elif [[ $spacegroupnum == "143" || $spacegroupnum == "144" || $spacegroupnum == "145" || $spacegroupnum == "149" || $spacegroupnum == "150" || $spacegroupnum == "151" || $spacegroupnum == "152" || $spacegroupnum == "153" || $spacegroupnum == "154" || $spacegroupnum == "168" || $spacegroupnum == "169" || $spacegroupnum == "170" || $spacegroupnum == "171" || $spacegroupnum == "172" || $spacegroupnum == "173" || $spacegroupnum == "177"  || $spacegroupnum == "178" || $spacegroupnum == "179" || $spacegroupnum == "180" || $spacegroupnum == "181" || $spacegroupnum == "182" ]]; then
	setting=hexagonal
elif [[ $spacegroupnum == "195" || $spacegroupnum == "196" || $spacegroupnum == "197" || $spacegroupnum == "198" || $spacegroupnum == "199" || $spacegroupnum == "207" || $spacegroupnum == "208" || $spacegroupnum == "209" || $spacegroupnum == "210" || $spacegroupnum == "211" || $spacegroupnum == "212"  || $spacegroupnum == "213" || $spacegroupnum == "214" ]]; then
	setting=cubic
fi

if [[ $setting == "triclinic" ]]; then
	echo -e "Please enter the length of the A-axis: \c"
	read aaxis
	echo -e "Please enter the length of the B-axis: \c"
	read baxis
	echo -e "Please enter the length of the C-axis: \c"
	read caxis
	echo -e "Please specify the alpha angle: \c"
	read alpha
	echo -e "Please specify the beta angle: \c"
	read beta
	echo -e "Please specify the gamma angle: \c"
	read gamma
elif [[ $setting == "monoclinic" ]]; then
	echo -e "Please enter the length of the A-axis: \c"
	read aaxis
	echo -e "Please enter the length of the B-axis: \c"
	read baxis
	echo -e "Please enter the length of the C-axis: \c"
	read caxis
	if [[ "$baxis" == "$aaxis" || "$baxis" == "$caxis" ]]; then
		echo -e "You've specified $setting lattice, therefore the B-axis must be unique!"
		until [[ ! "$baxis" == "$aaxis" || "$baxis" == "$caxis"  ]]; do
			echo -e "Please enter the length of the B-axis: \c"
			read baxis
		done
	fi
	echo -e "Please specify the beta angle: \c"
	read beta
	alpha=90
	gamma=90
elif [[ $setting == "orthorhombic" ]]; then
	echo -e "Please enter the length of the A-axis: \c"
	read aaxis
	echo -e "Please enter the length of the B-axis: \c"
	read baxis
	echo -e "Please enter the length of the C-axis: \c"
	read caxis
	alpha=90
	beta=90
	gamma=90
elif [[ $setting == "tetragonal" ]]; then
	echo -e "Please enter the length of the A-axis: \c"
	read aaxis
	baxis="$aaxis"
	echo -e "Please enter the length of the C-axis: \c"
	read caxis
	alpha=90
	beta=90
	gamma=90
elif [[ $setting == "hexagonal" ]]; then
	echo -e "Please enter the length of the A-axis: \c"
	read aaxis
	baxis="$aaxis"
	echo -e "Please enter the length of the C-axis: \c"
	read caxis
	alpha=90
	beta=90
	gamma=120
elif [[ $setting == "cubic" ]]; then
	echo -e "Please enter the length of the A-axis: \c"
	read aaxis
	baxis="$aaxis"
	caxis="$aaxis"
	alpha=90
	beta=90
	gamma=90		
#Special check for the hexagonal or rhombohedral setting in R3 and R32
elif [[ $spacegroupnum == "146" ]]; then
	echo -e "You have specified R3 (#146)."
	echo -e "Please enter the setting [rhombohedral/hexagonal]: \c"
		read r3setting
	until [[ $r3setting == "rhombohedral" || $r3setting == "hexagonal" ]]; do
		echo -e "Please answer 'rhombohedral' or 'hexagonal': \c"
		read r3setting
	done
	if [[ $r3setting == "rhombohedral" ]]; then
		echo -e "You have chosen R3:R"
		sg=R3
		echo -e "Please enter the length of the A-axis: \c"
		read aaxis
		baxis="$aaxis"
		caxis="$aaxis"
		echo -e "Please specify the alpha angle: \c"
		read alpha
		beta="$alpha"
		gamma="$alpha"
	elif [[ $r3setting == "hexagonal" ]]; then
		echo -e "You have chosen R3:H"
		sg=H3
		echo -e "Please enter the length of the A-axis: \c"
		read aaxis
		baxis="$aaxis"
		echo -e "Please enter the length of the C-axis: \c"
		read caxis
		alpha=90
		beta="$alpha"
		gamma=120
	fi
elif [[ $spacegroupnum == "155" ]]; then
	echo -e "You have specified R32 (#155)."
	echo -e "Please enter the setting [rhombohedral/hexagonal]: \c"
		read r32setting
	until [[ $r32setting == "rhombohedral" || $r32setting == "hexagonal" ]]; do
		echo -e "Please answer 'rhombohedral' or 'hexagonal': \c"
		read r32setting
	done
	if [[ $r32setting == "rhombohedral" ]]; then
		echo -e "You have chosen R32:R"
		sg=R32
		echo -e "Please enter the length of the A-axis: \c"
		read aaxis
		baxis="$aaxis"
		caxis="$aaxis"
		echo -e "Please specify the alpha angle: \c"
		read alpha
		beta="$alpha"
		gamma="$alpha"
	elif [[ $r32setting == "hexagonal" ]]; then
		echo -e "You have chosen R32:H"
		sg=H32
		echo -e "Please enter the length of the A-axis: \c"
		read aaxis
		baxis="$aaxis"
		echo -e "Please enter the length of the C-axis: \c"
		read caxis
		alpha=90
		beta="$alpha"
		gamma=120
	fi	
fi


#check for rhombohedral/hexagonal setting in space groups 146 and 155 and print the PDB standard
if [[ $spacegroupnum == "146" ]] && [[ $alpha == "$beta" ]] && [[ $alpha == "$gamma" ]]; then
	sg=R3
elif [[ $spacegroupnum == "155" ]] && [[ $alpha == "$beta" ]] && [[ $alpha == "$gamma" ]]; then
	sg=R32
elif [[ $spacegroupnum == "146" ]] && [[ ! $alpha == "$gamma" ]]; then
	sg=H3
elif [[ $spacegroupnum == "155" ]] && [[ ! $alpha == "$gamma" ]]; then
	sg=H32
fi

if [[ ! $autosym == "true" ]]; then
	echo "\
$spacegroupnum 
$aaxis $baxis $caxis $alpha $beta $gamma" > symm_def
	echo "\

Will process ALL datasets with these symmetry parameters:
Spacegroup: $sg (#$spacegroupnum)
Unit cell parameters: $aaxis, $baxis, $caxis, $alpha, $beta, $gamma"
fi

