### ApplicationContext

源码中的解释：

```java 
/**
 * Central interface to provide configuration for an application.
 * This is read-only while the application is running, but may be
 * reloaded if the implementation supports this.
 *
 * <p>An ApplicationContext provides:
 * <ul>
 * <li>Bean factory methods for accessing application components.
 * Inherited from {@link org.springframework.beans.factory.ListableBeanFactory}.
 * <li>The ability to load file resources in a generic fashion.
 * Inherited from the {@link org.springframework.core.io.ResourceLoader} interface.
 * <li>The ability to publish events to registered listeners.
 * Inherited from the {@link ApplicationEventPublisher} interface.
 * <li>The ability to resolve messages, supporting internationalization.
 * Inherited from the {@link MessageSource} interface.
 * <li>Inheritance from a parent context. Definitions in a descendant context
 * will always take priority. This means, for example, that a single parent
 * context can be used by an entire web application, while each servlet has
 * its own child context that is independent of that of any other servlet.
 * </ul>
 *
 * <p>In addition to standard {@link org.springframework.beans.factory.BeanFactory}
 * lifecycle capabilities, ApplicationContext implementations detect and invoke
 * {@link ApplicationContextAware} beans as well as {@link ResourceLoaderAware},
 * {@link ApplicationEventPublisherAware} and {@link MessageSourceAware} beans.
 */

```

翻译：为应用程序提供配置的中央接口。这在应用程序运行时是只读的，但如果实现支持，则可以重新加载。
ApplicationContext 提供:

1. 用于访问应用程序组件的 Bean 工厂方法。继承自ListableBeanFactory 。
2. 以通用方式加载文件资源的能力。继承自org.springframework.core.io.ResourceLoader接口。
3. 向注册的侦听器发布事件的能力。继承自ApplicationEventPublisher接口。
4. 解决消息的能力，支持国际化。继承自MessageSource接口。
5. 从父上下文继承。后代上下文中的定义将始终具有优先权。这意味着，例如，整个 Web 应用程序可以使用单个父上下文，而每个 servlet 都有自己的子上下文，该子上下文独立于任何其他 servlet。

除了标准的org.springframework.beans.factory.BeanFactory生命周期功能之外，ApplicationContext 实现检测和调用ApplicationContextAware bean 以及ResourceLoaderAware 、 ApplicationEventPublisherAware和MessageSourceAware bean。

```java 
public interface ApplicationContext extends EnvironmentCapable, ListableBeanFactory, HierarchicalBeanFactory,
		MessageSource, ApplicationEventPublisher, ResourcePatternResolver
        {...}
```

ApplicationContext和BeanFactory一样都是bean的容器，而BeanFactory是一切Bean容器的父类，ApplicationContext继承于BeanFactory（继承之BeanFactory的子类）.

ApplicationContext包含了BeanFactory的所有功能，并且扩展了其他功能，也就是我们可以用 ClassPathXmlApplicationContext("a.xml") 进行 bean 的初始化和加载。

