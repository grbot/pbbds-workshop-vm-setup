#!/bin/sh

if [ $# -eq 0 ]
  then
    echo "No arguments supplied"
    exit 1
fi

mkdir all-plays

# Copy all default plays
for i in `cut -f 2 $1`; do 
  mkdir all-plays/$i
  cp ansible.cfg all-plays/$i
  cp inventory.yaml all-plays/$i
  cp playbook.yml all-plays/$i
  cp -r roles all-plays/$i
done

# Replace default play
while read line; do 
  user=`echo $line | awk '{print $1}'`
  server=`echo $line | awk '{print $2}'`
  local_ip=`echo $line | awk '{print $3}'`
  float_ip=`echo $line | awk '{print $4}'`
  system_pass=`echo $line | awk '{print $5}'`
  jupyter_pass=`echo $line | awk '{print $6}'`
  sed -i "s/154.114.10.170/$float_ip/" all-plays/$server/inventory.yaml
  sed -i "s/192.168.101.190/$local_ip/" all-plays/$server/inventory.yaml
  sed -i "s/john/$user/" all-plays/$server/inventory.yaml
  sed -i "s/keiC5ahYsd/$system_pass/" all-plays/$server/inventory.yaml
  sed -i "s/KIw3chee7/$jupyter_pass/" all-plays/$server/inventory.yaml
done < $1
