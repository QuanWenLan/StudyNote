### Web

##### JSP静态包含和动态包含的区别？

- 静态包含，<%@include file="xxx.jsp"%>为jsp中的编译指令，其文件的包含是发生在jsp向servlet转换的时期；动态包含，<jsp:include page="xxx.jsp">是jsp中的动作指令，其文件的包含是发生在编译时期，也就是将java文件编译为class文件的时期。
- 使用静态包含只会产生一个class文件，而使用动态包含则会产生多个class文件。
- 使用**静态包含**，包含页面和被包含页面的request对象为同一对象，因为静态包含只是将被包含的页面的内容复制到包含的页面中去；而**动态包含**包含页面和被包含页面**不是同一个页面**，被包含的页面的request对象可以取到的参数范围要相对大些，不仅可以取到传递到包含页面的参数，同样也能取得在包含页面向下传递的参数。

##### JSP的一些内置对象

##### Cookie和Session的区别？

Cookie是会话技术。cookie数据存放在客户的浏览器上，session数据放在服务器上

cookie不是很安全，别人可以分析存放在本地的COOKIE并进行COOKIE欺骗,如果主要考虑到安全应当使用session。

session会在一定时间内保存在服务器上。当访问量增多时，占用服务器的性能，如果考虑到减轻服务器的性能方面应该使用cookie。

单个cookie在客户端的限制是3K，就是说一个站点在客户端存放的COOKIE不能3K。

##### Tomcat容器是如何创建servlet类实例？用到了什么原理？

当容器启动时，会读取在webapps目录下所有web应用中的web.xml文件，然后对web.xml文件进行解析，并读取servlet的注册信息。然后将每个应用的中注册的servlet类都进行实例化，通过反射的方法，有时也在第一次请求的时候实例化。   

 在注册servlet时加上<load-on-startup>1<load-on-startup>，它表示是否再web应用程序启动的时候就加载这个servlet。指定**启动的servlet的加载的先后顺序**，它的值必须是一个整数。如果该元素的值是一个**负数或者没有设置，则容器会当servlet被请求时再加载**。如果值为**正整数或者0**时，表示容器在应用启动时就加载并初始化这个servlet，**值越小，servlet的优先级越高，就越先被加载**。值相同时，容器就会自己选择顺序来加载。

##### [图解Tomcat类加载机制(阿里面试题) - aspirant - 博客园 (cnblogs.com)](https://www.cnblogs.com/aspirant/p/8991830.html) 

##### servlet 生命周期

> https://blog.csdn.net/zhouym_/article/details/90741337 
>
> servlet的生命周期就是从servlet出现到销毁的全过程。主要分为以下几个阶段：
> 加载类—>实例化(为对象分配空间)—>初始化(为对象的属性赋值)—>请求处理(服务阶段)—>销毁
>
> 服务器启动时(web.xml中配置load-on-startup=1，默认为0)或者第一次请求该servlet时，就会初始化一个Servlet对象，也就是会执行初始化方法init(ServletConfig conf),该servlet对象去处理所有客户端请求，service(ServletRequest req,ServletResponse res)方法中执行，最后服务器关闭时，才会销毁这个servlet对象，执行destroy()方法。其中加载阶段无法观察，但是初始化、服务、销毁阶段是可以观察到的。
>
> <img src="media/images/image-20221026094629236.png" alt="image-20221026094629236" style="zoom:67%;" />

- 为什么创建的servlet是继承自httpServlet，而不是直接实现Servlet接口

> HttpServlet继承了GenericServlet，GenericServlet是一个通用的Servlet，那么他的作用是什么呢？大概的就是将实现Servlet接口的方法，简化编写servlet的步骤，GenericServlet 实现了Servlet接口和ServletConfig接口
>
> ```jav
> public interface Servlet {
> 	void init(ServletConfig var1) throws ServletException;
> 	ServletConfig getServletConfig();
> 	void service(ServletRequest var1, ServletResponse var2) throws ServletException, IOException;
> 	String getServletInfo();
> 	void destroy();
> }
> 
> Servlet生命周期的三个关键方法，init、service、destroy。还有另外两个方法，一个getServletConfig()方法来获取ServletConfig对象，ServletConfig对象可以获取到Servlet的一些信息，ServletName、ServletContext、InitParameter、InitParameterNames、通过查看ServletConfig这个接口就可以知道
> ```
>
> 三个生命周期运行的方法，获取ServletConfig，而通过ServletConfig又可以获取到ServletContext。而GenericServlet实现了Servlet接口后，也就说明我们可以直接继承GenericServlet，就可以使用上面我们所介绍Servlet接口中的那几个方法了，能拿到ServletConfig，也可以拿到ServletContext，不过那样太麻烦，不能直接获取ServletContext，所以GenericServlet除了实现Servlet接口外，还实现了ServletConfig接口，那样，就可以直接获取ServletContext了



#### Spring

##### spring mvc的原理

源码解析在文件：readingNotes/Spring源码解析/Spring-MVC 源码

图示：

![image-20230613211432476](media/images/image-20230613211432476.png)



文字版本：

![image-20230613211506806](media/images/image-20230613211506806.png)

##### spring 事务

注解、声明式

##### @Transactional 什么时候失效

https://juejin.cn/post/6844904096747503629

###### Transactional 用于那些地方

- 类
- 方法
- 接口（不推荐使用这种方法，因为一旦标注在Interface上并且配置了Spring AOP 使用CGLib动态代理，将会导致@Transactional注解失效）

