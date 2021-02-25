#!/bin/bash

acr_name=iaearegistry
rep_dir=nahu/iris-sso
rep_name=dicts-service
counter_stable_value=0

for x in $(az acr repository show-tags -n $acr_name --repository $rep_dir/stable/$rep_name --output table --orderby time_desc) 
do 
    counter_stable_value=$(($counter_stable_value+1))
    if [ $counter_stable_value -gt 2 ]
    then
        echo "[" $counter_stable_value "] STABLE Release: " $x 
        sleep 1

        counter_dev_value=0
        dev_fnd=0
        for y in $(az acr repository show-tags -n $acr_name --repository $rep_dir/dev/$rep_name --output table --orderby time_desc) 
        do 
            counter_dev_value=$(($counter_dev_value+1))
            if [ $counter_dev_value -gt 2 ]
            then
                if [ $x = $y ]
                then
                    dev_fnd=1
                    break
                fi
            fi
        done 

        if [ $dev_fnd -eq 1 ]
        then
            echo "\t\t OK..."
        else
            echo "\t\t NOT FOUND..."
        fi   
    fi    
done