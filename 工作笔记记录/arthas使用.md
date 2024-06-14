##### 查看spring管理的bean的属性的值

```java
vmtool --action getInstances --className org.springframework.context.ApplicationContext --express 'instances[0].getBean("grayUtils")' -x 3
```