###### Propagation 属性

`propagation` 代表事务的传播行为，默认值为 `Propagation.REQUIRED`，其他的属性信息如下：

- `Propagation.REQUIRED`：如果当前存在事务，则加入该事务，如果当前不存在事务，则创建一个新的事务。( 也就是说如果A方法和B方法都添加了注解，在默认传播模式下，A方法内部调用B方法，会把两个方法的事务合并为一个事务 ）。
- `Propagation.SUPPORTS`：如果当前存在事务，则加入该事务；如果当前不存在事务，则以非事务的方式继续运行。
- `Propagation.MANDATORY`：如果当前存在事务，则加入该事务；如果当前不存在事务，则抛出异常。
- `Propagation.REQUIRES_NEW`：重新创建一个新的事务，如果当前存在事务，暂停当前的事务。( 当类A中的 a 方法用默认`Propagation.REQUIRED`模式，类B中的 b方法加上采用 `Propagation.REQUIRES_NEW`模式，然后在 a 方法中调用 b方法操作数据库，然而 a方法抛出异常后，b方法并没有进行回滚，因为`Propagation.REQUIRES_NEW`会暂停 a方法的事务 )
- `Propagation.NOT_SUPPORTED`：以非事务的方式运行，如果当前存在事务，暂停当前的事务。
- `Propagation.NEVER`：以非事务的方式运行，如果当前存在事务，则抛出异常。
- `Propagation.NESTED` ：和 Propagation.REQUIRED 效果一样。

###### isolation 属性

`isolation` ：事务的隔离级别，默认值为 `Isolation.DEFAULT`。

- Isolation.DEFAULT：使用底层数据库默认的隔离级别。
- Isolation.READ_UNCOMMITTED
- Isolation.READ_COMMITTED
- Isolation.REPEATABLE_READ
- Isolation.SERIALIZABLE

###### timeout 属性

`timeout` ：事务的超时时间，默认值为 -1。如果超过该时间限制但事务还没有完成，则自动回滚事务。

###### readOnly 属性

`readOnly` ：指定事务是否为只读事务，默认值为 false；为了忽略那些不需要事务的方法，比如读取数据，可以设置 read-only 为 true。

###### rollbackFor 属性

`rollbackFor` ：用于指定能够触发事务回滚的异常类型，可以指定多个异常类型。

###### noRollbackFor属性

`noRollbackFor`：抛出指定的异常类型，不回滚事务，也可以指定多个异常类型。

###### 失效场景

1. **@Transactional 应用在非 public 修饰的方法上**。

   > ![image-20230613205825197](media/images/image-20230613205825197.png)
   >
   > 之所以会失效是因为在Spring AOP 代理时，如上图所示 `TransactionInterceptor` （事务拦截器）在目标方法执行前后进行拦截，`DynamicAdvisedInterceptor`（CglibAopProxy 的内部类）的 intercept 方法或 `JdkDynamicAopProxy` 的 invoke 方法会间接调用 `AbstractFallbackTransactionAttributeSource`的 `computeTransactionAttribute` 方法，获取Transactional 注解的事务配置信息。
   >
   > ```java
   > protected TransactionAttribute computeTransactionAttribute(Method method,
   >     Class<?> targetClass) {
   >         // Don't allow no-public methods as required.
   >         if (allowPublicMethodsOnly() && !Modifier.isPublic(method.getModifiers())) {
   >         return null;
   > }
   > 
   > ```
   >
   > 此方法会检查目标方法的修饰符是否为 public，不是 public则不会获取@Transactional 的属性配置信息。
   >
   > **注意：`protected`、`private` 修饰的方法上使用 `@Transactional` 注解，虽然事务无效，但不会有任何报错，这是我们很容犯错的一点**。

2. **@Transactional 注解属性 propagation 设置错误**

   > `TransactionDefinition.PROPAGATION_SUPPORTS`：如果当前存在事务，则加入该事务；如果当前没有事务，则以非事务的方式继续运行。 `TransactionDefinition.PROPAGATION_NOT_SUPPORTED`：以非事务方式运行，如果当前存在事务，则把当前事务挂起。 `TransactionDefinition.PROPAGATION_NEVER`：以非事务方式运行，如果当前存在事务，则抛出异常。

3. **@Transactional 注解属性 rollbackFor 设置错误**

   > `rollbackFor` 可以指定能够触发事务回滚的异常类型。Spring默认抛出了未检查`unchecked`异常（继承自 `RuntimeException` 的异常）或者 `Error`才回滚事务；其他异常不会触发回滚事务。如果在事务中抛出其他类型的异常，但却期望 Spring 能够回滚事务，就需要指定 **rollbackFor**属性。
   >
   > <img src="media/images/image-20230613211013686.png" alt="image-20230613211013686" style="zoom:67%;" />
   >
   > ```java
   > // 希望自定义的异常可以进行回滚
   > @Transactional(propagation= Propagation.REQUIRED,rollbackFor= MyException.class
   > ```
   >
   > 若在目标方法中抛出的异常是 `rollbackFor` 指定的异常的子类，事务同样会回滚。Spring源码如下：
   >
   > ```java
   > private int getDepth(Class<?> exceptionClass, int depth) {
   >         if (exceptionClass.getName().contains(this.exceptionName)) {
   >             // Found it!
   >             return depth;
   > }
   >         // If we've gone as far as we can go and haven't found it...
   >         if (exceptionClass == Throwable.class) {
   >             return -1;
   > }
   > return getDepth(exceptionClass.getSuperclass(), depth + 1);
   > }
   > 
   > ```
   >
   > 

4. **同一个类中方法调用，导致@Transactional失效**

   > 开发中避免不了会对同一个类里面的方法调用，比如有一个类Test，它的一个方法A，A再调用本类的方法B（不论方法B是用public还是private修饰），但方法A没有声明注解事务，而B方法有。则外部调用方法A之后，方法B的事务是不会起作用的。这也是经常犯错误的一个地方。
   >
   > 那为啥会出现这种情况？其实这还是由于使用`Spring AOP`代理造成的，因为只有当事务方法被当前类以外的代码调用时，才会由`Spring`生成的代理对象来管理。

5. **异常被你的 catch“吃了”导致@Transactional失效**

   > ```java
   > @Transactional
   > private Integer A() throws Exception {
   >     int insert = 0;
   >     try {
   >         CityInfoDict cityInfoDict = new CityInfoDict();
   >         cityInfoDict.setCityName("2");
   >         cityInfoDict.setParentCityId(2);
   >         /**
   >              * A 插入字段为 2的数据
   >              */
   >         insert = cityInfoDictMapper.insert(cityInfoDict);
   >         /**
   >              * B 插入字段为 3的数据
   >              */
   >         b.insertB();
   >     } catch (Exception e) {
   >         e.printStackTrace();
   >     }
   > }
   > ```
   >
   > 如果B方法内部抛了异常，而A方法此时try catch了B方法的异常，那这个事务还能正常回滚吗？
   >
   > 答案：不能！
   >
   > 会抛出异常：org.springframework.transaction.UnexpectedRollbackException: Transaction rolled back because it has been marked as rollback-only
   >
   > 因为当`ServiceB`中抛出了一个异常以后，`ServiceB`标识当前事务需要`rollback`。但是`ServiceA`中由于你手动的捕获这个异常并进行处理，`ServiceA`认为当前事务应该正常`commit`。此时就出现了前后不一致，也就是因为这样，抛出了前面的`UnexpectedRollbackException`异常。
   >
   > `spring`的事务是在调用业务方法之前开始的，业务方法执行完毕之后才执行`commit` or `rollback`，事务是否执行取决于是否抛出`runtime异常`。如果抛出`runtime exception` 并在你的业务方法中没有catch到的话，事务会回滚。
   >
   > 在业务方法中一般不需要catch异常，如果非要catch一定要抛出`throw new RuntimeException()`，或者注解中指定抛异常类型`@Transactional(rollbackFor=Exception.class)`，否则会导致事务失效，数据commit造成数据不一致，所以有些时候try catch反倒会画蛇添足。

6. **数据库引擎不支持事务**

   > 常用的MySQL数据库默认使用支持事务的`innodb`引擎。一旦数据库引擎切换成不支持事务的`myisam`，那事务就从根本上失效了。

##### spring 中使用到的模式

###### 工厂模式

- BeanFactory
- FactoryBean

###### 建造者模式

```java
// 加载 xml 文件，建造者模式+工厂模式使用。 org.springframework.beans.factory.xml.DefaultDocumentLoader#loadDocument 
public Document loadDocument(InputSource inputSource, EntityResolver entityResolver,
                             ErrorHandler errorHandler, int validationMode, boolean namespaceAware) throws Exception {

    DocumentBuilderFactory factory = createDocumentBuilderFactory(validationMode, namespaceAware);
    if (logger.isTraceEnabled()) {
        logger.trace("Using JAXP provider [" + factory.getClass().getName() + "]");
    }
    DocumentBuilder builder = createDocumentBuilder(factory, entityResolver, errorHandler);
    return builder.parse(inputSource);
}
```

###### 模板方法模式

- JdbcTemplate

```java
//org.springframework.beans.factory.xml.DefaultBeanDefinitionDocumentReader#doRegisterBeanDefinitions, 这里的 root  是 <beans xxxx></beans>
protected void doRegisterBeanDefinitions(Element root) {
		// Any nested <beans> elements will cause recursion in this method. In
		// order to propagate and preserve <beans> default-* attributes correctly,
		// keep track of the current (parent) delegate, which may be null. Create
		// the new (child) delegate with a reference to the parent for fallback purposes,
		// then ultimately reset this.delegate back to its original (parent) reference.
		// this behavior emulates a stack of delegates without actually necessitating one.
		BeanDefinitionParserDelegate parent = this.delegate;
		this.delegate = createDelegate(getReaderContext(), root, parent);

		if (this.delegate.isDefaultNamespace(root)) {
			String profileSpec = root.getAttribute(PROFILE_ATTRIBUTE);
			if (StringUtils.hasText(profileSpec)) {
				String[] specifiedProfiles = StringUtils.tokenizeToStringArray(
						profileSpec, BeanDefinitionParserDelegate.MULTI_VALUE_ATTRIBUTE_DELIMITERS);
				// We cannot use Profiles.of(...) since profile expressions are not supported
				// in XML config. See SPR-12458 for details.
				if (!getReaderContext().getEnvironment().acceptsProfiles(specifiedProfiles)) {
					if (logger.isDebugEnabled()) {
						logger.debug("Skipped XML bean definition file due to specified profiles [" + profileSpec +
								"] not matching: " + getReaderContext().getResource());
					}
					return;
				}
			}
		}
// 模板方法模式，提供给子类进行实现，默认是没有实现的，protected 方法
		preProcessXml(root);
		parseBeanDefinitions(root, this.delegate);
		postProcessXml(root);

		this.delegate = parent;
	}
```

###### 观察者模式

- spring 的事件监听机制使用的是这个模式

###### 访问者模式

- PropertyAccess 接口，属性访问器，用来访问和设置某个对象的某个属性

###### 适配器模式

- AdvisorAdapter 接口，适配了 Advisor

###### 装饰器模式

- BeanWrapper

###### 代理模式

- AOP

###### 策略模式

- InstantiationStrategy 

  有两个实现类，SimpleInstantiationStrategy 和 CglibSubclassingInstantiationStrategy

###### 委派模式

- BeanDefinitionParserDelegate

###### 责任链模式

- BeanPostPocessor

#### SpringBoot

##### SpringBoot 是如何实现自动装配的

spring boot的核心注解：`@SpringBootApplication`

```java
@Target(ElementType.TYPE)
@Retention(RetentionPolicy.RUNTIME)
@Documented
@Inherited
@SpringBootConfiguration
@EnableAutoConfiguration
@ComponentScan(excludeFilters = { @Filter(type = FilterType.CUSTOM, classes = TypeExcludeFilter.class),
      @Filter(type = FilterType.CUSTOM, classes = AutoConfigurationExcludeFilter.class) })
public @interface SpringBootApplication {
}

@Target(ElementType.TYPE)
@Retention(RetentionPolicy.RUNTIME)
@Documented
@Configuration
public @interface SpringBootConfiguration {
}
```

###### 核心注解

`@EnableAutoConfiguration`：启用 SpringBoot 的自动配置机制

`@Configuration`：允许在上下文中注册额外的 bean 或导入其他配置类

`@ComponentScan`： 扫描被`@Component` (`@Service`,`@Controller`)注解的 bean，注解默认会扫描启动类所在的包下所有的类 ，可以自定义不扫描某些 bean。如下图所示，容器中将排除`TypeExcludeFilter`和`AutoConfigurationExcludeFilter`。

**@EnableAutoConfiguration:实现自动装配的核心注解**

```java
@Target({ElementType.TYPE})
@Retention(RetentionPolicy.RUNTIME)
@Documented
@Inherited
@AutoConfigurationPackage //作用：将main包下的所有组件注册到容器中
@Import({AutoConfigurationImportSelector.class}) //加载自动装配类 xxxAutoconfiguration
public @interface EnableAutoConfiguration {
    String ENABLED_OVERRIDE_PROPERTY = "spring.boot.enableautoconfiguration";

    Class<?>[] exclude() default {};

    String[] excludeName() default {};
}
```

**AutoConfigurationImportSelector**

```java
public class AutoConfigurationImportSelector implements DeferredImportSelector, BeanClassLoaderAware, ResourceLoaderAware, BeanFactoryAware, EnvironmentAware, Ordered {

}
public interface DeferredImportSelector extends ImportSelector {

}
public interface ImportSelector {
    String[] selectImports(AnnotationMetadata importingClassMetadata);
}
```

AutoConfigurationImportSelector 实现了这个方法：该方法主要用于**获取所有符合条件的类的全限定类名，这些类需要被加载到 IoC 容器中**。

```java
private static final String[] NO_IMPORTS = new String[0];

public String[] selectImports(AnnotationMetadata annotationMetadata) {
    // <1>.判断自动装配开关是否打开
    if (!this.isEnabled(annotationMetadata)) {
        return NO_IMPORTS;
    } else {
        //<2>.获取所有需要装配的bean
        AutoConfigurationMetadata autoConfigurationMetadata = AutoConfigurationMetadataLoader.loadMetadata(this.beanClassLoader);
        AutoConfigurationImportSelector.AutoConfigurationEntry autoConfigurationEntry = this.getAutoConfigurationEntry(autoConfigurationMetadata, annotationMetadata);
        return StringUtils.toStringArray(autoConfigurationEntry.getConfigurations());
    }
}
```

将断点打到这个方法，发现不会进入。

org.springframework.context.annotation.ConfigurationClassParser.processImports 在这个方法里面有执行 selector.selectImports 的调用。

```java
private void processImports(ConfigurationClass configClass, SourceClass currentSourceClass,
			Collection<SourceClass> importCandidates, boolean checkForCircularImports) {
    ...
    if (candidate.isAssignable(ImportSelector.class)) {
        // Candidate class is an ImportSelector -> delegate to it to determine imports
        Class<?> candidateClass = candidate.loadClass();
        ImportSelector selector = BeanUtils.instantiateClass(candidateClass, ImportSelector.class);
        ParserStrategyUtils.invokeAwareMethods(
                selector, this.environment, this.resourceLoader, this.registry);
        if (selector instanceof DeferredImportSelector) { // 如果实现了接口DeferredImportSelector 则添加到名为deferredImportSelectors的list中暂存
            this.deferredImportSelectorHandler.handle(
                    configClass, (DeferredImportSelector) selector);
        }
        else { // 否则执行selectImports方法
            String[] importClassNames = selector.selectImports(currentSourceClass.getMetadata());
            Collection<SourceClass> importSourceClasses = asSourceClasses(importClassNames);
            processImports(configClass, currentSourceClass, importSourceClasses, false);
        }
    }
    ...
}
```

调用栈如图：

![image-20230306162448630](media/images/image-20230306162448630.png)

```java
public void parse(Set<BeanDefinitionHolder> configCandidates) {
    for (BeanDefinitionHolder holder : configCandidates) {
        BeanDefinition bd = holder.getBeanDefinition();
        try {
            if (bd instanceof AnnotatedBeanDefinition) {
                // 先解析扫描bean, 在此方法中向deferredImportSelectorHandler中添加了一个对象, 存储了可延迟导入的selector列表
                parse(((AnnotatedBeanDefinition) bd).getMetadata(), holder.getBeanName());
            }
            else if (bd instanceof AbstractBeanDefinition && ((AbstractBeanDefinition) bd).hasBeanClass()) {
                parse(((AbstractBeanDefinition) bd).getBeanClass(), holder.getBeanName());
            }
            else {
                parse(bd.getBeanClassName(), holder.getBeanName());
            }
        }
        catch (BeanDefinitionStoreException ex) {
            throw ex;
        }
        catch (Throwable ex) {
            throw new BeanDefinitionStoreException(
                    "Failed to parse configuration class [" + bd.getBeanClassName() + "]", ex);
        }
    }
    // 执行对象的process方法
    this.deferredImportSelectorHandler.process();
}
```

org.springframework.context.annotation.ConfigurationClassParser.DeferredImportSelectorHandler#process 

```java
public void process() {
   List<DeferredImportSelectorHolder> deferredImports = this.deferredImportSelectors;
   this.deferredImportSelectors = null;
   try {
      if (deferredImports != null) {
         DeferredImportSelectorGroupingHandler handler = new DeferredImportSelectorGroupingHandler();
         deferredImports.sort(DEFERRED_IMPORT_COMPARATOR);
         // 这里需要注册
         deferredImports.forEach(handler::register);
         handler.processGroupImports();
      }
   }
   finally {
      this.deferredImportSelectors = new ArrayList<>();
   }
}
```

org.springframework.context.annotation.ConfigurationClassParser.DeferredImportSelectorGroupingHandler.register

```java
public void register(DeferredImportSelectorHolder deferredImport) {
    // 调用org.springframework.boot.autoconfigure.AutoConfigurationImportSelector.getImportGroup 返回AutoConfigurationGroup.class
    Class<? extends Group> group = deferredImport.getImportSelector().getImportGroup();
    // 创建Group对象, 用DeferredImportSelectorGrouping包装并存入到map中
    DeferredImportSelectorGrouping grouping = this.groupings.computeIfAbsent(
            (group != null ? group : deferredImport),
            key -> new DeferredImportSelectorGrouping(createGroup(group)));
    // 向deferredImports对象添加元素, 后面会使用
    grouping.add(deferredImport);
    // 存入map中 key为启动类的元数据 value是启动类
    this.configurationClasses.put(deferredImport.getConfigurationClass().getMetadata(),
            deferredImport.getConfigurationClass());
}
```

org.springframework.context.annotation.ConfigurationClassParser.DeferredImportSelectorGroupingHandler.processGroupImports

```java
public void processGroupImports() {
    for (DeferredImportSelectorGrouping grouping : this.groupings.values()) { // 只有一个元素, 上个方法放入的
        grouping.getImports().forEach(entry -> { // 重点解析
            // 获取主配置类 启动类
            ConfigurationClass configurationClass = this.configurationClasses.get(entry.getMetadata());
            try {
                // 逐个执行导入 至此执行完成后, 扫描出的类都会注册到BeanDefinition中 等待Spring容器对对象实例化和初始化
                processImports(configurationClass, asSourceClass(configurationClass),
                        asSourceClasses(entry.getImportClassName()), false);
            }
            catch (BeanDefinitionStoreException ex) {
                throw ex;
            }
            catch (Throwable ex) {
                throw new BeanDefinitionStoreException(
                        "Failed to process import candidates for configuration class [" +
                                configurationClass.getMetadata().getClassName() + "]", ex);
            }
        });
    }
}
```

org.springframework.context.annotation.ConfigurationClassParser.DeferredImportSelectorGrouping.getImports

```java
public Iterable<Group.Entry> getImports() {
    // 前面放入的一个元素 此处循环
    for (DeferredImportSelectorHolder deferredImport : this.deferredImports) {
        // group为AutoConfigurationGroup对象 执行org.springframework.boot.autoconfigure.AutoConfigurationImportSelector.AutoConfigurationGroup.process方法
        this.group.process(deferredImport.getConfigurationClass().getMetadata(),
                deferredImport.getImportSelector());
    }
    // 对map结果去重、排序并返回
    return this.group.selectImports();
}
```

org.springframework.boot.autoconfigure.AutoConfigurationImportSelector.AutoConfigurationGroup.process

```java
public void process(AnnotationMetadata annotationMetadata,
        DeferredImportSelector deferredImportSelector) {
    // 断言
    Assert.state(
            deferredImportSelector instanceof AutoConfigurationImportSelector,
            () -> String.format("Only %s implementations are supported, got %s",
                    AutoConfigurationImportSelector.class.getSimpleName(),
                    deferredImportSelector.getClass().getName()));
    // 调用getAutoConfigurationEntry检索spring.factories文件, 存储并排除文件中配置的bean
    AutoConfigurationEntry autoConfigurationEntry = ((AutoConfigurationImportSelector) deferredImportSelector)
            .getAutoConfigurationEntry(getAutoConfigurationMetadata(),  // 获取了所有包中的spring.factories文件配置参数
                annotationMetadata);

    this.autoConfigurationEntries.add(autoConfigurationEntry);
    for (String importClassName : autoConfigurationEntry.getConfigurations()) {
        // 将过滤后的类存入到entries map中
        this.entries.putIfAbsent(importClassName, annotationMetadata);
    }
}
```

调用`getAutoConfigurationEntry()`方法，这个方法主要负责加载自动配置类的。调用栈如上图

```java
protected AutoConfigurationEntry getAutoConfigurationEntry(
        AutoConfigurationMetadata autoConfigurationMetadata,
        AnnotationMetadata annotationMetadata) {
    if (!isEnabled(annotationMetadata)) {
        return EMPTY_ENTRY;
    }
    //(2) 获取EnableAutoConfiguration注解的属性,获取EnableAutoConfiguration注解中的 exclude 和 excludeName
    AnnotationAttributes attributes = getAttributes(annotationMetadata);
    //(3) 扫描各个包下META-INF/spring.factories文件中配置EnableAutoConfiguration 大约100+ 
    List<String> configurations = getCandidateConfigurations(annotationMetadata, attributes);
    //(4) Link转Array
    configurations = removeDuplicates(configurations);
    // 获取注解上排除的类  @SpringBootApplication(exclude= {DataSourceAutoConfiguration.class})
    Set<String> exclusions = getExclusions(annotationMetadata, attributes);
    checkExcludedClasses(configurations, exclusions);
    // 去掉排除的类
    configurations.removeAll(exclusions);
    // 使用filter过滤 过滤不存在的类(尝试加载 异常说明不存在)
    configurations = filter(configurations, autoConfigurationMetadata);
    // 发送一个AutoConfigurationImportEvent事件通知
    fireAutoConfigurationImportEvents(configurations, exclusions);
    return new AutoConfigurationEntry(configurations, exclusions);
}
```

流程

```java
protected List<String> getCandidateConfigurations(AnnotationMetadata metadata, AnnotationAttributes attributes) {
   List<String> configurations = SpringFactoriesLoader.loadFactoryNames(getSpringFactoriesLoaderFactoryClass(),
         getBeanClassLoader());
   Assert.notEmpty(configurations, "No auto configuration classes found in META-INF/spring.factories. If you "
         + "are using a custom packaging, make sure that file is correct.");
   return configurations;
}

public static List<String> loadFactoryNames(Class<?> factoryType, @Nullable ClassLoader classLoader) {
    String factoryTypeName = factoryType.getName();
    return loadSpringFactories(classLoader).getOrDefault(factoryTypeName, Collections.emptyList());
}
```

```java
/**
	 * 加载Factories文件
	 *
	 * @param classLoader factories文件解析之后的map
	 * @return
	 */
private static Map<String, List<String>> loadSpringFactories(ClassLoader classLoader) {
    // 现在缓存中查找，classLoader为key
    Map<String, List<String>> result = cache.get(classLoader);
    if (result != null) {
        return result;
    }

    result = new HashMap<>();
    try {
        // 获取资源，这里固定目录为：META-INF/spring.factories
        Enumeration<URL> urls = classLoader.getResources(FACTORIES_RESOURCE_LOCATION);
        while (urls.hasMoreElements()) {
            URL url = urls.nextElement();
            UrlResource resource = new UrlResource(url);
            // 将资源加载为Properties
            Properties properties = PropertiesLoaderUtils.loadProperties(resource);
            // 遍历配置
            for (Map.Entry<?, ?> entry : properties.entrySet()) {
                String factoryTypeName = ((String) entry.getKey()).trim();
                // 获取value的数组，一般为类的全限定名
                // 比如 org.springframework.beans.BeanInfoFactory=org.springframework.beans.ExtendedBeanInfoFactory
                String[] factoryImplementationNames =
                    StringUtils.commaDelimitedListToStringArray((String) entry.getValue());
                // 添加到result
                for (String factoryImplementationName : factoryImplementationNames) {
                    result.computeIfAbsent(factoryTypeName, key -> new ArrayList<>())
                        .add(factoryImplementationName.trim());
                }
            }
        }

        // 对value进行去重
        result.replaceAll((factoryType, implementations) -> implementations.stream().distinct()
                          .collect(Collectors.collectingAndThen(Collectors.toList(), Collections::unmodifiableList)));
        // 添加到缓存中
        cache.put(classLoader, result);
    } catch (IOException ex) {
        throw new IllegalArgumentException("Unable to load factories from location [" +
                                           FACTORIES_RESOURCE_LOCATION + "]", ex);
    }
    return result;
}
```

获取需要自动装配的所有配置类，读取`META-INF/spring.factories`

> spring-boot/spring-boot-project/spring-boot-autoconfigure/src/main/resources/META-INF/spring.factories

![image-20230306164248398](media/images/image-20230306164248398.png)

不光是这个依赖下的`META-INF/spring.factories`被读取到，所有 Spring Boot Starter 下的`META-INF/spring.factories`都会被读取到。

所以，你可以清楚滴看到， druid 数据库连接池的 Spring Boot Starter 就创建了`META-INF/spring.factories`文件。

如果，我们自己要创建一个 Spring Boot Starter，这一步是必不可少的。

最后使用filter过滤掉了不符合条件的类。

```java
@Configuration
// 检查相关的类：RabbitTemplate 和 Channel是否存在
// 存在才会加载
@ConditionalOnClass({ RabbitTemplate.class, Channel.class })
@EnableConfigurationProperties(RabbitProperties.class)
@Import(RabbitAnnotationDrivenConfiguration.class)
public class RabbitAutoConfiguration {
}
```

![image-20230306170025780](media/images/image-20230306170025780.png)

##### spring boot如何启动 Tomcat 的

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-web</artifactId>
</dependency>
```

添加如上 Web 的依赖，Spring Boot 就帮我们内置了 Servlet 容器，默认使用的是 Tomcat，同样也支持修改，比如可以使用 jetty、Undertow 等。

因为内置了启动容器，应用程序可以直接通过 Maven 命令将项目编译成可执行的 jar 包，通过 java -jar 命令直接启动，不需要再像以前一样，打包成 War 包，然后部署在 Tomcat 中。

原理：https://blog.csdn.net/niceyoo/article/details/109954382

首先，spring boot在启动时会先创建一个 spring 容器。

调用run方法之后，会运行到 ConfigurableApplicationContext  这个类的 run 方法里面，启动tomcat相关的代码在`context = createApplicationContext();`和 `refreshContext(context)` 方法里。

```java
public ConfigurableApplicationContext run(String... args) {
   StopWatch stopWatch = new StopWatch();
   stopWatch.start();
   ConfigurableApplicationContext context = null;
   Collection<SpringBootExceptionReporter> exceptionReporters = new ArrayList<>();
   configureHeadlessProperty();
   SpringApplicationRunListeners listeners = getRunListeners(args);
   listeners.starting();
   try {
      ApplicationArguments applicationArguments = new DefaultApplicationArguments(args);
      ConfigurableEnvironment environment = prepareEnvironment(listeners, applicationArguments);
      configureIgnoreBeanInfo(environment);
      Banner printedBanner = printBanner(environment);
      context = createApplicationContext();
      exceptionReporters = getSpringFactoriesInstances(SpringBootExceptionReporter.class,
            new Class[] { ConfigurableApplicationContext.class }, context);
      prepareContext(context, environment, listeners, applicationArguments, printedBanner);
       // 这个方法里面去创建了tomcat
      refreshContext(context);
      afterRefresh(context, applicationArguments);
      stopWatch.stop();
      if (this.logStartupInfo) {
         new StartupInfoLogger(this.mainApplicationClass).logStarted(getApplicationLog(), stopWatch);
      }
      listeners.started(context);
      callRunners(context, applicationArguments);
   }
   catch (Throwable ex) {
      handleRunFailure(context, ex, exceptionReporters, listeners);
      throw new IllegalStateException(ex);
   }

   try {
      listeners.running(context);
   }
   catch (Throwable ex) {
      handleRunFailure(context, ex, exceptionReporters, null);
      throw new IllegalStateException(ex);
   }
   return context;
}
```

上面方法进入之后，refreshContext() 方法传递的 context，经由 refresh() 方法强转成父类 AbstractApplicationContext，具体调用过程如下。

```java
public void refresh() throws BeansException, IllegalStateException {
   synchronized (this.startupShutdownMonitor) {
      try {
		...
         // Initialize other special beans in specific context subclasses. 主要是这个方法
         onRefresh();
         // Check for listener beans and register them.
         registerListeners();
         // Instantiate all remaining (non-lazy-init) singletons.
         finishBeanFactoryInitialization(beanFactory);
         // Last step: publish corresponding event.
         finishRefresh();
      }
       ...
   }
}
```

在这个方法中我们主要关心 onRefresh() 方法，onRefresh() 方法是调用其子类实现的，也就是 ServletWebServerApplicationContext，

```java
protected void onRefresh() {
   super.onRefresh();
   try {
      createWebServer();
   }
   catch (Throwable ex) {
      throw new ApplicationContextException("Unable to start web server", ex);
   }
}
private void createWebServer() {
    WebServer webServer = this.webServer;
    ServletContext servletContext = getServletContext();
    if (webServer == null && servletContext == null) {
        // 获取 servlet 工厂
        ServletWebServerFactory factory = getWebServerFactory();
        this.webServer = factory.getWebServer(getSelfInitializer());
        getBeanFactory().registerSingleton("webServerGracefulShutdown",
                                           new WebServerGracefulShutdownLifecycle(this.webServer));
        getBeanFactory().registerSingleton("webServerStartStop",
                                           new WebServerStartStopLifecycle(this, this.webServer));
    }
    else if (servletContext != null) {
        try {
            getSelfInitializer().onStartup(servletContext);
        }
        catch (ServletException ex) {
            throw new ApplicationContextException("Cannot initialize servlet context", ex);
        }
    }
    initPropertySources();
}
```

![image-20230613221647451](media/images/image-20230613221647451.png)

来看一下 TomcatServletWebServerFactory 的 getWebServer() 方法：

```java
public WebServer getWebServer(ServletContextInitializer... initializers) {
    if (this.disableMBeanRegistry) {
        Registry.disableRegistry();
    }
		/** 1、创建Tomcat实例 **/
    Tomcat tomcat = new Tomcat();
    File baseDir = this.baseDirectory != null ? this.baseDirectory : this.createTempDir("tomcat");
    tomcat.setBaseDir(baseDir.getAbsolutePath());
    Connector connector = new Connector(this.protocol);
    connector.setThrowOnFailure(true);
    tomcat.getService().addConnector(connector);
    this.customizeConnector(connector);
    /** 2、给创建好的tomcat设置连接器connector **/
    tomcat.setConnector(connector);
    /** 设置不自动部署 **/
    tomcat.getHost().setAutoDeploy(false);
    /** 3、配置Tomcat容器引擎 **/
    this.configureEngine(tomcat.getEngine());
    Iterator var5 = this.additionalTomcatConnectors.iterator();

    while(var5.hasNext()) {
        Connector additionalConnector = (Connector)var5.next();
        tomcat.getService().addConnector(additionalConnector);
    }
		/**
 		 * 准备Tomcat的StandardContext，并添加到Tomcat中，同时把initializers 注册到类型为
 		 * TomcatStarter的ServletContainerInitializer中
 		 **/
    this.prepareContext(tomcat.getHost(), initializers);
    /** 将创建好的Tomcat包装成WebServer返回**/
    return this.getTomcatWebServer(tomcat);
}

public Engine getEngine() {
    Service service = this.getServer().findServices()[0];
    if (service.getContainer() != null) {
        return service.getContainer();
    } else {
        Engine engine = new StandardEngine();
        engine.setName("Tomcat");
        engine.setDefaultHost(this.hostname);
        engine.setRealm(this.createDefaultRealm());
        service.setContainer(engine);
        return engine;
    }
}
```

getWebServer() 这个方法创建了 Tomcat 对象，并且做了两件重要的事情：

把连接器 Connector 对象添加到 Tomcat 中;
配置容器引擎，configureEngine(tomcat.getEngine());
首先说一下这个 Connector 连接器，Tomcat 有两个核心功能：

处理 Socket 连接，负责网络字节流与 Request 和 Response 对象的转化。
加载和管理 Servlet，以及具体处理 Request 请求。
针对这两个功能，Tomcat 设计了两个核心组件来分别完成这两件事，即：连接器(Connector)和容器(Container)。

整个过程大致就是：Connector 连接器接收连接请求，创建Request和Response对象用于和请求端交换数据，然后分配线程让Engine（也就是Servlet容器）来处理这个请求，并把产生的Request和Response对象传给Engine。当Engine处理完请求后，也会通过Connector将响应返回给客户端。

这里面提到了 Engine，这个是 Tomcat 容器里的顶级容器(Container)，我们可以通过 Container 类查看其他的子容器：Engine、Host、Context、Wrapper。

4者的关系是：Engine 是最高级别的容器，Engine 子容器是 Host，Host 的子容器是 Context，Context 子容器是 Wrapper，所以这4个容器的关系就是父子关系，即：Wrapper > Context > Host > Engine （>表示继承）

```java
private void configureEngine(Engine engine) {
   engine.setBackgroundProcessorDelay(this.backgroundProcessorDelay);
   for (Valve valve : this.engineValves) {
      engine.getPipeline().addValve(valve);
   }
}
```

其中 engine.setBackgroundProcessorDelay(this.backgroundProcessorDelay) 是指定背景线程的执行间隔，例如背景线程会在每隔多长时间后判断session是否失效之类。

再回到 getWebServer() 方法，最终 getWebServer() 方法返回了 TomcatWebServer。

`return getTomcatWebServer(tomcat);`

```java
protected TomcatWebServer getTomcatWebServer(Tomcat tomcat) {
   return new TomcatWebServer(tomcat, getPort() >= 0, getShutdown());
}
public TomcatWebServer(Tomcat tomcat, boolean autoStart, Shutdown shutdown) {
    Assert.notNull(tomcat, "Tomcat Server must not be null");
    this.tomcat = tomcat;
    this.autoStart = autoStart;
    this.gracefulShutdown = (shutdown == Shutdown.GRACEFUL) ? new GracefulShutdown(tomcat) : null;
    initialize();
}
private void initialize() throws WebServerException {
    // 启动spring boot经常看到这句话
    logger.info("Tomcat initialized with port(s): " + getPortsDescription(false));
    synchronized (this.monitor) {
        try {
            addInstanceIdToEngineName();
            Context context = findContext();
            context.addLifecycleListener((event) -> {
                if (context.equals(event.getSource()) && Lifecycle.START_EVENT.equals(event.getType())) {
                    // Remove service connectors so that protocol binding doesn't
                    // happen when the service is started.
                    removeServiceConnectors();
                }
            });

            // Start the server to trigger initialization listeners
            this.tomcat.start();
            // We can re-throw failure exception directly in the main thread
            rethrowDeferredStartupExceptions();
            try {
                ContextBindings.bindClassLoader(context, context.getNamingToken(), getClass().getClassLoader());
            }
            catch (NamingException ex) {
                // Naming is not enabled. Continue
            }
            // Unlike Jetty, all Tomcat threads are daemon threads. We create a
            // blocking non-daemon to stop immediate shutdown
            startDaemonAwaitThread();
        }
        catch (Exception ex) {
            stopSilently();
            destroySilently();
            throw new WebServerException("Unable to start embedded Tomcat", ex);
        }
    }
}
```

##### 配置文件加载顺序

###### 内部配置文件加载顺序

优先级1：项目路径下的config文件夹配置文件
优先级2：项目的根目录下面配置文件
优先级3：资源路径下的config文件夹配置文件
优先级4：资源路径下配置文件

![image-20230613224519147](media/images/image-20230613224519147.png)

***加载顺序为上文的排列顺序，高优先级配置的属性会生效***。

###### 外部配置文件加载顺序

https://docs.spring.io/spring-boot/docs/current/reference/html/features.html#features.external-config

***我们只需要记住 命令行参数 是最高的优先级加载顺序。***

##### spring boot 做单元测试

[如何在 Spring Boot 应用中做单元测试？（文末福利） (qq.com)](https://mp.weixin.qq.com/s/NK0wlFbfbnCg12j38vpIaQ)