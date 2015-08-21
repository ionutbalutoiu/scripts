set -e

IP_1=`nova list | grep " test " | awk '{print $13}'`
IP_2=`nova list | grep " test_2 " | awk '{print $13}'`
nova floating-ip-disassociate test $IP_1
nova floating-ip-disassociate test_2 $IP_2
nova floating-ip-delete $IP_1
nova floating-ip-delete $IP_2
nova delete test
heat stack-delete test_stack

#while [ -z "`nova volume-list | grep test_vol | grep available`" ]; do
#    sleep 1
#done

#VOL_ID=`nova volume-list | grep test_vol | awk '{print $2}'`
#cinder force-delete $VOL_ID
