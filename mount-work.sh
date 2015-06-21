if [ $# -ne 4 ]; then
    echo "USAGE: $0 <smb_user> <smb_password> <smb_dir> <mount_dir>"
    exit 1
fi

USER="$1"
PASSWORD="$2"
SMB_DIR="$3"
MOUNT_DIR="$4"

if [ ! -d $MOUNT_DIR ]; then
    mkdir $MOUNT_DIR
fi

sudo mount -t cifs -o username=$USER,password=$PASSWORD $SMB_DIR $MOUNT_DIR
