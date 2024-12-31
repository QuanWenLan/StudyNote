https://arthas.aliyun.com/doc/quick-start.html

##### 启动jar的程序

```java
curl -O https://arthas.aliyun.com/math-game.jar
java -jar math-game.jar
```

##### 启动arthas

```shell
curl -O https://arthas.aliyun.com/arthas-boot.jar
java -jar arthas-boot.jar
```







##### 查看spring管理的bean的属性的值

```java
vmtool --action getInstances --className org.springframework.context.ApplicationContext --express 'instances[0].getBean("grayUtils")' -x 3
```

