[关于 RabbitMQ，应该没有比这更详细的教程了！ (qq.com)](https://mp.weixin.qq.com/s/YPmW9_d4YdcjShqf255g7g) 

连接成功后，查看管理平台的 connection 选项，多了一个连接了。

未连接之前：

![image-20220529214455800](media/images/image-20220529214455800.png)

连接之后

![image-20220529214338060](media/images/image-20220529214338060.png)

查看队列，是我们刚才创建绑定的队列

![image-20220529214606832](media/images/image-20220529214606832.png)

##### 发送消息 

![image-20220529214706252](media/images/image-20220529214706252.png)

在项目端收到了消息：

![image-20220529214735297](media/images/image-20220529214735297.png)

#### 问题

#### springboot 启动后连接不上端口 

需要在防护墙添加端口 5672

![image-20220529214228407](media/images/image-20220529214228407.png)





