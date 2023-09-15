#!/bin/bash
# This script will update, reboot, then heal glusterfs volumes one host at a time, based on gluster environment input
# 3/25 Kyle Vandoremalen

echo "Enter one of the following glusterfs environments to update:"
echo "dev"
echo "qa"
echo "stg"
echo "prd"

read enviro

if [[ $enviro == "" ]]; then
        echo "Please enter an environment name."
        exit 1
elif [[ $enviro == "dev" ]]; then
        servers=("devnode1" "devnode2" "devnode3")
elif [[ $enviro == "qa" ]]; then
        servers=("qanode1" "qanode2" "qanode3")
elif [[ $enviro == "stg" ]]; then
        servers=("stgnode1" "stgnode2" "stgnode3")
elif [[ $enviro == "prd" ]]; then
        servers=("prdnode1" "prdnode2" "prdnode3"")
elif [[ $enviro != "dev" ]] && [[ $enviro != "qa" ]] && [[ $enviro != "stg" ]] && [[ $enviro != "prd" ]]; then
        echo " "
        echo "------------------"
        echo "That is not a valid option."
        exit 1
fi

#for server in ${servers[@]};
#echo $server
#done

# Run yum updates on one server at a time
for server in ${servers[@]}; do
        echo "Updating yum packages on $server..."
        ssh -t root@$server "sudo yum-complete-transaction --cleanup-only && yum -y update --skip-broken"

        # Reboot once updates complete
        echo "Updates complete. Rebooting $server..."
        ssh root@$server "nohup reboot &>/dev/null & exit"

        #Check if the server is back online before continuing
        while ! ping -c1 $server &>/dev/null; do sleep 2; done
        echo "Server $server is back online"


# Heal GlusterFS  until acceptable number of shards remaining overall
        echo "Wait for glusterfs to have less than 3 unhealed shards overall"
        while true
        do
                output=$(gluster volume heal guac_gfs_vol info | grep 'Number of entries' | awk '{ sum += $NF } END {print sum}')
                echo "Unheald shards: $output"

                # Wait until less than 2 shards remain unhealed
                if [[ $output -eq 2 ]]; then
                        echo "Unheald shards remaining: $output"
                        break
                fi
                sleep 120
        done

echo "Finished updating server"

done
