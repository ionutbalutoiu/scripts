if [ $# -ne 2 ]; then
    echo "USAGE: $0 <login_session> <tag_name>"
    exit 1
fi

maas $1 tags new name="$2"
