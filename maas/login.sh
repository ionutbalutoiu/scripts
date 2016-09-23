if [ $# -ne 3 ]; then
    echo "USAGE: $0 <session_name> <maas_ip> <maas_user>"
    exit 1
fi

API_KEY=`sudo maas-region apikey --username $3`
maas login $1 http://$2/MAAS/api/2.0 $API_KEY
