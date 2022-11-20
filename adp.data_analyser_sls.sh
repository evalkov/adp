#!/bin/sh

#  test.sh
#  /home/evalkov/scripts/autoproc/test.sh
#
#  Created by Eugene Valkov on 12/3/14.
#

if [ -e data_list ]  || [ -e pruned_data_list ] || [ -e dataset_list ] || [ -e image_list ]; then
    rm data_list > /dev/null 2>&1
    rm pruned_data_list > /dev/null 2>&1
    rm dataset_list > /dev/null 2>&1
    rm image_list > /dev/null 2>&1
fi

if [ ! "$1" = "" ]; then
    path=$1
else
    echo -e "\nPlease specify the FULL path to the data: \c"
    read path
fi


echo -e "\nDo you expect small datasets (less than 150 frames)? [y/N]: \c"
read yesno
if [[ $yesno == "y" || $yesno == "Y" || $yesno == "yes" ]]; then
    echo -e "\nWill attempt to process all datasets that contain at least 25 frames."
    dataset_size=small
elif [[ $yesno == "n" || $yesno == "N" || $yesno == "no" || $yesno == "" ]]; then
    echo -e "\nWill only process datasets that contain at least 150 frames."
    dataset_size=large
else
    until [[ $yesno == "yes" || $yesno == "no" ]]; do
    echo -e "Please answer 'yes' or 'no': \c"
    read yesno; done
fi

find "$path" -type f \( -name '*.img' -o -name '*.mar1600' -o -name '*.cbf' -o -name '*.mar2300' -o -name '*.mccd' \) | sort -u | awk -F "/" '{ print $0}' > data_list


for image in `cat data_list`; do
    image_name=`echo "${image##*/}"`
    folder_name=`echo "${image%/*}"`
    #echo "$folder_name-$image_name" | sed 's!.*/!!'
    image_name_check=`echo $image | sed 's/.[^_]*$//'`
    if [[ "$image_name_check" ]]; then
        echo $image_name_check >> image_list
    fi
done


#delete duplicates
awk -F "|" '!arr[$1]++' image_list > pruned_data_list
unique_prefixes=`awk 'END { print NR }' pruned_data_list`
echo -e "\nFound $unique_prefixes unique image names in specified path."
echo -e "\nCandidate datasets for processing:\n"

#SLS-specific: removes image folders that are the result of automated processing with GO.com
sed -i '/GO/d' pruned_data_list


cat pruned_data_list | while read prefix; do
    #do exact string match for image prefix
    #awk '$1=="'$prefix'" {print $0}'`
    image_set_check=`cat image_list | awk '$1=="'$prefix'" {print $0}' | wc -l`
    dataset_name=`echo "${prefix##*/}"`
    dataset_folder_name=`echo "${prefix%/*}"`
    dataset=`echo "$dataset_folder_name-$dataset_name" | sed 's!.*/!!'`
    if [[ "$image_set_check" -gt "150" ]] && [[ "$dataset_size" == "large" ]]; then
        echo $dataset >> dataset_list
        mkdir $dataset > /dev/null 2>&1
        cd $dataset
        mkdir images > /dev/null 2>&1
        cd ..
        echo -e "$dataset ($image_set_check frames)"
        for file in `cat data_list | grep "$dataset_folder_name/$dataset_name"`; do
            #check if grepped prefix belongs to actual data image file and not processing file
            #file_check=`echo $file | awk -F "/" '{ print $NF}' | grep $prefix`
            #if [[ "$file_check" ]]; then
            link=`echo $file | sed 's!.*/!!'`
            ln -s $file $dataset/images/$link > /dev/null 2>&1
            #fi
        done
    elif [[ "$image_set_check" -lt "150" ]] && [[ "$image_set_check" -gt "25" ]] && [[ "$dataset_size" == "small" ]] ; then
        echo -e "$dataset ($image_set_check frames)"
        echo $dataset >> dataset_list
        mkdir $dataset > /dev/null 2>&1
        cd $dataset
        mkdir images > /dev/null 2>&1
        cd ..
        for file in `cat data_list | grep "$dataset_folder_name/$dataset_name"`; do
            link=`echo $file | sed 's!.*/!!'`
            ln -s $file $dataset/images/$link > /dev/null 2>&1
        done
    elif [[ "$image_set_check" -lt "150" ]] && [[ "$image_set_check" -gt "25" ]] && [[ "$dataset_size" == "large" ]] ; then
        echo -e "$dataset ($image_set_check frames) <- below default 150 frames so will not be processed."
    fi
done

echo -e "\nFinished collecting information about the data."
