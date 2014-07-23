#!/bin/bash

if [[ $1  == "-f" && $2 != "" && -d "/etc/racoon/remote" ]]; then
vpnip=`dig +short $2`
echo $vpnip
	if [ ! -f  /var/run/racoon/$vpnip.conf ]; then
		echo "You should connect the VPN first, then do this!"
		exit 1
	fi
echo "Your VPN connection will be disconnected when fixing..."
sudo sed -i -e 's/lifetime time 3600 sec/lifetime time 240 hours/' /var/run/racoon/$vpnip.conf
sudo mv /var/run/racoon/$vpnip.conf /etc/racoon/remote
sudo launchctl stop com.apple.racoon
sudo launchctl start com.apple.racoon
echo "$2 should be fixed now, reconnect VPN and try it."
exit 1
fi

if [[ $1  == "-r" && $2 != "" && -d "/etc/racoon/remote" ]]; then
vpnip=`dig +short $2`
echo $vpnip
sudo rm -rf /etc/racoon/remote/$vpnip.conf
echo "$2 fix removed."
exit 1
fi

if [[ $1  == "fix" ]]; then

sudo mv /etc/racoon/racoon.conf.origbak /etc/racoon/racoon.conf
sudo rm -rf /etc/racoon/remo*
sudo rm -rf /etc/racoon/racoon.conf.r*
exit 1

fi

if [[ $1  == "debug" ]]; then

sudo ls -alhs /etc/racoon/
sudo ls -alhs /etc/racoon/remote/
sudo cat /etc/racoon/racoon.conf|tail -n 10
sudo grep -r hour /etc/racoon/remote/
exit 1

fi

if [ "$1" = "" ];then
c=`grep '/etc/racoon/remote/' /etc/racoon/racoon.conf | grep -v '#' | wc -l`
if [[ $c -eq 0 ]]; then
sudo mkdir /etc/racoon/remote
sudo cp /etc/racoon/racoon.conf{,.origbak}
sudo patch /etc/racoon/racoon.conf <<EOF
--- /etc/racoon.orig/racoon.conf 2009-06-23 09:09:08.000000000 +0200
+++ /etc/racoon/racoon.conf 2009-12-11 13:52:11.000000000 +0100
@@ -135,4 +135,5 @@
 # by including all files matching /var/run/racoon/*.conf
 # This line should be added at the end of the racoon.conf file
 # so that settings such as timer values will be appropriately applied.
+include "/etc/racoon/remote/*.conf" ;
 include "/var/run/racoon/*.conf" ;
EOF
sudo launchctl stop com.apple.racoon
sudo launchctl start com.apple.racoon
echo "Ya, system fixed, then each VPN connection should fix one by one."
fi

if [ -d "/etc/racoon/remote" ]; then
	echo "Seems you had fixed system. Now if you need to fix one or more VPN connection, please use ' ./fix_auto_disconnect.sh -f some.vpnserver.com '. For example, you added a new VPN e.g. us1.gfw.io to your Mac OS, you should do ' ./fix_auto_disconnect.sh -f us1.gfw.io ' in your terminal."
fi
fi
