#!/bin/bash

export LINODE_ACCESS_TOKEN='XXX'
HOSTFILE=ansible/host.ini
PB=ansible/playbooks/linuxgsm.p

#Clobber existing file 
echo "[linuxgsm]" >$HOSTFILE
ansible-inventory -i ansible/linuxgsm/linode.yml --graph --vars|grep ipv4|awk '{print $5}'|tr -d \[\'\]\} >> $HOSTFILE
echo "[linuxgsm:vars]" >>$HOSTFILE
echo ansible_ssh_common_args=\'-o StrictHostKeyChecking=no\' >>$HOSTFILE
ansible -m ping linuxgsm -i

ansible-playbook $PB -u root --private-key id_rsa -i $HOSTFILE