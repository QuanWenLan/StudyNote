#### 防火墙命令

##### 1 查看 firewall 服务状态

![image-20220525114417511](media/images/image-20220525114417511.png)

##### 2 查看firewall的状态

firewall-cmd --state 

![image-20220525114448089](media/images/image-20220525114448089.png)

##### 3 开启、重启、关闭、firewalld.service服务

开启：`service firewalld start`

重启： `service firewalld restart`

关闭：`service firewalld stop`

##### 4 查看防火墙规则

`firewall-cmd --list-all`

![image-20220525114622113](media/images/image-20220525114622113.png)

我这里腾讯云服务器，还要在控制台添加对应的规则才行

![image-20220525114700372](media/images/image-20220525114700372.png)

##### 5 查询、开放、关闭端口 

`firewall-cmd --query-port=80/tcp`

开放80端口

`firewall-cmd --permanent --add-port=80/tcp`

移除端口

`firewall-cmd --permanent --remove-port=8080/tcp`

##### 重启防火墙(修改配置后要重启防火墙) ---必须操作

`firewall-cmd --reload`