#! /bin/bash
source /root/.bashrc
url='204.12.203.253:82'
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
path=$url'/web_crawler/eth/node/updateQuiliBalance?nodeName='$nodeName'&version='$version'&balance='$balance
echo 'curl '$path
curl $path
