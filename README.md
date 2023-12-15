# StudyNote
_记录学习过程中的各种技术的笔记，包括面试时候的一些准备_  

***




### Java
***
#### 基础

- **[基础知识使用注意事项及疑难点](docs/java/基础/基础知识使用注意事项及疑难点.md)**

#### 持久化对象（集合、容器）
#### IO
#### JVM
* **[1，Java内存区域](docs/java/jvm/Java内存区域与内存溢出异常.md)**  
* **[2，垃圾回收](docs/java/jvm/垃圾收集.md)**  
  - **[理解GC日志](docs/java/jvm/理解GC日志.md)**  
* **[3，Java中四种引用和jvm参数](docs/java/jvm/四种引用和常用参数.md)**  
* **[4，理解GC日志](docs/java/jvm/理解GC日志.md)**  
* **[5，虚拟机性能监控工具 ](docs/java/jvm/虚拟机性能监控和故障处理工具.md)**  
* **[6，类文件结构](docs/java/jvm/类文件结构.md)**  
* **[7，类初始化和加载机制](docs/java/java/jvm/类加载机制.md)**  
* **[8,   虚拟机字节码执行引擎](docs/java/jvm/虚拟机字节码执行引擎.md)**
* **[9,  类加载及执行子系统的案例与实战](docs/java/jvm/类加载及执行子系统案例与实战.md)**
* **[10,  早期（编译期）优化]()**
* **[11,  晚期（运行期）优化](docs/java/jvm/运行期优化.md)**
* **[12，Java内存模型与线程](docs/java/jvm/Java内存模型与线程.md)**  
* **[13，线程安全和锁优化](docs/java/jvm/线程安全和锁优化.md)**  
#### Java8新特性

