set -e

NET_ID=$(nova net-list | awk '/ private / { print $2 }')
nova boot --flavor=m1.tiny --image=cirros --nic net-id=$NET_ID test --poll

nova volume-create --display-name test_vol --availability-zone nova 1
while [ -z "`nova volume-list | grep test_vol | grep available`" ]; do
    sleep 1
done

VOL_ID=`nova volume-list | grep test_vol | awk '{print $2}'`
nova volume-attach test $VOL_ID

IP_1=`nova floating-ip-create public | awk '{if (NR==4){print $2}}'`
nova floating-ip-associate test $IP_1

heat stack-create -f basic.yaml -P "ImageID=cirros;NetID=$NET_ID" test_stack

while [ -z "`nova list | grep test_2`" ]; do
    sleep 1
done

IP_2=`nova floating-ip-create public | awk '{if (NR==4){print $2}}'`
nova floating-ip-associate test_2 $IP_2
