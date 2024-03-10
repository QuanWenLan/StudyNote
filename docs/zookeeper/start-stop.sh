#! /bin/bash

case $1 in
"start"){
    for i in 192.168.146.128 192.168.146.129 192.168.146.130 
    do
        echo ------------ zookeeper $i 启动 ---------------
    ssh $i "/opt/module/zookeeper-3.5.7/bin/zkServer.sh start"
    done
};;
"stop"){
    for i in 192.168.146.128 192.168.146.129 192.168.146.130 
    do
        echo ------------ zookeeper $i 启动 ---------------
    ssh $i "/opt/module/zookeeper-3.5.7/bin/zkServer.sh stop"
    done
};;
"status"){
    for i in 192.168.146.128 192.168.146.129 192.168.146.130 
    do
        echo ------------ zookeeper $i 启动 ---------------
    ssh $i "/opt/module/zookeeper-3.5.7/bin/zkServer.sh status"
    done
};;