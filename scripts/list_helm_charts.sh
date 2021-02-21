#!/bin/bash

# ------ Variables -------------------------------------
helm_chart=$1
rep_dir=$2
rep_name=$3
acr_name=iaearegistry

echo "--------------------------------------------------"
echo "* Variable 'helm_chart' : " $helm_chart
echo "* Variable 'Repository Folder' : " $rep_dir
echo "* Variable 'Repository Name' : " $rep_name
echo "--------------------------------------------------"

# ------- Date utils ----------------------------------------------
date2stamp () {
    date --utc --date "$1" +%s
}
dateDiff () {
    case $1 in
        -s)   sec=1;      shift;;
        -m)   sec=60;     shift;;
        -h)   sec=3600;   shift;;
        -d)   sec=86400;  shift;;
        *)    sec=86400;;
    esac
    dte1=$(date2stamp $1)
    dte2=$(date2stamp $2)
    diffSec=$((dte2-dte1))
    if [ $diffSec -lt  0 ]; then abs=-1; else abs=1; fi
    echo $((diffSec/sec))
}
# ------- Forming release string ----------------------------------
get_release_date() {
    local version=$1
    local _year=$(echo $version | cut -c 3-6)
    local _month=$(echo $version | cut -c 7-8)
    local _day=$(echo $version | cut -c 9-10)
    
    echo $_year"-"$_month"-"$_day
}
# ------- Getting minor release version ---------------------------
last_release() {
    local rep_stage=$1
    local counter_value=0
    local fnd=""
    for x in $(az acr repository show-tags -n $acr_name --repository $rep_dir/stable/$rep_name --output table --orderby time_desc) 
    do 
        counter_value=$(($counter_value+1))
        if [ $counter_value -gt 2 ]
        then
            if [ $counter_value -eq 5 ]
            then
                fnd=$x
                break
            fi
        fi
    done

    echo $fnd
}
# ------- Checking in ACR ------------------------------
check_image_in_acr() {
    local rep_stage=$1
    local counter_value=0
    local fnd=0
    for x in $(az acr repository show-tags -n $acr_name --repository $rep_dir/$rep_stage/$rep_name --output table --orderby time_desc) 
    do 
        counter_value=$(($counter_value+1))
        if [ $counter_value -gt 2 ]
        then
            if [ $x = $version ]
            then
                fnd=1
                break
            fi
        fi
    done

    echo $fnd
}
# -------- Deleting the helm chart from ACR------------
delete_helm_chart() {
    local ver=$1
    printf '\t Processing "%s"\t%s\n' $helm_chart $ver
    az acr helm delete --name $acr_name $helm_chart --version $ver --yes
}
# -------- Deleting the helm chart from ACR------------
delete_image() {
    local rep_stage=$1
    local ver=$2
    printf '\t Processing "%s/%s:%s"\n' $rep_stage $rep_name $ver
    az acr repository delete --name $acr_name --image $rep_dir/$rep_stage/$rep_name:$ver --yes
}

release_ver=$(last_release 'stable') 
release_date=$(get_release_date $release_ver)

printf " * Release version: %s\n" $release_ver
printf " * Release date: %s\n" $release_date

for row in $(az acr helm list --name $acr_name --output json | jq -r '[.'\"$helm_chart\"'[] | { index: .appVersion, version: .version, created: .created }] | sort_by(.created)'  | jq -r '.[] | @base64'); do
    index=$(echo ${row} | base64 --decode | jq -r '.index')
    version=$(echo ${row} | base64 --decode | jq -r '.version')
    created=$(echo ${row} | base64 --decode | jq -r '.created')

    helm_date=$(get_release_date $version)

    _diff=$(dateDiff $helm_date $release_date)
    printf "\t * [%s] Compare '%s' and '%s': %s\n" $version $helm_date $release_date  $_diff
    if [ $_diff -gt 0 ]; then
        delete_image 'dev' $index
        delete_image 'stable' $index
        delete_helm_chart $index
    fi
done

for row in $(az acr helm list --name $acr_name --output json | jq -r '[.'\"$helm_chart\"'[] | { index: .appVersion, version: .version, created: .created }] | sort_by(.created)'  | jq -r '.[] | @base64'); do
    index=$(echo ${row} | base64 --decode | jq -r '.index')
    version=$(echo ${row} | base64 --decode | jq -r '.version')
    created=$(echo ${row} | base64 --decode | jq -r '.created')

    fnd_dev=$(check_image_in_acr 'dev')    
    fnd_stable=$(check_image_in_acr 'stable')   

    if [ $fnd_dev -eq 0 ] && [ $fnd_stable -eq 0 ]; then
        delete_helm_chart $index
    fi
done