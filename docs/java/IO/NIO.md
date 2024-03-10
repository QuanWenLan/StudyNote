###  Java的NIO（尚硅谷NIO学习笔记）

https://www.bilibili.com/video/BV14W411u7ro

|             IO             |                NIO                 |
| :------------------------: | :--------------------------------: |
| 面向流 （Stream Oriented） |   面向缓冲区（Buffer Oriented）    |
|   阻塞IO（Blocking IO）    | 非阻塞IO（Non（New） Blocking IO） |
|             无             |               选择器               |
1. IO流相当于水流。
- 目标数据读取数据到程序中叫输入流；从程序中输出数据到目标地点叫做输出流（简而言之）。
2. NIO传输数据相当于管道、通道。
- 通道只适用于**连接数据传输的道路**，传输数据实际上是用**缓冲区**来传输的。**缓冲区**是一个双向的，既面向文件又面向程序。
- NIO的核心在于：**通道（Channel）**和**缓冲区（Buffer）**。通道表示打开到IO设备（例如：文件、套接字）的连接。**简而言之Java的NIO和IO的区别：channel负责传输，buffer负责存储。**

***
#### 缓冲区（Buffer）
1. 在Java NIO中负责数据的存取。缓冲区就是数组，用于存储不同数据类型的数据。比如：ByteBuffer、CharBuffer、ShortBuffer、IntBuffer、LongBuffer、FloatBuffer、DoubleBuffer。
2. 创建缓冲区。
- 通过使用allocate()方法分配一个缓冲区。
- 缓冲区的四个核心属性，**capacity**，容量，一旦申明不能改变；**limit**：界限，可以操作数据的大小；**position**：位置，正在操作数据的位置；**mark**：表示记录当前position的位置，可以通过mark()方法标记当前位置，随后可以通过reset()方法恢复到mark的位置。
`// Invariants（不变性）: mark <= position <= limit <= capacity
`
#####  非直接缓冲区   

非直接缓冲区多了**复制**的步骤，降低了效率。通过allocate()方法分配缓冲区，将缓冲区建立在JVM的内存中。

<img src="media/images/image-20200728151658300.png" alt="image-20200728151658300" style="zoom:50%;" />

##### 直接缓冲区

通过allocateDirect()方法分配直接缓冲区，将缓冲区建立在 **物理内存中**，可以提高效率。

```java
ByteBuffer buffer = ByteBuffer.allocateDirect(1024);
System.out.println(buffer.isDirect()); 
```

<img src="media/images/image-20200728151713878.png" alt="image-20200728151713878" style="zoom:50%;" />

***
#### 通道（Channel）
- 早期的操作系统处理IO接口
![image-20200728150244641](media/images/image-20200728150244641.png)

- DMA（直接存储器存储）
![image-20200728150321164](media/images/image-20200728150321164.png)
- 使用通道（通道是一个**完全独立的处理器**，专门用于IO操作，此时不需要向CPU请求处理IO接口上的操作，而是直接处理IO操作）
![image-20200728150356698](media/images/image-20200728150356698.png)

*如果有很大型的、很多的IO操作，这个时候通道的效率就体现出来了*。通道要配合缓冲区才能使用。

**Java 为 Channel 接口提供的最主要实现类如下：**

- FileChannel：用于读取、写入、映射和操作文件的通道。
- DatagramChannel：通过 UDP 读写网络中的数据通道。 
- SocketChannel：通过 TCP 读写网络中的数据。 
- ServerSocketChannel：可以监听新进来的 TCP 连接，对每一个新进来 的连接都会创建一个 SocketChannel。

**获取通道**

