#! /bin/bash
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
IFS="$OLD_IFS"
path=$monitorUrl'/web_crawler/eth/node/updateQuiliBalance?nodeName='$nodeName'&version='$version'&balance='$balance
echo 'curl '$path
curl $path
