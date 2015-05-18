if [ $# -ne 1 ]; then
    echo "USAGE: $0 <login_session>"
    exit 1
fi

sudo maas $1 tags list | egrep "\s*\"name\"" | cut -d':' -f2
