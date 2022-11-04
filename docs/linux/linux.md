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

