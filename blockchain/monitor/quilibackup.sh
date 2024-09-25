#! /bin/bash
function log(){
  echo "$(date +"%Y-%m-%d %H:%M:%S") ""$1"
}
source /etc/profile
mkdir -p /root/backup
tar -czvf  /root/backup/config.tar.gz /root/ceremonyclient/node/.config
