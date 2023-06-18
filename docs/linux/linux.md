### Linux 配置 Java 环境变量

#### 1 查看 Linux 环境

```sh
[root@VM-12-9-centos /]# uname -a
Linux VM-12-9-centos 4.18.0-348.7.1.el8_5.x86_64 #1 SMP Wed Dec 22 13:25:12 UTC 2021 x86_64 x86_64 x86_64 GNU/Linux
```

#### 2 安装配置步骤

##### 2.1 下载并上传 JDK

1.8.0_144 压缩包，链接：https://pan.baidu.com/s/1TOl0QdAEDwyJMjaZjUcdtA?pwd=1q2u 
提取码：1q2u 

Oracle 官网下载地址：[Java Downloads | Oracle](https://www.oracle.com/java/technologies/downloads/#java8) 

可以访问 [oracle.com passwords - BugMeNot](http://bugmenot.com/view/oracle.com) 获取Oracle的账号，不需要注册。下载后上传到服务器并解压。我这里上传到了 /home/jdk 里面

```sh
[root@VM-12-9-centos jdk]# ls
jdk-11.0.15.1_windows-x64_bin.zip  jdk-8u351-linux-x64.tar.gz
[root@VM-12-9-centos jdk]# pwd
/home/jdk
[root@VM-12-9-centos software]# tar -zxf /home/jdk/jdk-8u351-linux-x64.tar.gz -C ./jdk
[root@VM-12-9-centos jdk]# cd jdk1.8.0_351/
[root@VM-12-9-centos jdk1.8.0_351]# pwd
/usr/local/software/jdk/jdk1.8.0_351
```

##### 2.2 配置 JAVA_HOME 

打开 /etc/profile 文件 `vim /etc/profile`; 在文件末尾处添加以下内容：

```properties
export JAVA_HOME=/usr/local/software/jdk/jdk1.8.0_351
export JRE_HOME=${JAVA_HOME}/jre
export CLASSPATH=.:${JAVA_HOME}/lib:${JRE_HOME}/lib
export PATH=${JAVA_HOME}/bin:$PATH
```

##### 2.3 检查是否生效

需要刷新一下 profile 文件，使用 `source /etc/profile`

```sh
[root@VM-12-9-centos jdk1.8.0_351]# java -version
-bash: java: command not found
[root@VM-12-9-centos jdk1.8.0_351]# echo $JAVA_HOME

[root@VM-12-9-centos jdk1.8.0_351]# source /etc/profile
[root@VM-12-9-centos jdk1.8.0_351]# java -version
java version "1.8.0_351"
[root@VM-12-9-centos jdk1.8.0_351]# echo $JAVA_HOME
/usr/local/software/jdk/jdk1.8.0_351
```

如果上面的 `echo $JAVA_HOME` 输出不了则用下面步骤：

```sh
[lan@192 etc]$ which java
/usr/bin/java
[lan@192 etc]$ ls -lrt /usr/bin/java
lrwxrwxrwx. 1 root root 22 Apr  3 06:41 /usr/bin/java -> /etc/alternatives/java
[lan@192 etc]$ ls -lrt /etc/alternatives/java
lrwxrwxrwx. 1 root root 71 Apr  3 06:41 /etc/alternatives/java -> /usr/lib/jvm/java-1.8.0-openjdk-1.8.0.181-7.b13.el7.x86_64/jre/bin/java
[lan@192 etc]$ 
```

然后编辑 `/etc/profile`文件在文件末尾添加：

```sh
export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.181-7.b13.el7.x86_64/jre/bin/java
export JRE_HOME=${JAVA_HOME}/jre
export CLASSPATH=.:${JAVA_HOME}/lib:${JRE_HOME}/lib
export PATH=${JAVA_HOME}/bin:$PATH

```

### 关闭某个端口

查看所有端口号

```sh
netstat -tanlp
```

查找指定的端口

```sh
[root@192 bin]# netstat -anp|grep 2181
tcp6       0      0 :::2181                 :::*                    LISTEN      off (0.00/0/0)
tcp6       0      0 127.0.0.1:59822         127.0.0.1:2181          TIME_WAIT   timewait (13.44/0/0)
```

此时上面是看不到pid的，所以，`kill -9 pid` 是不知道那个pid。所以用下面这种关闭指定端口号

```sh
[root@192 bin]# sudo fuser -k -n tcp 2181
2181/tcp:            10866
[root@192 bin]# netstat -ano | grep 2181
```

此时再次查看端口占用，发现是没有被占用。

### 配置静态IP

#### 1 设置网络

先查看自己当前的IP地址，`ip addr` 或者是 `ifconfig`，然后记住这个ip和掩码，再编辑配置文件 ` vi /etc/sysconfig/network-scripts/ifcfg-ens33` :

```sh
[root@localhost bin]# cat /etc/sysconfig/network-scripts/ifcfg-ens33 
TYPE="Ethernet"
PROXY_METHOD="none"
BROWSER_ONLY="no"
# 需要将这个改成 static
BOOTPROTO="static" 
DEFROUTE="yes"
IPV4_FAILURE_FATAL="no"
IPV6INIT="yes"
IPV6_AUTOCONF="yes"
IPV6_DEFROUTE="yes"
IPV6_FAILURE_FATAL="no"
IPV6_ADDR_GEN_MODE="stable-privacy"
NAME="ens33"
UUID="fb9ec427-7f41-43e3-8b35-593150de0e60"
DEVICE="ens33"
# 配置网卡开机自启动
ONBOOT="yes"
# 新增下面几个
# 静态ip
IPADDR="192.168.146.128"
# 子网掩码
NETMASK="255.255.255.0"
# 网关
GATEWAY="192.168.146.2"
# DNS
DNS="192.168.146.2"
```

可以使用 `router -n` 来查看 DNS 和网关地址，随后再重启网络，`systemctl restart network`，然后再查看ip是不是更改过来了。

[Linux查看及设置DNS服务器 - 腾讯云开发者社区-腾讯云 (tencent.com)](https://cloud.tencent.com/developer/article/1963426) 

![image-20230405132956467](E:\project\IdeaProjects\StudyNote\docs\linux\images\image-20230405132956467.png)

框出来的就代表不是动态ip而是静态ip了。

#### 2 设置虚拟网络编辑器

![image-20230405133101214](E:\project\IdeaProjects\StudyNote\docs\linux\images\image-20230405133101214.png)

设置子网IP和网关IP

<img src="E:\project\IdeaProjects\StudyNote\docs\linux\images\image-20230405133152332.png" alt="image-20230405133152332" style="zoom:67%;" />

点NAT进去的设置

<img src="E:\project\IdeaProjects\StudyNote\docs\linux\images\image-20230405133245114.png" alt="image-20230405133245114" style="zoom:67%;" />

如果添加了多个虚拟机的话，网关这里需要设置相同。只需要IPADDR不同就行了。



#### 防火墙命令

##### 1 查看 firewall 服务状态

![image-20220525114417511](E:\project\IdeaProjects\StudyNote\docs\linux\images\image-20220525114417511.png)

##### 2 查看firewall的状态

firewall-cmd --state 

![image-20220525114448089](E:\project\IdeaProjects\StudyNote\docs\linux\images\image-20220525114448089.png)

##### 3 开启、重启、关闭、firewalld.service服务

开启：`service firewalld start`

重启： `service firewalld restart`

关闭：`service firewalld stop`

##### 4 查看防火墙规则

`firewall-cmd --list-all`

![image-20220525114622113](E:\project\IdeaProjects\StudyNote\docs\linux\images\image-20220525114622113.png)

我这里腾讯云服务器，还要在控制台添加对应的规则才行

![image-20220525114700372](E:\project\IdeaProjects\StudyNote\docs\linux\images\image-20220525114700372.png)

##### 5 查询、开放、关闭端口 

`firewall-cmd --query-port=80/tcp`

开放80端口

`firewall-cmd --permanent --add-port=80/tcp`

移除端口

`firewall-cmd --permanent --remove-port=8080/tcp`

##### 重启防火墙(修改配置后要重启防火墙) ---必须操作

`firewall-cmd --reload`

#### 关闭防火墙

`systemctl stop firewalld.service`：停止firewall

`systemctl disable firewalld.service`：禁止firewall开机启动

`firewall-cmd --state`：查看默认防火墙状态（关闭后显示notrunning，开启后显示running）



#### 22端口访问不了

使用腾讯云的VNC或者网页登录后，切换到目录 /etc/ssh 下。

- 执行 systemctl start sshd 命令
- 执行netstat -lunpt命令看下sshd服务是否监听
- 执行 sshd -t命令排除故障
- 执行 systemctl restart sshd 重启服务

备用方法：

1.systemctl stop firewalld
2.iptables -I INPUT -p tcp --dport 11222 -j ACCEPT
执行完后访问测试，如果不通执行下面命令
3.iptables-save > /iptables.save
4.iptables -F
5.setenforce 0



同样的案例： 收到腾讯云官方的违规提醒：https://www.cnblogs.com/whot/p/15294467.html

[一次惨痛的教训：被pnscan病毒攻击的经过](https://blog.csdn.net/chenmozhe22/article/details/112578057) 

#### Windows 查看端口并结束占用

1. 查找所有运行的端口

`netstat ano`

2. 查看被占用端口对应的 PID

`netstat -aon|findstr "8081"`

3. 查看指定 PID 的进程

`tasklist|findstr "9088"`

4. 结束进程

`taskkill /T /F /PID 9088`

