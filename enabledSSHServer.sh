#!/bin/sh
addConfig(){
#判断 file.sh 文件中是否存在该字符串
echo "param:${1}"
if grep "#${1}" /etc/ssh/sshd_config  >/dev/null
then
#存在注释，则替换
   echo "replace file:#${1} to ${1}"
   sed -i "s/#${1}/${1}/g" /etc/ssh/sshd_config
elif ! grep ${1} /etc/ssh/sshd_config  >/dev/null
then
#不存在，添加字符串
   echo "input file:${1}"
   sed -i "$a${1}" /etc/ssh/sshd_config
else
#存在，不做处理
   echo "not input file"
fi
}
replaceConfig(){
#判断 file.sh 文件中是否存在该字符串
echo "param:${1}"
if grep "#${1}" /etc/ssh/sshd_config  >/dev/null
then
#存在注释，则替换
   echo "replace file:#${1} to ${1}"
   sed -i "s/#${1}/${1}/g" /etc/ssh/sshd_config
else
#存在，不做处理
   echo "not input file"
fi
}
#执行该函数
addConfig "RSAAuthentication yes"
addConfig "PubkeyAuthentication yes"
replaceConfig "AuthorizedKeysFile"
systemctl restart sshd