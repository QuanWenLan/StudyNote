博客：[SpringMVC实现原理解析 - Lucky帅小武 - 博客园 (cnblogs.com)](https://www.cnblogs.com/jackion5/p/15611758.html) 

### 二、SpringMVC核心组件

DispatcherServlet：中央控制器，统一调度其他组件的调用，是整个请求响应的控制中心，本质是一个Servlet；

HandlerMapping：处理器映射器，客户端请求URL和业务处理器的映射关系，根据请求URL可以找到对应的业务处理器；

Handler：业务处理器，处理客户端的具体请求和返回处理结果，通常存在形式就是各种Controller；

HandlerAdapter：处理器适配器，负责调用业务处理器的具体方法，返回逻辑视图ModelAndView对象；

ViewResolver：视图解析器，负责将业务处理器返回的视图ModelAndView对象解析成JSP；

### 三、SpringMVC工作流程

![image-20230613211432476](file://D:/projects/StudyNote/docs/%E9%9D%A2%E8%AF%95/media/images/image-20230613211432476.png?lastModify=1691659081)

1、客户端发送请求，所有请求都由中央处理器DispatcherServlet处理；

2、DispatcherServlet通过处理器映射器HandlerMapping根据客户端请求URL获取对应的业务处理器Handler对象；

3、DispatcherServlet调用HandlerAdapter处理器适配器，通知HandlerAdapter执行具体哪个Handler；

4、HandlerAdapter调用具体Handler(Controller)的方法并得到返回的结果ModelAndView，且将结果返回给DispatcherServlet；

5、DispatcherServlet将ModelAndView交给ViewReslover视图解析器解析，然后返回真正的视图；

6、DispatcherServlet将模型数据填充到视图中；

7、DispatcherServlet将结果响应给用户。

### 四、SpringMVC流程图

![mvc流程](media/images/mvc流程.png)

### 五、源码解析 

#### 1启动流程 

##### web.XML

需要先在 web.XML 中配置 DispatcherServlet。

```xml
<?xml version="1.0" encoding="UTF-8"?>
<web-app xmlns="http://xmlns.jcp.org/xml/ns/javaee"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://xmlns.jcp.org/xml/ns/javaee http://xmlns.jcp.org/xml/ns/javaee/web-app_4_0.xsd"
         version="4.0" metadata-complete="false">
<!--metadata-complete:
    这个值表为true，则表示对三大组件的注册方式就只有web.xml中的注册起作用，将会忽略注解的注册；
    为false表示可以两个同时使用
-->
  <display-name>Archetype Created Web Application</display-name>
  <welcome-file-list>
    <welcome-file>index.jsp</welcome-file>
  </welcome-file-list>
<!--  MVC 配置-->
  <listener>
    <listener-class>org.springframework.web.context.ContextLoaderListener</listener-class>
  </listener>

  <context-param>
    <param-name>contextConfigLocation</param-name>
    <param-value>classpath:springmvc.xml</param-value>
  </context-param>

  <servlet>
    <servlet-name>dispatcherServlet</servlet-name>
    <servlet-class>org.springframework.web.servlet.DispatcherServlet</servlet-class>
    <init-param>
      <param-name>contextConfigLocation</param-name>
      <param-value>classpath:springmvc.xml</param-value>
    </init-param>
    <load-on-startup>1</load-on-startup>
  </servlet>

  <servlet-mapping>
    <servlet-name>dispatcherServlet</servlet-name>
    <url-pattern>/</url-pattern>
  </servlet-mapping>
</web-app>
```

##### spring mvc的配置

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:context="http://www.springframework.org/schema/context"
       xmlns:mvc="http://www.springframework.org/schema/mvc"
       xmlns:p="http://www.springframework.org/schema/p"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xsi:schemaLocation="http://www.springframework.org/schema/beans
       http://www.springframework.org/schema/beans/spring-beans-4.0.xsd
       http://www.springframework.org/schema/context http://www.springframework.org/schema/context/spring-context-4.0.xsd
       http://www.springframework.org/schema/mvc http://www.springframework.org/schema/mvc/spring-mvc-4.0.xsd">

    <!-- <mvc:annotation-driven /> 会自动注册DefaultAnnotationHandlerMapping 与 AnnotationMethodHandlerAdapter 两个bean,是spring MVC为@Controllers分发请求所必须的。它提供了数据绑定支持，读取json的支持 -->
    <mvc:annotation-driven />

    <!-- 设置自动注入bean的扫描范围，use-default-filters默认为true，会扫描所有的java类进行注入 ，-->
    <!-- Use-dafault-filters=”false”的情况下：<context:exclude-filter>指定的不扫描，<context:include-filter>指定的扫描 -->
    <!-- springmvc和application文件都需要配置，但mvc文件只扫描controller类，application扫描不是controller类 -->
    <!--<context:component-scan base-package="lan.mvc" use-default-filters="false">
        <context:include-filter expression="org.springframework.stereotype.Controller" type="annotation"/>
    </context:component-scan>-->
    <context:component-scan base-package="lan.mvc" />

    <!-- 文件上传功能需该配置 当有文件时调用org.springframework.web.servlet.DispatcherServlet.checkMultipart() 方法
    参考：https://blog.csdn.net/weixin_34411563/article/details/92375209
    -->
    <bean class="org.springframework.web.multipart.commons.CommonsMultipartResolver" id="multipartResolver">
        <property name="defaultEncoding" value="UTF-8"/>
        <property name="maxUploadSize" value="10485760"/>
    </bean>

    <!-- ResourceBundleThemeSource是ThemeSource接口默认实现类-->
    <bean class="org.springframework.ui.context.support.ResourceBundleThemeSource" id="themeSource"/>

    <!-- 用于实现用户所选的主题，以Cookie的方式存放在客户端的机器上-->
    <bean class="org.springframework.web.servlet.theme.CookieThemeResolver" id="themeResolver" p:cookieName="theme" p:defaultThemeName="standard"/>

    <!-- 由于web.xml文件中进行了请求拦截
        <servlet-mapping>
            <servlet-name>dispatcher</servlet-name>
            <url-pattern>/</url-pattern>
        </servlet-mapping>
    这样会影响到静态资源文件的获取，mvc:resources的作用是帮你分类完成获取静态资源的责任
    -->
<!--    <mvc:resources mapping="/resources/**" location="/WEB-INF/resources/" />-->

    <!-- 配置使用 SimpleMappingExceptionResolver 来映射异常 -->
    <bean class="org.springframework.web.servlet.handler.SimpleMappingExceptionResolver" >
        <!-- 定义默认的异常处理页面 -->
        <property name="defaultErrorView" value="error"/>
        <!-- 配置异常的属性值为ex，那么在错误页面中可以通过 ${exception} 来获取异常的信息如果不配置这个属性，它的默认值为exception-->
        <property name="exceptionAttribute" value="exception"/>
        <property name="exceptionMappings">
            <props>
                <!-- 映射特殊异常对应error.jsp这个页面 -->
                <prop key=".DataAccessException">error</prop>
                <prop key=".NoSuchRequestHandlingMethodException">error</prop>
                <prop key=".TypeMismatchException">error</prop>
                <prop key=".MissingServletRequestParameterException">error</prop>
            </props>
        </property>
    </bean>

    <!-- 配置jsp视图解析器 -->
    <bean class="org.springframework.web.servlet.view.InternalResourceViewResolver" id="jspViewResolver">
        <property name="viewClass" value="org.springframework.web.servlet.view.JstlView"/>
        <property name="prefix" value="/WEB-INF/"/>
        <property name="suffix" value=".jsp"/>
    </bean>
</beans>
```

项目启动时会创建DispatcherServlet并会执行DispatcherServlet的初始化init方法，查看DispatcherServlet的类图可以发现，DispatcherServlet继承FrameworkServlet，最先开始调用的是 HttpServlet 的init 方法。这个方法是空方法，留给子类覆盖了。而 HttpServletBean 覆盖了这个方法，所以会调用到这个类的 init 方法里面去。至于为什么会调用 HttpServlet 的init方法，还要分析查找下。(应该和tomcat启动有关，这里是servlet的生命周期有关，先调用init方法)

![image-20220413115518595](media/images/image-20220413115518595.png)

```java
// org.springframework.web.servlet.HttpServletBean#init
public final void init() throws ServletException {

   // Set bean properties from init parameters.
   PropertyValues pvs = new ServletConfigPropertyValues(getServletConfig(), this.requiredProperties);
   if (!pvs.isEmpty()) {
      try {
         BeanWrapper bw = PropertyAccessorFactory.forBeanPropertyAccess(this);
         ResourceLoader resourceLoader = new ServletContextResourceLoader(getServletContext());
         bw.registerCustomEditor(Resource.class, new ResourceEditor(resourceLoader, getEnvironment()));
         initBeanWrapper(bw);
         bw.setPropertyValues(pvs, true);
      }
      catch (BeansException ex) {
         if (logger.isErrorEnabled()) {
            logger.error("Failed to set bean properties on servlet '" + getServletName() + "'", ex);
         }
         throw ex;
      }
   }

   // Let subclasses do whatever initialization they like.
   initServletBean();
}
```

initServletBean(); 则调用到了 `org.springframework.web.servlet.FrameworkServlet#initServletBean`里去。

```java
protected final void initServletBean() throws ServletException {
   getServletContext().log("Initializing Spring " + getClass().getSimpleName() + " '" + getServletName() + "'");
   if (logger.isInfoEnabled()) {
      logger.info("Initializing Servlet '" + getServletName() + "'");
   }
   long startTime = System.currentTimeMillis();

   try {
       // 初始化操作
      this.webApplicationContext = initWebApplicationContext();
      initFrameworkServlet();
   }
   ....
}
```

调用路径：

![image-20220413152929524](media/images/image-20220413152929524.png)

继续深入调用分析：`initWebApplicationContext()`，IOC 容器 WebApplicationContext

```java
protected WebApplicationContext initWebApplicationContext() {
    /** 1. 尝试获取WebApplicationContext */
   WebApplicationContext rootContext =
         WebApplicationContextUtils.getWebApplicationContext(getServletContext());
   WebApplicationContext wac = null;

   if (this.webApplicationContext != null) {
      // A context instance was injected at construction time -> use it
      wac = this.webApplicationContext;
      if (wac instanceof ConfigurableWebApplicationContext) {
         ConfigurableWebApplicationContext cwac = (ConfigurableWebApplicationContext) wac;
         if (!cwac.isActive()) {
            // The context has not yet been refreshed -> provide services such as
            // setting the parent context, setting the application context id, etc
            if (cwac.getParent() == null) {
               // The context instance was injected without an explicit parent -> set
               // the root application context (if any; may be null) as the parent
               cwac.setParent(rootContext);
            }
            configureAndRefreshWebApplicationContext(cwac);
         }
      }
   }
   if (wac == null) {
      // No context instance was injected at construction time -> see if one
      // has been registered in the servlet context. If one exists, it is assumed
      // that the parent context (if any) has already been set and that the
      // user has performed any initialization such as setting the context id
      wac = findWebApplicationContext();
   }
    /** 2.如果当前没有WebApplicationContext就初始化并刷新WebApplicationContext */
   if (wac == null) {
      // No context instance is defined for this servlet -> create a local one
      wac = createWebApplicationContext(rootContext);
   }

   if (!this.refreshEventReceived) {
      // Either the context is not a ConfigurableApplicationContext with refresh
      // support or the context injected at construction time had already been
      // refreshed -> trigger initial onRefresh manually here.
      synchronized (this.onRefreshMonitor) {
          /** 3.WebApplicationContext初始化并刷新后,执行onRefresh方法*/
         onRefresh(wac);
      }
   }

   if (this.publishContext) {
      // Publish the context as a servlet context attribute.
      String attrName = getServletContextAttributeName();
      getServletContext().setAttribute(attrName, wac);
   }

   return wac;
}
```

通过createWebApplicationContext方法创建IOC容器WebApplicationContext并启动刷新容器，当Spring容器启动后再执行onRefresh方法刷新Servlet，Spring容器启动刷新逻辑不再细看，onRefresh方法实际是交给了子类DispatcherServlet实现，DispatcherServlet的onRefresh方法源码如下：

```java
// org.springframework.web.servlet.FrameworkServlet#onRefresh
protected void onRefresh(ApplicationContext context) {
   // For subclasses: do nothing by default.
}
```

是由子类实现的；org.springframework.web.servlet.DispatcherServlet#onRefresh

```java
protected void onRefresh(ApplicationContext context) {
   initStrategies(context);
}

/**
 * Initialize the strategy objects that this servlet uses.
 * <p>May be overridden in subclasses in order to initialize further strategy objects.
 */
protected void initStrategies(ApplicationContext context) {
   initMultipartResolver(context);
   initLocaleResolver(context);
   initThemeResolver(context);
    /** 初始化处理器映射器HandlerMapping */
    initHandlerMappings(context);
    /** 初始化处理器适配器handlerAdapter */
    initHandlerAdapters(context);
    initHandlerExceptionResolvers(context);
    initRequestToViewNameTranslator(context);
    /** 初始化视图解析器ViewResolver */
    initViewResolvers(context);
   initFlashMapManager(context);
}
```

初始化处理器映射器后：

![image-20230613232348351](media/images/image-20230613232348351.png)

初始化处理器适配器之后有三个对应的 handlerAdapter，其中一个支持的话就直接返回。

![image-20220414122334465](media/images/image-20220414122334465.png)

#### 2 请求访问流程源码解析

首先浏览器发送请求，DispatcherServlet 作为统一处理前端请求的 servlet，实际上也是 servlet，继承了 HttpServlet，当识别到 get、post、put 请求的时候会执行 doGet()、doPost()等方法。

doGet() 方法继续调用到子类 FrameworkServlet 中（因为我们当前是DispatcherServlet）的 doGet() 方法，进而继续调用到 FrameworkServlet  的processRequest() 方法中，实际上这个方法的核心是 doDispatch(request, response) 分发请求，源码如下：

调用链：

![image-20220414121056440](media/images/image-20220414121056440.png)

调用 doDispatch(request, response) 后

```java
protected void doService(HttpServletRequest request, HttpServletResponse response) throws Exception {
   logRequest(request);
/** 1.请求参数快照,将请求参数缓存起来 */
   // Keep a snapshot of the request attributes in case of an include,
   // to be able to restore the original attributes after the include.
   Map<String, Object> attributesSnapshot = null;
   if (WebUtils.isIncludeRequest(request)) {
      attributesSnapshot = new HashMap<>();
      Enumeration<?> attrNames = request.getAttributeNames();
      while (attrNames.hasMoreElements()) {
         String attrName = (String) attrNames.nextElement();
         if (this.cleanupAfterInclude || attrName.startsWith(DEFAULT_STRATEGIES_PREFIX)) {
            attributesSnapshot.put(attrName, request.getAttribute(attrName));
         }
      }
   }

    /** 2.请求参数添加配置 */
   // Make framework objects available to handlers and view objects.
   request.setAttribute(WEB_APPLICATION_CONTEXT_ATTRIBUTE, getWebApplicationContext());
   request.setAttribute(LOCALE_RESOLVER_ATTRIBUTE, this.localeResolver);
   request.setAttribute(THEME_RESOLVER_ATTRIBUTE, this.themeResolver);
   request.setAttribute(THEME_SOURCE_ATTRIBUTE, getThemeSource());

   if (this.flashMapManager != null) {
      FlashMap inputFlashMap = this.flashMapManager.retrieveAndUpdate(request, response);
      if (inputFlashMap != null) {
         request.setAttribute(INPUT_FLASH_MAP_ATTRIBUTE, Collections.unmodifiableMap(inputFlashMap));
      }
      request.setAttribute(OUTPUT_FLASH_MAP_ATTRIBUTE, new FlashMap());
      request.setAttribute(FLASH_MAP_MANAGER_ATTRIBUTE, this.flashMapManager);
   }

   try {
       /** 重点逻辑 */
      doDispatch(request, response);
   }
   ...
}
```

继续查看核心逻辑 

```java
protected void doDispatch(HttpServletRequest request, HttpServletResponse response) throws Exception {
   HttpServletRequest processedRequest = request;
   HandlerExecutionChain mappedHandler = null;
   boolean multipartRequestParsed = false;

   WebAsyncManager asyncManager = WebAsyncUtils.getAsyncManager(request);

   try {
      ModelAndView mv = null;
      Exception dispatchException = null;

      try {
         processedRequest = checkMultipart(request);
         multipartRequestParsed = (processedRequest != request);

         // Determine handler for the current request. HandlerExecutionChain 是这个对象
          /** 1.根据请求从HandlerMapping中查询具体的业务处理器 也就是获取对应的 controller 对应的 handler*/
         mappedHandler = getHandler(processedRequest);
         if (mappedHandler == null) {
            noHandlerFound(processedRequest, response);
            return;
         }
/** 2.根据业务处理器查询对应业务处理器适配器，根据handler获取匹配的handlerAdapter */
         // Determine handler adapter for the current request.
         HandlerAdapter ha = getHandlerAdapter(mappedHandler.getHandler());

         // Process last-modified header, if supported by the handler.
         String method = request.getMethod();
         boolean isGet = "GET".equals(method);
         if (isGet || "HEAD".equals(method)) {
            long lastModified = ha.getLastModified(request, mappedHandler.getHandler());
            if (new ServletWebRequest(request, response).checkNotModified(lastModified) && isGet) {
               return;
            }
         }

         if (!mappedHandler.applyPreHandle(processedRequest, response)) {
            return;
         }
  /** 3.调用处理器适配器的handle方法处理具体的业务逻辑，返回ModelAndView对象 */
         // Actually invoke the handler. mv == ModelAndView
         mv = ha.handle(processedRequest, response, mappedHandler.getHandler());

         if (asyncManager.isConcurrentHandlingStarted()) {
            return;
         }
// 通过视图的prefix和postfix获取完整的视图名
         applyDefaultViewName(processedRequest, mv);
         // 应用后置的拦截器
         mappedHandler.applyPostHandle(processedRequest, response, mv);
      }
      catch (Exception ex) {
         dispatchException = ex;
      }
      catch (Throwable err) {
         // As of 4.3, we're processing Errors thrown from handler methods as well,
         // making them available for @ExceptionHandler methods and other scenarios.
         dispatchException = new NestedServletException("Handler dispatch failed", err);
      }
        /** 4.处理请求执行结果，显然就是对ModelAndView 或者 出现的Excpetion处理 */
      processDispatchResult(processedRequest, response, mappedHandler, mv, dispatchException);
   }
   // ....
}
```

初始化处理器适配器之后有三个对应的 handlerAdapter，其中一个支持的话就直接返回。

![image-20220414122334465](media/images/image-20220414122334465.png)

`ModelAndView mv = ha.handle(processedRequest, response, mappedHandler.getHandler());`

这里处理完了之后返回的是视图 ModelAndView 了。

##### 获取HandlerExecutionChain 

具体 HandlerExecutionChain mappedHandler = getHandler(processedRequest);

![image-20240131152836873](media/images/image-20240131152836873.png)

查看请求我们在页面上发起了一个get请求，然后走到了这里，去获取对应的执行链，我们继续往下看。

```java
protected HandlerExecutionChain getHandler(HttpServletRequest request) throws Exception {
   if (this.handlerMappings != null) {
      for (HandlerMapping mapping : this.handlerMappings) {
         HandlerExecutionChain handler = mapping.getHandler(request);
         if (handler != null) {
            return handler;
         }
      }
   }
   return null;
}
```

这里是直接通过 HandlerMapping 来获取的，通过第一个mapping去获取出来的结果就已经能够判断到是哪个controller了。

![image-20240131153048809](media/images/image-20240131153048809.png)

![image-20240131153252520](media/images/image-20240131153252520.png)

但是这里的handler是一个 HandlerMethod 对象，随后在方法 HandlerExecutionChain executionChain = getHandlerExecutionChain(handler, request); 中组装成一个chain

```java
protected HandlerExecutionChain getHandlerExecutionChain(Object handler, HttpServletRequest request) {
   HandlerExecutionChain chain = (handler instanceof HandlerExecutionChain ?
         (HandlerExecutionChain) handler : new HandlerExecutionChain(handler));

   String lookupPath = this.urlPathHelper.getLookupPathForRequest(request, LOOKUP_PATH);
   for (HandlerInterceptor interceptor : this.adaptedInterceptors) {
      if (interceptor instanceof MappedInterceptor) {
         MappedInterceptor mappedInterceptor = (MappedInterceptor) interceptor;
         if (mappedInterceptor.matches(lookupPath, this.pathMatcher)) {
            chain.addInterceptor(mappedInterceptor.getInterceptor());
         }
      }
      else {
         chain.addInterceptor(interceptor);
      }
   }
   return chain;
}
```

![image-20240131153540969](media/images/image-20240131153540969.png)

##### 获取 getHandlerAdapter

```java
HandlerAdapter ha = getHandlerAdapter(mappedHandler.getHandler());
```

具体的则是通过判断哪个adapter能够支持，就返回哪一个，第一个判断就成功了，那么这里也就是类 RequestMappingHandlerAdapter 了。

![image-20220414122334465](media/images/image-20220414122334465.png)

##### 执行具体逻辑

```java
mv = ha.handle(processedRequest, response, mappedHandler.getHandler());
```

现在是走到具体的RequestMappingHandlerAdapter 的handle方法里面去执行逻辑了，交给handleInternal方法处理，以RequestMappingHandlerAdapter这个HandlerAdapter中的处理方法为例。

![image-20240131154223392](media/images/image-20240131154223392.png)

然后执行invokeHandlerMethod这个方法，用来对RequestMapping（TestController中的users方法）进行处理。

```java
protected ModelAndView invokeHandlerMethod(HttpServletRequest request,
      HttpServletResponse response, HandlerMethod handlerMethod) throws Exception {

   ServletWebRequest webRequest = new ServletWebRequest(request, response);
   try {
      WebDataBinderFactory binderFactory = getDataBinderFactory(handlerMethod);
      ModelFactory modelFactory = getModelFactory(handlerMethod, binderFactory);
	// 重要：设置handler(controller#list)方法上的参数，返回值处理，绑定databinder等！！！
      ServletInvocableHandlerMethod invocableMethod = createInvocableHandlerMethod(handlerMethod);
      if (this.argumentResolvers != null) {
         invocableMethod.setHandlerMethodArgumentResolvers(this.argumentResolvers);
      }
      if (this.returnValueHandlers != null) {
         invocableMethod.setHandlerMethodReturnValueHandlers(this.returnValueHandlers);
      }
      invocableMethod.setDataBinderFactory(binderFactory);
      invocableMethod.setParameterNameDiscoverer(this.parameterNameDiscoverer);

      ModelAndViewContainer mavContainer = new ModelAndViewContainer();
      mavContainer.addAllAttributes(RequestContextUtils.getInputFlashMap(request));
      modelFactory.initModel(webRequest, mavContainer, invocableMethod);
      mavContainer.setIgnoreDefaultModelOnRedirect(this.ignoreDefaultModelOnRedirect);

      AsyncWebRequest asyncWebRequest = WebAsyncUtils.createAsyncWebRequest(request, response);
      asyncWebRequest.setTimeout(this.asyncRequestTimeout);

      WebAsyncManager asyncManager = WebAsyncUtils.getAsyncManager(request);
      asyncManager.setTaskExecutor(this.taskExecutor);
      asyncManager.setAsyncWebRequest(asyncWebRequest);
      asyncManager.registerCallableInterceptors(this.callableInterceptors);
      asyncManager.registerDeferredResultInterceptors(this.deferredResultInterceptors);

      if (asyncManager.hasConcurrentResult()) {
         Object result = asyncManager.getConcurrentResult();
         mavContainer = (ModelAndViewContainer) asyncManager.getConcurrentResultContext()[0];
         asyncManager.clearConcurrentResult();
         LogFormatUtils.traceDebug(logger, traceOn -> {
            String formatted = LogFormatUtils.formatValue(result, !traceOn);
            return "Resume with async result [" + formatted + "]";
         });
         invocableMethod = invocableMethod.wrapConcurrentResult(result);
      }
 // 执行controller中方法！！！
      invocableMethod.invokeAndHandle(webRequest, mavContainer);
      if (asyncManager.isConcurrentHandlingStarted()) {
         return null;
      }

      return getModelAndView(mavContainer, modelFactory, webRequest);
   }
   finally {
      webRequest.requestCompleted();
   }
}
```

后续的调用查看调用栈，最后会到我们具体的那个方法：

![image-20240131154730121](media/images/image-20240131154730121.png)

```java
@RequestMapping("/users")
public String users() {
    System.out.println("come in....");
    System.out.println("come out....");
    return "users";
}
```

##### 视图渲染

我上面没有返回一个具体的视图，后续代码可以看：https://pdai.tech/md/spring/spring-x-framework-springmvc-source-2.html。但是我配置了具体的页面，也是视图，我这个请求会跳转到user.jsp页面的。我们查看返回后的结果：

![image-20240131155030207](media/images/image-20240131155030207.png)

接下来继续执行processDispatchResult方法，对视图和model（如果有异常则对异常处理）进行处理（显然就是渲染页面了）。返回到调用入口，查看 modelandview

![image-20240131155148338](media/images/image-20240131155148338.png)

```java
/**
  * Handle the result of handler selection and handler invocation, which is
  * either a ModelAndView or an Exception to be resolved to a ModelAndView.
  */
private void processDispatchResult(HttpServletRequest request, HttpServletResponse response,
    @Nullable HandlerExecutionChain mappedHandler, @Nullable ModelAndView mv,
    @Nullable Exception exception) throws Exception {

  boolean errorView = false;

  // 如果处理过程有异常，则异常处理
  if (exception != null) {
    if (exception instanceof ModelAndViewDefiningException) {
      logger.debug("ModelAndViewDefiningException encountered", exception);
      mv = ((ModelAndViewDefiningException) exception).getModelAndView();
    }
    else {
      Object handler = (mappedHandler != null ? mappedHandler.getHandler() : null);
      mv = processHandlerException(request, response, handler, exception);
      errorView = (mv != null);
    }
  }

  // 是否需要渲染视图
  if (mv != null && !mv.wasCleared()) {
    render(mv, request, response); // 渲染视图
    if (errorView) {
      WebUtils.clearErrorRequestAttributes(request);
    }
  }
  else {
    if (logger.isTraceEnabled()) {
      logger.trace("No view rendering, null ModelAndView returned.");
    }
  }

  if (WebAsyncUtils.getAsyncManager(request).isConcurrentHandlingStarted()) {
    // Concurrent handling started during a forward
    return;
  }

  if (mappedHandler != null) {
    // Exception (if any) is already handled..
    mappedHandler.triggerAfterCompletion(request, response, null);
  }
}
```

接下来显然就是渲染视图了, spring在initStrategies方法中初始化的组件（LocaleResovler等）就派上用场了。还记得我们配置springmvc.xml的时候配置了视图相关组件吗？

```xml
<bean class="org.springframework.web.servlet.view.InternalResourceViewResolver" id="jspViewResolver">
    <property name="viewClass" value="org.springframework.web.servlet.view.JstlView"/>
    <property name="prefix" value="/WEB-INF/"/>
    <property name="suffix" value=".jsp"/>
</bean>
```

在执行完了resolveViewName 方法后，查看view就已经是正常的页面了。这里有一个 Locale，查看

![image-20240131155939860](media/images/image-20240131155939860.png)

![image-20240131155552277](media/images/image-20240131155552277.png)

后续就是通过viewResolver进行解析了。

#### 总结

核心逻辑比较清晰，先从处理器映射器中查询请求对应的业务处理器，然后再根据业务处理器找到处理器适配器，然后调用适配器的handle方法处理业务，最终执行processDispatchResult方法处理请求的处理结果。

getHandler逻辑就是从集合handlerMappings中找到匹配的处理器；

getHandlerAdapter就是从集合handlerAdapters中找到对应的适配器；

handle方法就是通过反射机制执行对应处理器的方法；

processDispatchResult就是将执行结果封装成ModelAndView对象； 