#!/bin/bash
sudo apt install ppp xl2tpd
if [[ ! $? -eq 0 ]];then
	exit 233
fi

echo

if [[ ! -f /etc/xl2tpd/xl2tpd.conf.bak ]];then
	echo 'backup /etc/xl2tpd/xl2tpd.conf'
	sudo cp /etc/xl2tpd/xl2tpd.conf /etc/xl2tpd/xl2tpd.conf.bak
fi

echo 'copy and link auth_supplicant.sh'
sudo cp -f $(dirname $0)/auth_supplicant.sh /usr/local/etc/
sudo chmod a+x /usr/local/etc/auth_supplicant.sh
sudo ln -sf /usr/local/etc/auth_supplicant.sh /usr/local/bin/auth_supplicant

echo 'done'
