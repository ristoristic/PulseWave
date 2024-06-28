#!/bin/bash

date
echo
echo -ne “Enter CMTS IP Address: ”
read ipaddr
echo -ne “Enter CMTS SNMP Community String : ”
read community
echo -ne “Enter Cable Modem SNMP Community String : ”
read cmcommunity
echo
echo ‘# docsIfCmtsCmStatusMacAddress’
snmpwalk -v2c -c $community $ipaddr 1.3.6.1.2.1.10.127.1.3.3.1.2
echo
echo -ne “ENTER Cable Modem INDEX: ”
read cmindex
ifdescr=$(snmpget -v2c -c $community $ipaddr 1.3.6.1.4.1.4491.2.1.20.1.3.1.7.$cmindex |cut -d “:” -f2| awk ‘{print $1}’)
cmipaddr=$(snmpget -v2c -c $community $ipaddr 1.3.6.1.2.1.10.127.1.3.3.1.3.$cmindex |cut -d “:” -f2 | awk ‘{print $1}’)
cmdsindex=$(snmpget -v2c -c $community $ipaddr 1.3.6.1.2.1.10.127.1.3.3.1.4.$cmindex | cut -d “:” -f2| awk ‘{print $1}’)
cmusindex=$(snmpget -v2c -c $community $ipaddr 1.3.6.1.2.1.10.127.1.3.3.1.5.$cmindex | cut -d “:” -f2| awk ‘{print $1}’)
cmusmodtype=$(snmpget -v2c -c $community $ipaddr 1.3.6.1.2.1.10.127.1.1.2.1.4.$cmusindex | cut -d “:” -f2| awk ‘{print $1}’)
echo
echo -ne “cmindex : ” ; echo $cmindex
echo "Debugging: snmpget output: $(snmpget -v2c -c $community $ipaddr 1.3.6.1.4.1.4491.2.1.20.1.3.1.7.$cmindex)"
echo -ne “ifDescr : ” ; echo $ifdescr
echo -ne “cmipaddr : ” ; echo $cmipaddr
echo -ne “cmdsindex : ” ; echo $cmdsindex
echo -ne “cmusindex : ” ; echo $cmusindex
echo