### 安装与启动 rabbitmq  

查询rabbitMQ镜像：

management版本，不指定默认为最新版本latest

` docker search rabbitmq:management`

 拉取镜像：

`docker pull rabbitmq:management`

查看 docker 镜像列表 `docker images`

![image-20220529161740128](media/images/image-20220529161740128.png)

启动：

`docker run -d -p 5672:5672 -p 15672:15672 --name rabbitmq rabbitmq:management`

可以参考官网资料： https://hub.docker.com/_/rabbitmq ，5672 通信端口，15672 后端管理的web页面

```java
$ docker run -d --hostname my-rabbit --name some-rabbit rabbitmq:3-management
```

- -d 后台运行
- -p 隐射端口
- –name 指定rabbitMQ名称
- 

![image-20220529162024054](media/images/image-20220529162024054.png)



复杂版本：

```java
docker run -d -p 15672:15672  -p  5672:5672  -e RABBITMQ_DEFAULT_USER=admin -e RABBITMQ_DEFAULT_PASS=admin --name rabbitmq --hostname=rabbitmqhostone rabbitmq:management
```

- -d 后台运行
- -p 隐射端口
- –name 指定rabbitMQ名称
- RABBITMQ_DEFAULT_USER 指定用户账号
- RABBITMQ_DEFAULT_PASS 指定账号密码

执行如上命令后访问：http://ip:15672/

默认账号密码：guest/guest

![image-20220529210117504](media/images/image-20220529210117504.png)

我的是腾讯云，需要添加端口访问：

![image-20220529210152186](media/images/image-20220529210152186.png)

登录之后的状态“

![image-20220529210246008](media/images/image-20220529210246008.png)

#### 查看运行中的容器

```javascript
# 查看所有的容器用命令docker ps -a
docker ps
```

#### 启动容器

```javascript
# eg: docker start 9781cb2e64bd
docker start CONTAINERID[容器ID]
```

stop容器

```javascript
docker stop CONTAINERID[容器ID]
```

删除一个容器

```javascript
 docker rm CONTAINERID[容器ID]
```

查看Docker容器日志

```javascript
# eg：docker logs 9781cb2e64bd
docker logs container‐name[容器名]/container‐id[容器ID]
```

常见的docker镜像操作：来源：[Docker系列之RabbitMQ安装部署教程](https://cloud.tencent.com/developer/article/1612598) 

![image-20220529210427678](media/images/image-20220529210427678.png)