1. 获取通道的一种方式是对支持通道的对象调用 getChannel() 方法。支持通道的类如下：
* FileInputStream 
* FileOutputStream 
* RandomAccessFile 
* DatagramSocket 
* Socket 
* ServerSocket
2. 获取通道的其他方式是使用 Files 类的静态方法 newByteChannel() 获取字节通道。或者通过通道的静态方法 open() 打开并返回指定通道。
**通道的数据传输**
`ByteBuffer dst = ByteBuffer.allocate(1024);`
- 写数据
例如：将**buffer**数组中的数据写入**Channel**
`outChannel.write(dst);`
- 读数据
例如：从 **Channel** 读取数据到**Buffer**
`inChannel.read(dst);`
示例：
```Java
@Test
    public void test1() {
        FileInputStream fileInputStream = null;
        FileOutputStream fileOutputStream = null;
        FileChannel inChannel = null;
        FileChannel outChannel = null;
        try {
//            fileInputStream = new FileInputStream("E:\\project\\IdeaProjects\\javaDemo\\src\\test\\java\\1.png");
            String c = this.getClass().getResource("/").getPath();
            fileInputStream = new FileInputStream(c + "/1.png");
//            fileOutputStream = new FileOutputStream("E:\\project\\IdeaProjects\\javaDemo\\src\\test\\java\\2.png");
            fileOutputStream = new FileOutputStream(c + "/2.png");


            // channel只是通道，操作数据是要用缓冲区来操作
            inChannel = fileInputStream.getChannel();
            outChannel = fileOutputStream.getChannel();


            // 使用普通的数据读写来读取数据
            ByteBuffer dst = ByteBuffer.allocate(1024);
            while (inChannel.read(dst) != -1) {
                // 切换数据为读数据的模式
                dst.flip();
                outChannel.write(dst);
                dst.clear();// 这次读取完数据之后，清空dst，所有的数据limit，position，回归到默认
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (outChannel != null) {
                try {
                    fileInputStream.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
            if (inChannel != null) {
                try {
                    fileInputStream.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
            if (fileOutputStream != null) {
                try {
                    fileInputStream.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
            if (fileInputStream != null) {
                try {
                    fileInputStream.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }
    }
```
##### FileChannel通道的常用方法：

<img src="media/images/image-20200730171210062.png" alt="image-20200730171210062" style="zoom:50%;" />

#### 分散读取(Scatter Reads)和聚集写入(Gather Writes)

1. 分散读取（scatter reads）是指从Channel中读取的数据“分散”到多个buffer中。

   <img src="media/images/image-20200728173608476.png" alt="image-20200728173608476" style="zoom: 33%;" />

   注意：**按照缓冲区的顺序，从Channel中读取的数据一次将Buffer填满**。

2. 聚集写入（gathering writes）是指将多个Buffer中的数据“聚集”到Channel中。

<img src="media/images/image-20200728173901346.png" alt="image-20200728173901346" style="zoom: 33%;" />

​		注意：**按照缓冲区的顺序，写入position和limit之间的数据到Channel**。

***

### NIO的非阻塞式网络通信

- 传统的 IO 流都是阻塞式的。也就是说，当一个线程调用 read() 或 write()时，该线程被阻塞，直到有一些数据被读取或写入，该线程在此期间不能执行其他任务。因此，在完成网络通信进行 IO 操作时，由于线程会阻塞，所以服务器端必须为每个客户端都提供一个独立的线程进行处理，当服务器端需要处理大量客户端时，性能急剧下降。
- Java NIO 是非阻塞模式的。当线程从某通道进行读写数据时，若没有数据可用时，该线程可以进行其他任务。线程通常将非阻塞 IO 的空闲时间用于在其他通道上执行 IO 操作，所以单独的线程可以管理多个输入和输出通道。因此，NIO 可以让服务器端使用一个或有限几个线程来同时处理连接到服务器端的所有客户端。

1. **使用NIO完成网络通信的三个核心。**

   1.1 通道（Channel）负责连接

   java.nio.channels.Channel 接口： 

   * |--SelectableChannel                
   * |--SocketChannel              
   * |--ServerSocketChannel              
   * |--DatagramChannel      

   

   * |--Pipe.SinkChannel             
   * |--Pipe.SourceChannel

   1.2 缓冲区(Buffer):负责数据的存取

   1.2 选择器(Selector):是 SelectableChannel 的多路复用器。用于监控SelectableChannel的IO状况

2. **选择器（Selector）**

选择器（Selector） 是 SelectableChannle 对象的**多路复用器**，Selector 可以同时监控多个 **SelectableChannel**的 **IO 状况**，也就是说，利用 Selector 可使一个单独的线程管理多个 Channel。Selector 是非阻塞 IO 的核心。









### 知识补充（NIO 底层原理）

#### 1 Java IO 读写原理

