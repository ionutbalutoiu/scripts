if [ $# -ne 2 ]; then
    echo "USAGE: $0 <login_session> <node_name>"
    exit 1
fi

NODE_ID=`maas $1 nodes list hostname="$2" | egrep "\"system_id\":" | egrep -o "node-[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}"`
maas $1 node start "$NODE_ID"
