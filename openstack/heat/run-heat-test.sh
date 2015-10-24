if [ $# -ne 1 ]; then
    echo "USAGE: $0 <stack_number>"
    exit 1
fi

DIR=`dirname $0`
NET_ID=$(nova net-list | awk '/ private / { print $2 }')
heat stack-create -f "$DIR/basic.yaml" -P "ImageID=cirros;NetID=$NET_ID" test_stack_$1
