glance image-create --name=cirros --container-format=bare --copy-from=http://download.cirros-cloud.net/0.3.3/cirros-0.3.3-x86_64-disk.img --is-public disk-format=qcow2 --progress
while [ "`glance image-list | grep cirros | awk '{print $11}'`" != "active" ]; do
    echo "Image is not active. Sleeping 2 seconds..."
    sleep 2
done
