#! /bin/bash
function log(){
  echo "$(date +"%Y-%m-%d %H:%M:%S") ""$1"
}
source /etc/profile
mkdir -p /root/backup
tar -czvf  /root/backup/config.tar.gz /root/ceremonyclient/node/.config
path1=$monitorUrl'/web_crawler/eth/node/isBackup?nodeName='$nodeName
log 'curl '$path1
result=$(curl $path1)
log $result
isBackup=$(echo $result|grep -oP '"isBackup":(true|false)'| awk -F':' '{print $2}')
log 'isBackup:'$isBackup
if [[ "$isBackup" == "true" ]]; then
    log "开始备份"
    ip=$(echo $result|grep -oP '"ip":\K[^,}]*'| sed 's/"//g')
    user=$(echo $result|grep -oP '"user":\K[^,}]*'| sed 's/"//g')
    password=$(echo $result|grep -oP '"password":\K[^,}]*'| sed 's/"//g')
    filePath=$(echo $result|grep -oP '"filePath":\K[^,}]*'| sed 's/"//g')
    scpCommand="scp -v -P 22 -r /root/backup/config.tar.gz $user@$ip:$filePath/$nodeName"
    log $scpCommand
    log $password
    expect -c "
        set timeout 30
        spawn $scpCommand
        expect \"Are you sure you want to continue connecting\" {
            send \"yes\r\"
        }
        expect \"password:\" {
            send \"$password\r\"
        }
        expect \"Exit status 0\" {
            exec bash -c \"curl $monitorUrl/web_crawler/eth/node/finishBackup?nodeName=\$nodeName\"
        }
        expect {
            timeout {
                puts \"Error: SCP command timed out.\"
            }
            eof {
                puts \"Error: SCP command failed unexpectedly.\"
            }
        }
        expect eof
    "
    log "结束备份"
else
    log "不用备份"
fi
