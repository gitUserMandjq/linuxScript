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
path=$monitorUrl'/web_crawler/eth/node/updateQuiliBalance?nodeName='$nodeName'&version='$version'&balance='$balance'&increment='$increment
log 'curl '$path
curl $path