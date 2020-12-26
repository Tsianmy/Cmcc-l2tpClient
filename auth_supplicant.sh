#!/bin/bash
log=/etc/xl2tpd/log.txt
> $log
if [[ ! $? -eq 0 ]];then
	echo 'failed'
	exit 220
fi

# 匹配 lns
lns=`grep 'lns' /etc/xl2tpd/xl2tpd.conf`
reg='lns\s*=\s*([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)'
if [[ ! $lns =~ $reg ]];then
	exit 221
fi
lns=${BASH_REMATCH[1]}
echo 'find lns '$lns | tee -a $log

# 启动 xl2tpd
echo "start xl2tpd"
xl2tpd -c /etc/xl2tpd/xl2tpd.conf
mkdir -p /var/run/xl2tpd
echo "c myvpn" > /var/run/xl2tpd/l2tp-control

#在发送完连接命令之后, 就每隔2s检查下有没有ppp0的接口在ifconfig中出现. 次数超过10次就exit.
count=0
while [ $count -lt 10 ]; do
	haveppp0=`ifconfig | grep ppp0`
	if [[ $haveppp0 != "" ]];then
		break
	fi
	echo 'check if ppp0 exists, time:'$count | tee -a $log
	let count=count+1
	sleep 2s
done
if [[ $count -eq 10 ]];then
	echo 'time out!' | tee -a $log
	sudo killall xl2tpd
	exit 0
fi
echo 'build ppp0' | tee -a $log

#匹配出 网关的地址. 
gateway=`ifconfig enp3s0 | grep 'inet '`
reg='.*inet ([0-9]+\.[0-9]+\.)([0-9]+\.[0-9]+).*'
if [[ $gateway =~ $reg ]];then
	pre=${BASH_REMATCH[1]}
	last=${BASH_REMATCH[2]}
else
	sudo killall xl2tpd
	exit 222
fi
default=`ip route show default | grep $pre`
reg='.* ([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+).*'
if [[ $default =~ $reg ]];then
	echo 'find gateway' | tee -a $log
else
	sudo killall xl2tpd
	exit 223
fi
gateway=${BASH_REMATCH[1]}

# 匹配出 远程server的地址
remote=`ifconfig ppp0 | grep 'inet '`
reg='.*inet ([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+).*'
if [[ $remote =~ $reg ]];then
	echo 'find remote' | tee -a $log
	remote=${BASH_REMATCH[1]}
else
	sudo killall xl2tpd
	exit 224
fi

### debug!!
echo 'the gateway is '$gateway | tee -a $log
echo 'the remote is '$remote | tee -a $log
###

#改改路由:
default=`ip route show default | grep "default via $remote dev ppp0"`
if [[ ! $default ]];then
	echo 'add default to ppp0' | tee -a $log
	route add default gw $remote dev ppp0
fi
route=`route -n | grep -E "^$lns.*$gateway"`
if [[ ! $route ]];then
	echo 'add route to lns' | tee -a $log
	route add -host $lns gw $gateway dev enp3s0
fi

echo 'Connection established'