#### MySQL数据库  
- [《MySQL 实战45讲》](docs/数据库/mysql)
  - [01一条sql查询语句是如何执行的](docs/数据库/mysql/01一条sql查询语句是如何执行的.md)  
  - [02一条sql更新语句是如何执行的](docs/数据库/mysql/02一条sql更新语句是如何执行的.md)  
  - [03事务隔离](docs/数据库/mysql/03事务隔离.md)  
  - [04深入浅出索引上](docs/数据库/mysql/04深入浅出索引上.md)  
  - [05深入浅出索引下.md](docs/数据库/mysql/05深入浅出索引下.md)  
  - [06全局锁和表锁：给表加个字段这么多阻碍](docs/数据库/mysql/06全局锁和表锁：给表加个字段这么多阻碍？.md)  
  - [07行锁功过：怎么减少行锁对性能的影响](docs/数据库/mysql/07行锁功过：怎么减少行锁对性能的影响.md)  
  - [08事务到底是隔离的还是不隔离的](docs/数据库/mysql/08事务到底是隔离的还是不隔离的.md)  
  - [09普通索引和唯一索引，怎么选择](docs/数据库/mysql//09普通索引和唯一索引.md)
  - [10MySQL为什么有时候会选错索引](docs/数据库/mysql/10MySQL为什么有时候会选错索引.md)   
  - [11怎么给字符串加索引](docs/数据库/mysql/11怎么给字符串加索引.md)   
  - [12为什么我的MySQL会抖一下](docs/数据库/mysql/12为什么我的MySQL会抖一下.md)   
  - [13为什么表数据删掉一半，表文件大小不变](docs/数据库/mysql/13为什么表数据删掉一半，表文件大小不变.md)   
  - [14count()这么慢，怎么办](docs/数据库/mysql/14count\(\)这么慢，怎么办.md)   
  - [16order by是怎么工作的](docs/数据库/mysql/16orderby是怎么工作的.md)   
  - [17如何正确地显示随机消息](docs/数据库/mysql/17如何正确地显示随机消息.md)   
  - [18为什么SQL语句逻辑相同，性能却差异巨大](docs/数据库/mysql/18为什么SQL语句逻辑相同，性能却差异巨大.md)   
  - [19为什么我只查一行的语句，也执行这么慢](docs/数据库/mysql/19为什么我只查一行的语句，也执行这么慢.md)   
  - [20幻读是什么，幻读有什么问题](docs/数据库/mysql/20幻读是什么，幻读有什么问题.md)   
  - [25MySQL是怎么保证高可用的](docs/数据库/mysql/25MySQL是怎么保证高可用的.md)   
  - [13为什么表数据删掉一半，表文件大小不变](docs/数据库/mysql/13为什么表数据删掉一半，表文件大小不变.md)   
  - [26备库为什么会延迟好几个小时](docs/数据库/mysql/26备库为什么会延迟好几个小时.md)   
  - [慢查询日志](docs/数据库/mysql/慢查询日志.md) 

- [《MySQL 怎样运行的？从根上理解MySQL》](readingNotes/MySQL 怎样运行的？-从跟上理解MySQL/)

#### Spring 

- [《Spring源码深度解析》](readingNotes/Spring源码解析/)（第一版）
  - [配置文件加载，bean 加载、初始化、获取，循环依赖](readingNotes/Spring源码解析/Spring源码解析1-bean解析和加载.md)
  - [循环依赖](readingNotes/Spring源码解析/Spring源码解析6-循环依赖.md)
  - [AOP](readingNotes/Spring源码解析/Spring源码解析5-AOP.md)
  - [AOP-CGLIB的执行源码解析](readingNotes/Spring源码解析/AOP-cglib执行源码解析.md)
  - [扩展功能](readingNotes/Spring源码解析/Spring源码解析2-bean扩展.md) 
  - [消息JMS](readingNotes/Spring源码解析/Spring源码解析3-消息.md)
  - [事务](readingNotes/Spring源码解析/Spring源码解析4-事务.md) 
  - [事件监听及ApplicationContext](readingNotes/Spring源码解析/Spring-ApplicationContext及事件监听解析.md) 
  - [Aware接口](readingNotes/Spring源码解析/Spring源码解析7-Aware接口.md) 
  - [MVC源码解析](readingNotes/Spring源码解析/Spring-MVC源码.md)

#### Redis 

[《redis核心技术与实战》](readingNotes/redis核心技术与实战/目录.md) 

#### 并发

[《并发编程之美》](readingNotes/并发编程之美) 内容包括这些；



[《并发编程的艺术》](readingNotes/并发编程的艺术) 内容包括这些；

- [死锁](readingNotes/并发编程的艺术/Java并发编程的艺术.md)
- volatile定义与实现原理
- synchronized的实现原理与应用（对象头，锁升级）
- 内存模型
- 线程状态
- [Java中的锁](readingNotes/并发编程的艺术/Java中的锁和并发容器.md)
- AbstractQueuedSynchronizer 队列同步器
- Condition接口
- 并发容器
  - ArrayBlockingQueue：一个由数组结构组成的有界阻塞队列。
  - LinkedBlockingQueue：一个由链表结构组成的有界阻塞队列。
  - PriorityBlockingQueue：一个支持优先级排序的无界阻塞队列。
  - DelayQueue：一个使用优先级队列实现的无界阻塞队列。
  - SynchronousQueue：一个不存储元素的阻塞队列。
  - LinkedTransferQueue：一个由链表结构组成的无界阻塞队列。
  - LinkedBlockingDeque：一个由链表结构组成的双向阻塞队列。  
- 原子类
- Executor 框架



[completableFuture使用](docs/java/并发/completableFuture使用.md)

[concurrentHashMap原理](docs/java/并发/concurrentHashMap原理.md)

#### 网络

[《图解HTTP》](readingNotes/图解HTTP)

[《网络是怎样连接的》](readingNotes/网络是怎样连接的)
- [生成http请求底层](readingNotes/网络是怎样连接的/1-1生成发送http请求底层.md)
- [DNS服务器](readingNotes/网络是怎样连接的/1-2DNS服务器.md)
- [委托操作系统和协议栈发送消息](readingNotes/网络是怎样连接的/1-3委托操作系统和协议栈发送消息.md)
- [创建-连接-收发数据](readingNotes/网络是怎样连接的/2-1协议栈和网卡-创建-连接-收发数据.md) 包含下面几个信息
  - 创建socket，客户端与连接连接（三次握手过程）
  - 断开连接（四次挥手过程）
  - 收发数据与滑动窗口
- [IP-以太网的包收发操作](readingNotes/网络是怎样连接的/2-2协议栈和网卡-IP与以太网的包收发操作.md)
- [UDP协议收发操作](readingNotes/网络是怎样连接的/2-3协议栈和网卡-UDP协议收发操作.md)
#### 中间件

[rabbit mq](docs/rabbitmq)

#### 算法

[《小灰的算法学习之旅》](docs/算法/小灰的算法之旅-学习.md)

#### 书单

[书单](java书单.md)