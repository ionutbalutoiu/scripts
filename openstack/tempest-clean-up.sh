#!/bin/bash

MAX_PARALLEL=10
TIME_TO_SLEEP=0.5

function wait_for_background_jobs {
    while [ $(jobs | wc -l) -gt $MAX_PARALLEL ]; do
        echo -n "Waiting for background jobs... "
        echo "Current active jobs: $(jobs | wc -l). Max active jobs: $MAX_PARALLEL"
        sleep $TIME_TO_SLEEP
    done
}

function wait_for_all_background_jobs {
    while [ $(jobs | wc -l) -gt 0 ]; do
        echo -n "Waiting for all background jobs to finish... "
        echo "Current active jobs: $(jobs | wc -l)."
        sleep $TIME_TO_SLEEP
    done
}

function delete_all_instances {
    # Delete all instances
    echo "Deleting all instances..."
    nova list --all 2> /dev/null | grep -E 'ACTIVE|BUILD|ERROR' | awk '{print $2}' | while read -r vm_id ; do
        nova delete $vm_id 2>/dev/null & 
        wait_for_background_jobs
    done
}

function delete_all_rally_routers {
    # Delete all routers starting with "c_rally"
    echo "Deleting rally routers..."
    neutron router-list 2>/dev/null | grep 'c_rally' | awk '{print $2}' | while read -r router_id ; do
        neutron router-port-list "$router_id" 2>/dev/null | grep "subnet_id" | awk '{print $10}' | tr -d \", | while read -r port_id; do
            neutron router-interface-delete "$router_id" "$port_id" 2>/dev/null
        done
        neutron router-delete "$router_id" 2>/dev/null
    done
}

function delete_all_rally_networks {
    # Delete all subnets and networks starting with "c_rally"
    echo "Deleting rally networks..."
    # wait_for_all_background_jobs
    neutron subnet-list 2>/dev/null | grep 'c_rally' | awk '{print $2}' | while read -r subnet_id ; do
        neutron port-list 2>/dev/null | grep "$subnet_id" | awk '{print $2}' | while read -r port_id ; do
            if [ "$port_id" != '|' ]
            then
                neutron port-delete "$port_id" 2>/dev/null
                # wait_for_background_jobs
            fi
        done
        # wait_for_all_background_jobs
        neutron subnet-delete "$subnet_id" 2>/dev/null
        # wait_for_background_jobs
    done
    wait_for_all_background_jobs
    neutron net-list 2>/dev/null | grep 'c_rally' | awk '{print $2}' | while read -r net_id ; do
        neutron net-delete "$net_id" 2>/dev/null &
        wait_for_background_jobs
    done
}

function delete_all_rally_users {
    echo "Deleting rally users..."
    wait_for_all_background_jobs
    openstack user list 2>/dev/null | grep 'c_rally' | awk '{print $2}' | while read -r user_id ; do
        openstack user delete "$user_id" 2>/dev/null &
        wait_for_background_jobs
        echo "Deleted user: $user_id"
    done
}

function delete_all_rally_tenants {
    echo "Deleting rally tenants..."
    wait_for_all_background_jobs
    openstack project list 2>/dev/null | grep 'c_rally' | awk '{print $2}' | while read -r user_id ; do
        openstack project delete "$user_id" 2>/dev/null &
        wait_for_background_jobs
        echo "Deleted tenant: $tenant_id"
    done
}

function delete_all_floating_ips {
    echo "Deleting all floating ips..."
    neutron floatingip-list 2>/dev/null | grep 172.24 | awk '{print $2}' | while read -r ip_id ; do
        neutron floatingip-delete $ip_id 2>/dev/null &
        wait_for_background_jobs
    done
}


delete_all_instances
delete_all_rally_routers
delete_all_rally_networks

delete_all_rally_users &
delete_all_rally_tenants &
delete_all_floating_ips &