参考：[spring源码解析-ApplicationContext解析 - Lucky帅小武 - 博客园 (cnblogs.com)](https://www.cnblogs.com/jackion5/p/10991825.html) 

> 高频面试题：ApplicationContext和BeanFactory的区别？
>
> 1.BeanFactory是容器所有容器接口的父类，提供了最基本的bean相关的功能，而ApplicationContext是继承之BeanFactory，在BeanFactory的基础上扩展了更多的功能
>
> 2.ApplicationContext的初始化过程就包含了BeanFactory的初始化过程，如何额外扩展，
>
> 3.BeanFactory中的bean是在获取的时候才初始化，而ApplicationContext是初始化的时候就初始化所有的单例bean（好处是在启动的时候就可以检查到不合法的bean）
>
> 4.ApplicationContext增加了SPEL语言的支持（#{xx.xx}等配置）、 消息发送、响应机制（ApplicationEventPublisher）、支持了@Qualiiar和@Autowired等注解



### 事件监听 

ApplicationContext 提供了如上面的一些额外支持，事件监听，消息发送，这里用到的是 **观察者模式**。

博文链接：[spring源码解析--事件监听机制的使用和原理解析 - Lucky帅小武 - 博客园 (cnblogs.com)](https://www.cnblogs.com/jackion5/p/13272683.html) 

#### 1 事件监听机制的定义

使用过MQ的或者了解观察者设计模式的同学应该大致都了解，实现事件监听机制至少四个核心：**事件、事件生产者和事件消费者，另外还需要有一个管理生产者、消费者和事件之间的注册监听关系的控制器**。

在Spring中，事件监听机制主要实现是通过**事件、事件监听器、事件发布者和事件广播器**来实现。

##### 1.1 Spring 中的事件（ApplicationEvent ）

spring中的事件有一个抽象父类ApplicationEvent，该类包含有当前ApplicationContext的引用，这样就可以确认每个事件是从哪一个Spring容器中发生的。

##### 1.2 Spring 中的事件监听器（ApplicationListener）

spring中的事件监听器同样有一个顶级接口ApplicationListener,只有一个onApplicationEvent(E event)方法，当该监听器所监听的事件发生时，就会执行该方法

##### 1.3、Spring中的事件发布者（ApplicationEventPublisher）

spring中的事件发布者同样有一个顶级接口ApplicationEventPublisher，只有一个方法publishEvent(Object event)方法，调用该方法就可以发生spring中的事件

##### 1.4、Spring中的事件广播器（ApplicationEventMulticaster）

spring中的事件核心控制器叫做事件广播器,接口为ApplicationEventMulticaster，广播器的作用主要有两个：

作用一：将事件监听器注册到广播器中，这样广播器就知道了每个事件监听器分别监听什么事件，且知道了每个事件对应哪些事件监听器在监听

作用二：将事件广播给事件监听器，当有事件发生时，需要通过广播器来广播给所有的事件监听器，因为生产者只需要关心事件的生产，而不需要关心该事件都被哪些监听器消费

#### 2 使用 

以电商为例，假设现在有这样一个场景：当用户下单成功之后，此时需要做很多操作，比如需要保存一个订单记录、对应的商品库存需要扣除，假设下单的时候还用到了红包，那么对应的红包也需要改成已经使用。所以相当于一个下单操作，需要进行三个数据更新操作。而这三个操作实际上又是互相没有任何关联的，所以可以通过三个下单事件的监听器分别来处理对应的业务逻辑，此时就可以采用Spring的事件监听机制来模拟实现这样的场景。

1、首先定义一个下单事件 OrderEvent,下单事件中包含了订单号、商品编号和使用的红包编号，代码如下：

```java 
/**
 * @Auther: Lucky
 * @Date: 2020/7/8 下午2:53
 * @Desc: 自定义下单事件
 */
public class OrderEvent extends ApplicationEvent {

    /** 订单编号*/
    private String orderCode;
    /** 商品编号*/
    private String goodsCode;
    /** 红包编号*/
    private String redPacketCode;

    /** 事件的构造函数*/
    public OrderEvent(ApplicationContext source, String orderCode, String goodsCode, String redPacketCode) {
        super(source);
        this.orderCode = orderCode;
        this.goodsCode = goodsCode;
        this.redPacketCode = redPacketCode;
    }
}
```

2、分别定义订单监听器、商品监听器和红包监听器分别监听下单事件，分别做对应的处理，代码如下：

```java
public class GoodsListener implements ApplicationListener<OrderEvent> {
    @Override
    public void onApplicationEvent(OrderEvent event) {
        System.out.println("订单监听器监听到下单事件,更新商品库存:" + event.getOrderCode());
        // todo 更新商品库存
    }
}

public class OrderListener implements ApplicationListener<OrderEvent> {
    @Override
    public void onApplicationEvent(OrderEvent event) {
        System.out.println("订单监听器监听到下单事件,订单号为:" + event.getOrderCode());
        // todo 处理订单
    }
}

public class RedPacketListener implements ApplicationListener<OrderEvent> {
    @Override
    public void onApplicationEvent(OrderEvent event) {
        if(event.getRedPacketCode()!=null) {
            System.out.println("红包监听器监听到下单事件,红包编号为:" + event.getRedPacketCode());
            //TODO 使用红包处理
        }else {
            System.out.println("订单:"+event.getOrderCode()+"没有使用红包");
        }
    }
}
```

3、事件发布器和事件广播器无需自定义，采用Spring默认的就可以

4、注册监听器到 spring 中

```xml
<beans>

   <!-- 其他bean -->

    <bean id="orderListener" class="com.lucky.test.spring.event.OrderListener"/>
    <bean id="goodsListener" class="com.lucky.test.spring.event.GoodsListener"/>
    <bean id="redPacketListener" class="com.lucky.test.spring.event.RedPacketListener"/>
</beans>
```



```java 
@Test
public void testListener() {
        ApplicationContext context = new ClassPathXmlApplicationContext("classpath:listener.xml");
        TestEvent event = new TestEvent("hello", "msg");
        context.publishEvent(event);
        for (int i = 0; i < 5; i++) {
            String orderCode = "test_order_" + i;
            String goodsCode = "test_order_" + i;
            String redPacketCode = null;
            if (i % 2 == 0) {
                //偶数时使用红包
                redPacketCode = "test_order_" + i;
            }
            OrderEvent orderEvent = new OrderEvent(context, orderCode, goodsCode, redPacketCode);
            /** 3. ApplicationContext实现了ApplicationEventPublisher接口,所以可以直接通过ApplicationContext来发送事件*/
            context.publishEvent(orderEvent);
        }
    }
```

输出：

```te
订单监听器监听到下单事件,订单号为:test_order_0
订单监听器监听到下单事件,更新商品库存:test_order_0
红包监听器监听到下单事件,红包编号为:test_order_0
订单监听器监听到下单事件,订单号为:test_order_1
订单监听器监听到下单事件,更新商品库存:test_order_1
订单:test_order_1没有使用红包
订单监听器监听到下单事件,订单号为:test_order_2
订单监听器监听到下单事件,更新商品库存:test_order_2
红包监听器监听到下单事件,红包编号为:test_order_2
订单监听器监听到下单事件,订单号为:test_order_3
订单监听器监听到下单事件,更新商品库存:test_order_3
订单:test_order_3没有使用红包
订单监听器监听到下单事件,订单号为:test_order_4
订单监听器监听到下单事件,更新商品库存:test_order_4
红包监听器监听到下单事件,红包编号为:test_order_4
```

**Tip：Spring的事件监听机制是同步处理的，也就是说生产者发布事件和消费者消费事件是在同一个线程下执行的，所以本案例中的下单事件虽然按三个事件监听器分别监听下单事件，但是总的方法耗时并没有减少，并且如果任何一个监听器抛了异常，同样会影响到其他的监听器，所以每个事件监听器监听消息时必须要对事件进行异常捕获操作，或者内部改成异步处理。** 

可以将处理事件的操作改成 异步 操作，创建新的线程去执行，这样就不会一个监听器抛出了异常后，其他的的也受到影响了。

```java 
public class OrderListener implements ApplicationListener<OrderEvent>  {

    @Override
    public void onApplicationEvent(OrderEvent event) {
        /** 通过try/catch保证事件监听器不会抛异常*/
        try {
            new Thread(new Runnable() {
                @Override
                public void run() {
                    System.out.println("订单监听器监听到下单事件,订单号为:" + event.getOrderCode() + "线程为:" + Thread.currentThread().getName());
                    //TODO 保存订单处理
                }
            }).start();
        }catch (Exception e){
            e.printStackTrace();
        }
    }
}
```

6、对于同一个事件如果有多个事件监听器时，既然是同步的，那么就必然会有执行顺序的区别，Spring默认的事件执行的执行顺序是按照bean加载的顺序执行的，比如本例中，在XML中配置的顺序是OrderListener->GoodsListener->RedPacketListener,

那么最后执行的顺序就是这个顺序，但是很显然这种隐式的排序方式很容易让开发人员忽视，所以Spring提供了额外的排序方式，就是让监听器实现**Ordered接口或者Ordered的子接口PriorityOrdered接口**。

Ordered接口只有一个方法: org.springframework.core.Ordered

```java 
public interface Ordered {
/**
	 * Useful constant for the highest precedence value.
	 * @see java.lang.Integer#MIN_VALUE 最高优先级
	 */
	int HIGHEST_PRECEDENCE = Integer.MIN_VALUE;

	/**
	 * Useful constant for the lowest precedence value.
	 * @see java.lang.Integer#MAX_VALUE 最低优先级
	 */
	int LOWEST_PRECEDENCE = Integer.MAX_VALUE;

    /**
	 * Get the order value of this object.
	 * <p>Higher values are interpreted as lower priority. As a consequence,
	 * the object with the lowest value has the highest priority (somewhat
	 * analogous to Servlet {@code load-on-startup} values).
	 * <p>Same order values will result in arbitrary sort positions for the
	 * affected objects.
	 * @return the order value
	 * @see #HIGHEST_PRECEDENCE
	 * @see #LOWEST_PRECEDENCE
	 */
	int getOrder();
}
```

所以上面我们可以实现 Ordered 接口，定义 getOrder() 方法：

```java 
public class GoodsListener implements ApplicationListener<OrderEvent>, Ordered {
    @Override
    public int getOrder() {
        /** 使用最高优先级*/
        return Ordered.HIGHEST_PRECEDENCE;
    }
}
public class RedPacketListener implements ApplicationListener<OrderEvent>, PriorityOrdered {

    @Override
    public int getOrder() {
        /**使用最低优先级*/
        return Ordered.LOWEST_PRECEDENCE;
    }
}
```

这里GoodsListener实现了Ordered接口,优先级为最高优先级；RedPacketListener实现了PriorityOrdered,设置优先级为最低优先级,执行结果如下:

```tex
1 红包监听器监听到下单事件,更新红包:test_order_0
2 商品监听器监听到下单事件,更新商品库存:test_order_0
3 订单监听器监听到下单事件,订单号为:test_order_0
```

可以发现实现了PriorityOrdered接口的RedPacketListener最先执行，实现了Ordered接口的GoodsListener第二个执行，没有实现排序接口的OrderListener接口最后执行。

#### 3 原理 

当ApplicationContext初始化的时候， 有两个核心步骤和事件监听器有关，一个是初始化事件广播器，一个是注册所有的事件监听器。

```java
// Initialize event multicaster for this context.
initApplicationEventMulticaster();
// Check for listener beans and register them.
registerListeners();
```

剩下的可参考： [6.6.4 初始化 ApplicationEventMulticaster  事件广播器](./Spring源码解析2.md)

