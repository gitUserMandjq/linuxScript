#! /bin/bash
function log(){
  echo "$(date +"%Y-%m-%d %H:%M:%S") ""$1"
}
#定时器脚本里不会自动获取环境变量，需要手动执行
source /etc/profile
OLDIFS="$IFS"
IFS=$'\n'
for line in $(echo 6|./Quili.sh|grep -E 'Version|Unclaimed balance');do
	IFS=':'
	array=(${line})
	echo "${array[0]}""${array[1]}"
	if [ "${array[0]}" == "Version" ]
	then
		version=`echo ${array[1]}| xargs`
	elif [ "${array[0]}" == "Unclaimed balance" ]
	then
		balance=`echo ${array[1]/ QUIL/}| xargs`
	fi
done

FILE_PATH="/var/log/quili.log"
increment=$(tail -n 100 $FILE_PATH|grep -a 'increment'|tail -n 1|grep -oP '"increment":[0-9]+'| awk -F':' '{print $2}')
time_taken=$(tail -n 100 $FILE_PATH|grep -a 'time_taken'|tail -n 1|grep -oP '"time_taken":\K[^,}]*')
processNum=$(ps -aux|grep '/root/ceremonyclient'|wc -l)
nproc=$(nproc)
# 获取文件大小（以字节为单位）
FILESIZE=$(stat -c %s "$FILE_PATH")
log "日志文件大小为: $(echo "scale=2; $FILESIZE / (1024 * 1024)" | bc) MB"
# 将字节转换为兆字节，并进行大小比较
if [ $FILESIZE -gt 10485760 ]; then
    log "日志文件大于10MB，将清空: $FILE_PATH"
    # 清空文件
    truncate -s 0 "$FILE_PATH"
else
    log "日志文件小于或等于10MB，保留: $FILE_PATH"
fi
IFS="$OLD_IFS"
path=$monitorUrl'/web_crawler/eth/node/updateQuiliBalance?nodeName='$nodeName'&version='$version'&balance='$balance'&increment='$increment\
'&time_taken='$time_taken'&processNum='$processNum'&nproc='$nproc
log 'curl '$path
curl $path
#自动备份
path1=$monitorUrl'/web_crawler/eth/node/isBackup?nodeName='$nodeName
log 'curl '$path1
result=$(curl $path1)
log $result
isBackup=$(echo $result|grep -oP '"isBackup":(true|false)'| awk -F':' '{print $2}')
log 'isBackup:'$isBackup
if [[ "$isBackup" == "true" ]]; then
    log "开始备份"
    mkdir -p /root/backup
    tar -czvf  /root/backup/config.tar.gz /root/ceremonyclient/node/.config
    if ! tar -tzvf "/root/backup/config.tar.gz" &>/dev/null; then
        log "文件不完整或损坏。"
        exit 1
    else
        log "文件完整。"
    fi
    ip=$(echo $result|grep -oP '"ip":\K[^,}]*'| sed 's/"//g')
    user=$(echo $result|grep -oP '"user":\K[^,}]*'| sed 's/"//g')
    password=$(echo $result|grep -oP '"password":\K[^,}]*'| sed 's/"//g')
    filePath=$(echo $result|grep -oP '"filePath":\K[^,}]*'| sed 's/"//g')
    sshCommand="ssh -p 22 -o StrictHostKeyChecking=no \"$user@$ip\" \"mkdir -p \\\"$filePath/$nodeName\\\"\""
    scpCommand="scp -v -P 22 -o StrictHostKeyChecking=no -r /root/backup/config.tar.gz $user@$ip:$filePath/$nodeName"
    log $sshCommand
    log $password
    expect <<EOF
        set timeout 30
        spawn $sshCommand
        expect "*password:" {
            send "$password\r"
            puts "#####send password"
        }
        expect eof
EOF
    log $scpCommand
    log $password
    expect <<EOF
        set timeout 30
        spawn $scpCommand
        expect "*password:" {
            send "$password\r"
            puts "#####send password"
        }
        expect eof
EOF
	if [ $? -eq 0 ]; then
	  log "备份成功"
		curl $monitorUrl/web_crawler/eth/node/finishBackup?nodeName=$nodeName
	fi
    log "结束备份"
else
    log "不用备份"
fi