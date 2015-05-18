if [ $# -ne 1 ]; then
    echo "USAGE: $0 <login_session>>"
    exit 1
fi

sudo maas $1 nodes list | grep 'hostname' | cut -d':' -f2
