#!/bin/ash
set -x
set -e
# script for centos
# Require passwordless ssh and pssh installed
# hostname and ports optional

# fixing command for script input
if [ "$#" -ne 2 ]; then
  echo "Usage (1): bash script.sh [ip:port file] [cmd] "
  echo "cmd: install, start, ssh_all_1, ssh_all_2, pssh_all..."
	exit 1
fi


# common variables ----------------------------------------------------
myIP=$(hostname -I | cut -d' ' -f1)
CWD=$(pwd) # /home/cc/pgsql
# all hosts use same db name and path
host_file=$1
cmd=$2

hostname_list=()
hostname_str=""
ip_list=()
ip_str=""
port_list=() #optional
port_str="" #optional

# prepare needed variables -----------------------------------------
# parsing host file into array ------------
while IFS= read -r line
do
  #echo "$line"
  IFS=@ read hostname ipport <<< "$line"
  IFS=: read ip port <<< "$ipport"

  hostname_list+=( $hostname )
  hostname_str="$hostname_str$hostname "

  ip_list+=( $ip )
  ip_str="$host1_str$ip "

  port_list+=( $port )
  port_str="$port1_str$port "

done < "$host_file"

echo "hostnames: $hostname_str"
echo "hosts: $ip_str"
echo "ports: $port_str"
let "numhosts = ${#ip_list[@]} "


# finctions ----------------------------------------------------
ssh_all_1(){ # modify for use

for node in ${ip_list[@]}
do
  ssh $node /bin/bash << EOF
echo "In host ${node}"
echo "Exiting host ${node}"
EOF
done
}

ssh_all_2(){ # modify for use

for i in `seq 1 $numhosts`
do
  node=${ip_list[$i]}
	ssh $node << EOF
echo "In host ${node}"
echo "Exiting host ${node}"
EOF
done
}

pssh_all(){

  pssh -i -H "$hosts_str" echo "pssh command timeout 60 sec"
  pssh -i -H "$hosts_str" -t 0 'echo "pssh command no timeout"; echo "Careful!"'
}

### Installation
install(){

  for node in ${ip_list[@]}
  do
    ssh $node /bin/bash << EOF
echo "Starting install on ${node}"
sudo yum update -y
EOF
  done

}


startservers(){

  echo "Clean up servers"
  pssh -i -H "$hosts_str" echo "Do some cleanup"

  if [ ${#hosts_list[@]} -eq ${#ports_list[@]} ]; then
		echo "hosts numbers and port numbers does match!!"
	fi

  ### start servers
  for i in `seq 0 $numhosts`
  do
    node=${ip_list[$i]}
    port=${port_list[$i]}
          ssh $node /bin/bash << EOF
echo "Starting server on ${node}:${port}"
EOF

  pssh -i -H "$hosts_str" echo "Do some mroe setup"

done

}



# input options ----------------------------------------------------
if [ "$2" == "install" ]; then
  install
  echo "Installation done."
  exit 0
fi

if [ "$2" == "start" ]; then
  startservers
  echo "Server start done."
  exit 0
fi


if [ "$2" == "ssh_all_1" ]; then ssh_all_1; fi

if [ "$2" == "ssh_all_2" ]; then ssh_all_2; fi

if [ "$2" == "pssh_all" ]; then pssh_all; fi