[10分钟看懂， Java NIO 底层原理 - 疯狂创客圈 - 博客园 (cnblogs.com)](https://www.cnblogs.com/crazymakercircle/p/10225159.html) 

用户程序进行IO的读写，基本上会用到read&write两大系统调用。可能不同操作系统，名称不完全一样，但是功能是一样的。

先强调一个基础知识：read系统调用，并不是把数据直接从物理设备，读数据到内存。write系统调用，也不是直接把数据，写入到物理设备。

**read系统调用**，是**把数据从内核缓冲区复制到进程缓冲区**；而**write系统调用**，是**把数据从进程缓冲区复制到内核缓冲区**。这个两个系统调用，都不负责数据在内核缓冲区和磁盘之间的交换。**底层的读写交换，是由操作系统kernel内核完成的**。

##### 1.1 内核缓冲区与进程缓冲区

**缓冲区的目的，是为了减少频繁的系统IO调用**。大家都知道，系统调用需要保存之前的进程数据和状态等信息，而结束调用之后回来还需要恢复之前的信息，为了减少这种损耗时间、也损耗性能的系统调用，于是出现了缓冲区。

有了缓冲区，操作系统使用read函数把数据从内核缓冲区复制到进程缓冲区，write把数据从进程缓冲区复制到内核缓冲区中。**等待缓冲区达到一定数量的时候，再进行IO的调用，提升性能**。至于什么时候读取和存储则由内核来决定，用户程序不需要关心。

在linux系统中，**系统内核也有个缓冲区叫做内核缓冲区**。**每个进程有自己独立的缓冲区，叫做进程缓冲区**。

所以，用户程序的IO读写程序，大多数情况下，并没有进行实际的IO操作，而是在读写自己的进程缓冲区。

##### 1.2 IO 读写的底层流程 

用户程序进行IO的读写，基本上会用到系统调用read&write，read把数据从内核缓冲区复制到进程缓冲区，write把数据从进程缓冲区复制到内核缓冲区，它们不等价于数据在内核缓冲区和磁盘之间的交换。

![image-20220520172217917](media/images/image-20220520172217917.png)

首先看看一个典型Java 服务端处理网络请求的典型过程：

（1）客户端请求

Linux通过网卡，**读取客户断的请求数据，将数据读取到内核缓冲区**。（write 调用）

（2）获取请求数据

**服务器从内核缓冲区读取数据到Java进程缓冲区**。（read 调用）

（3）服务器端业务处理

Java服务端在自己的用户空间中，处理客户端的请求。

（4）服务器端返回数据

Java服务端已构建好的响应，从用户缓冲区写入内核缓冲区。（write 调用）

（5）发送给客户端

Linux内核通过网络 I/O ，将内核缓冲区中的数据，写入网卡，网卡通过底层的通讯协议，会将数据发送给目标客户端。

##### 阻塞与非阻塞

**阻塞IO**，**指的是需要内核IO操作彻底完成后，才返回到用户空间，执行用户的操作**。**阻塞指的是用户空间程序的执行状态**，**用户空间程序需等到IO操作彻底完成**。传统的IO模型都是同步阻塞IO。在java中，默认创建的socket都是阻塞的。

**非阻塞IO，指的是用户程序不需要等待内核IO操作完成后，内核立即返回给用户一个状态值，用户空间无需等到内核的IO操作彻底完成，可以立即返回用户空间**，执行用户的操作，处于非阻塞的状态。

简单来说：**阻塞是指用户空间（调用线程）一直在等待，而且别的事情什么都不做**；**非阻塞是指用户空间（调用线程）拿到状态就返回**，IO操作可以干就干，不可以干，就去干的事情

##### 同步与异步

同步IO，**是一种用户空间与内核空间的调用发起方式**。同步IO是指用户空间线程是主动发起IO请求的一方，内核空间是被动接受方。异步IO则反过来，是指内核kernel是主动发起IO请求的一方，用户线程是被动接受方。

#### 2 四种主要的 IO 模型 

##### 2.1 同步阻塞 IO （Blocking IO） 

![image-20220520173006263](media/images/image-20220520173006263.png)

举个例子，发起一个blocking socket的read读操作系统调用，流程大概是这样：

（1）当用户线程调用了read系统调用，内核（kernel）就开始了IO的第一个阶段：**准备数据**。很多时候，数据在一开始还没有到达（比如，还没有收到一个完整的Socket数据包），这个时候kernel就要等待足够的数据到来。

（2）当kernel一直等到数据准备好了，它就会将数据从kernel内核缓冲区，拷贝到用户缓冲区（用户内存），然后kernel返回结果。

（3）从开始IO读的read系统调用开始，用户线程就进入阻塞状态。一直到kernel返回结果后，用户线程才解除block的状态，重新运行起来。

所以，blocking IO的特点就是在内核进行IO执行的两个阶段，用户线程都被block了。

BIO的优点：

**程序简单，在阻塞等待数据期间，用户线程挂起。用户线程基本不会占用 CPU 资源**。

BIO的缺点：

一般情况下，会为每个连接配套一条独立的线程，或者说一条线程维护一个连接成功的IO流的读写。在并发量小的情况下，这个没有什么问题。但是，当在高并发的场景下，需要大量的线程来维护大量的网络连接，内存、线程切换开销会非常巨大。因此，基本上，BIO模型在高并发场景下是不可用的。

##### 2.2 同步非阻塞IO（Non-blocking IO）

非阻塞IO要求socket被设置为NONBLOCK

（1）**在内核缓冲区没有数据的情况下，系统调用会立即返回，返回一个调用失败的信息**。

（2）**在内核缓冲区有数据的情况下，是阻塞的**，**直到数据从内核缓冲区复制到用户进程缓冲区**。复制完成后，系统调用返回成功，应用进程开始处理用户空间的缓存数据。

![image-20220520173328132](media/images/image-20220520173328132.png)

例如，发起一个non-blocking socket的read读操作系统调用，流程是这个样子：

（1）在内核数据没有准备好的阶段，用户线程发起IO请求时，立即返回。用户线程需要不断地发起IO系统调用。

（2）内核数据到达后，用户线程发起系统调用，用户线程阻塞。内核开始复制数据。它就会将数据从kernel内核缓冲区，拷贝到用户缓冲区（用户内存），然后kernel返回结果。

（3）用户线程才解除block的状态，重新运行起来。经过多次的尝试，用户线程终于真正读取到数据，继续执行。



**NIO的特点**：

应用程序的线程需要不断的进行 I/O 系统调用，轮询数据是否已经准备好，如果没有准备好，继续轮询，直到完成系统调用为止。

**NIO的优点**：每次发起的 IO 系统调用，在内核的等待数据过程中可以立即返回。用户线程不会阻塞，实时性较好。

**NIO的缺点**：需要不断的重复发起IO系统调用，这种不断的轮询，将会不断地询问内核，这将占用大量的 CPU 时间，系统资源利用率较低。

总之，NIO模型在高并发场景下，也是不可用的。一般 Web 服务器不使用这种 IO 模型。一般很少直接使用这种模型，而是在其他IO模型中使用非阻塞IO这一特性。java的实际开发中，也不会涉及这种IO模型。

再次说明，**Java NIO（New IO） 不是IO模型中的NIO模型**，而是另外的一种模型，**叫做IO多路复用模型（ IO multiplexing ）**。

##### 2.3 IO多路复用（IO Multiplexing）

**即经典的Reactor设计模式**，有时也称为异步阻塞IO，Java中的Selector和Linux中的epoll都是这种模型。

[Reactor模式 - 疯狂创客圈 - 博客园 (cnblogs.com)](https://www.cnblogs.com/crazymakercircle/p/9833847.html) 

**如何避免同步非阻塞NIO模型中轮询等待的问题**呢？这就是IO多路复用模型。

IO多路复用模型，就是**通过一种新的系统调用，一个进程可以监视多个文件描述符，一旦某个描述符就绪（一般是内核缓冲区可读/可写），内核kernel能够通知程序进行相应的IO系统调用**。

目前支持IO多路复用的系统调用，有 select，epoll等等。select系统调用，是目前几乎在所有的操作系统上都有支持，具有良好跨平台特性。

**IO多路复用模型的基本原理就是select/epoll系统调用，单个线程不断的轮询select/epoll系统调用所负责的成百上千的socket连接，当某个或者某些socket网络连接有数据到达了，就返回这些可以读写的连接**。因此，好处也就显而易见了——通过一次select/epoll系统调用，就查询到到可以读写的一个甚至是成百上千的网络连接。

举个例子。发起一个多路复用IO的的read读操作系统调用，流程是这个样子：

![image-20220520173759989](media/images/image-20220520173759989.png)

在这种模式中，首先不是进行read系统调动，而是进行select/epoll系统调用。当然，**这里有一个前提，需要将目标网络连接，提前注册到select/epoll的可查询socket列表中**。然后，才可以开启整个的IO多路复用模型的读流程。

1）进行select/epoll系统调用，查询可以读的连接。kernel会查询所有select的可查询socket列表，当任何一个socket中的数据准备好了，select就会返回。当用户进程调用了select，那么整个线程会被block（阻塞掉）。

（2）用户线程获得了目标连接后，发起read系统调用，用户线程阻塞。内核开始复制数据。它就会将数据从kernel内核缓冲区，拷贝到用户缓冲区（用户内存），然后kernel返回结果。

（3）用户线程才解除block的状态，用户线程终于真正读取到数据，继续执行。



**多路复用IO的特点**：

IO多路复用模型，建立在操作系统kernel内核能够提供的多路分离系统调用select/epoll基础之上的。多路复用IO需要用到两个系统调用（system call）， 一个select/epoll查询调用，一个是IO的读取调用。

和NIO模型相似，多路复用IO需要轮询。负责select/epoll查询调用的线程，需要不断的进行select/epoll轮询，查找出可以进行IO操作的连接。

另外，多路复用IO模型与前面的NIO模型，是有关系的。对于每一个可以查询的socket，一般都设置成为non-blocking模型。只是这一点，对于用户程序是透明的（不感知）。

**多路复用IO的优点**：

用select/epoll的优势在于，它可以同时处理成千上万个连接（connection）。与一条线程维护一个连接相比，I/O多路复用技术的最大优势是：系统不必创建线程，也不必维护这些线程，从而大大减小了系统的开销。

Java的NIO（new IO）技术，使用的就是IO多路复用模型。在linux系统上，使用的是epoll系统调用。

**多路复用IO的缺点**：

本质上，select/epoll系统调用，属于同步IO，也是阻塞IO。都需要在读写事件就绪后，自己负责进行读写，也就是说这个读写过程是阻塞的。

##### 2.4 异步IO（Asynchronous IO） 

异步IO，指的是用户空间与内核空间的调用方式反过来。用户空间线程是变成被动接受的，内核空间是主动调用者。

这一点，有点类似于Java中比较典型的模式是回调模式，用户空间线程向内核空间注册各种IO事件的回调函数，由内核去主动调用。

如何进一步提升效率，解除最后一点阻塞呢？这就是异步IO模型，全称asynchronous I/O，简称为AIO。

AIO的基本流程是：**用户线程通过系统调用，告知kernel内核启动某个IO操作，用户线程返回。kernel内核在整个IO操作（包括数据准备、数据复制）完成后，通知用户程序，用户执行后续的业务操作**。

**kernel的数据准备是将数据从网络物理设备（网卡）读取到内核缓冲区；kernel的数据复制是将数据从内核缓冲区拷贝到用户程序空间的缓冲区**。

![image-20220520174020642](media/images/image-20220520174020642.png)

（1）当用户线程调用了read系统调用，立刻就可以开始去做其它的事，用户线程不阻塞。

（2）内核（kernel）就开始了IO的第一个阶段：准备数据。当kernel一直等到数据准备好了，它就会将数据从kernel内核缓冲区，拷贝到用户缓冲区（用户内存）。

（3）kernel会给用户线程发送一个信号（signal），或者回调用户线程注册的回调接口，告诉用户线程read操作完成了。

（4）用户线程读取用户缓冲区的数据，完成后续的业务操作。



**异步IO模型的特点**：

在内核kernel的等待数据和复制数据的两个阶段，用户线程都不是block(阻塞)的。用户线程需要接受kernel的IO操作完成的事件，或者说注册IO操作完成的回调函数，到操作系统的内核。所以说，异步IO有的时候，也叫做信号驱动 IO 。

**异步IO模型缺点**：

需要完成事件的注册与传递，这里边需要底层操作系统提供大量的支持，去做大量的工作。

目前来说， Windows 系统下通过 IOCP 实现了真正的异步 I/O。但是，就目前的业界形式来说，Windows 系统，很少作为百万级以上或者说高并发应用的服务器操作系统来使用。

而在 Linux 系统下，异步IO模型在2.6版本才引入，目前并不完善。所以，这也是在 Linux 下，实现高并发网络编程时都是以 IO 复用模型模式为主。



