if [ $# -ne 4 ]; then
    echo "USAGE: $0 <login_session> <tag_name> <add/remove> <node_name>"
    exit 1
fi

NODE_ID=`sudo maas $1 nodes list hostname="$4" | egrep "\"system_id\":" | egrep -o "node-[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}"`
sudo maas $1 tag update-nodes $2 $3="$NODE_ID"
