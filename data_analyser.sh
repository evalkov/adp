#! /bin/bash

#use find and maxdepth to deal with identical files in subfolders????

if [ -e data_list ]  || [ -e pruned_data_list ] || [ -e dataset_list ] || [ -e image_list ]; then
	rm data_list
	rm pruned_data_list
	rm dataset_list
	rm image_list
fi

echo -e "\nPlease specify the FULL path to the data: \c"
read path
find "$path" -type f \( -name '*.img' -o -name '*.mar1600' -o -name '*.cbf' -o -name '*.mar2300' -o -name '*.mccd' \) | sort -u | awk -F "/" '{ print $0}' > data_list

for image in `cat data_list | sed 's!.*/!!'`; do
    image_name_check=`echo $image | sed 's/.[^_]*$//'`
    if [[ "$image_name_check" ]]; then
        echo $image_name_check >> image_list
    fi
done

#delete duplicates
awk -F "|" '!arr[$1]++' image_list > pruned_data_list
unique_prefixes=`awk 'END { print NR }' pruned_data_list`
echo -e "\nFound $unique_prefixes unique image names in specified path."
echo -e "WARNING! Identical filenames in separate subfolders will screw this up!"
echo -e "\nCandidate datasets for processing:\n"

cat pruned_data_list | while read prefix; do
	#do exact string match for image prefix    
	#awk '$1=="'$prefix'" {print $0}'`
    image_set_check=`cat image_list | awk '$1=="'$prefix'" {print $0}' | wc -l`
    if [[ "$image_set_check" -gt "60" ]]; then
        echo -e "$prefix ($image_set_check images)"
        echo $prefix >> dataset_list
        mkdir $prefix
        cd $prefix
        mkdir images
        cd ..  
        for file in `cat data_list | grep $prefix`; do
            #check if grepped prefix belongs to actual data image file and not processing file
            file_check=`echo $file | awk -F "/" '{ print $NF}' | grep $prefix`
            if [[ "$file_check" ]]; then
                link=`echo $file | sed 's!.*/!!'`
                ln -s $file $prefix/images/$link > /dev/null 2>&1
            fi
        done 
    fi
done   

echo -e "\nFinished collecting information about the data."
