#### 1 spring boot 和 cloud 的版本对应

博客：[Spring Boot、Spring Cloud与Spring Cloud Alibaba版本对应关系_@lehao的博客-CSDN博客_alibaba cloud 版本对应关系](https://blog.csdn.net/qq_18432653/article/details/109612235) 

##### 一 、前言

在搭建SpringCloud项目环境架构的时候，需要选择SpringBoot和SpringCloud进行兼容的版本号，因此对于选择SpringBoot版本与SpringCloud版本的对应关系很重要，如果版本关系不对应，常见的会遇见项目启动不起来，怪异的则会是你的项目出现一些诡异的问题，查资料也不好查。

##### 1 历史版本图

![image-20221101115537193](media/images/image-20221101115537193.png)

##### 二、查看版本关系

`https://start.spring.io/actuator/info ` 

```json
{
    "git": {
        "branch": "f5360b578faa5e3530069e319097acbe5b609af8",
        "commit": {
            "id": "f5360b5",
            "time": "2022-11-01T16:47:02Z"
        }
    },
    "build": {
        "version": "0.0.1-SNAPSHOT",
        "artifact": "start-site",
        "versions": {
            "spring-boot": "2.7.5",
            "initializr": "0.13.0"
        },
        "name": "start.spring.io website",
        "time": "2022-11-01T16:50:14.056Z",
        "group": "io.spring.start"
    },
    "bom-ranges": {
        "codecentric-spring-boot-admin": {
            "2.4.3": "Spring Boot >=2.3.0.M1 and <2.5.0-M1",
            "2.5.6": "Spring Boot >=2.5.0.M1 and <2.6.0-M1",
            "2.6.8": "Spring Boot >=2.6.0.M1 and <2.7.0-M1",
            "2.7.4": "Spring Boot >=2.7.0.M1 and <3.0.0-M1",
            "3.0.0-M4": "Spring Boot >=3.0.0-M1 and <3.1.0-M1"
        },
        "solace-spring-boot": {
            "1.1.0": "Spring Boot >=2.3.0.M1 and <2.6.0-M1",
            "1.2.2": "Spring Boot >=2.6.0.M1 and <3.0.0-M1"
        },
        "solace-spring-cloud": {
            "1.1.1": "Spring Boot >=2.3.0.M1 and <2.4.0-M1",
            "2.1.0": "Spring Boot >=2.4.0.M1 and <2.6.0-M1",
            "2.3.2": "Spring Boot >=2.6.0.M1 and <3.0.0-M1"
        },
        "spring-cloud": {
            "Hoxton.SR12": "Spring Boot >=2.2.0.RELEASE and <2.4.0.M1",
            "2020.0.6": "Spring Boot >=2.4.0.M1 and <2.6.0-M1",
            "2021.0.0-M1": "Spring Boot >=2.6.0-M1 and <2.6.0-M3",
            "2021.0.0-M3": "Spring Boot >=2.6.0-M3 and <2.6.0-RC1",
            "2021.0.0-RC1": "Spring Boot >=2.6.0-RC1 and <2.6.1",
            "2021.0.4": "Spring Boot >=2.6.1 and <3.0.0-M1",
            "2022.0.0-M1": "Spring Boot >=3.0.0-M1 and <3.0.0-M2",
            "2022.0.0-M2": "Spring Boot >=3.0.0-M2 and <3.0.0-M3",
            "2022.0.0-M3": "Spring Boot >=3.0.0-M3 and <3.0.0-M4",
            "2022.0.0-M4": "Spring Boot >=3.0.0-M4 and <3.0.0-M5",
            "2022.0.0-M5": "Spring Boot >=3.0.0-M5 and <3.1.0-M1"
        },
        "spring-cloud-azure": {
            "4.3.0": "Spring Boot >=2.5.0.M1 and <2.7.0-M1",
            "4.4.1": "Spring Boot >=2.7.0-M1 and <3.0.0-M1"
        },
        "spring-cloud-gcp": {
            "2.0.11": "Spring Boot >=2.4.0-M1 and <2.6.0-M1",
            "3.4.0": "Spring Boot >=2.6.0-M1 and <3.0.0-M1"
        },
        "spring-cloud-services": {
            "2.3.0.RELEASE": "Spring Boot >=2.3.0.RELEASE and <2.4.0-M1",
            "2.4.1": "Spring Boot >=2.4.0-M1 and <2.5.0-M1",
            "3.3.0": "Spring Boot >=2.5.0-M1 and <2.6.0-M1",
            "3.4.0": "Spring Boot >=2.6.0-M1 and <2.7.0-M1",
            "3.5.0": "Spring Boot >=2.7.0-M1 and <3.0.0-M1"
        },
        "spring-geode": {
            "1.3.12.RELEASE": "Spring Boot >=2.3.0.M1 and <2.4.0-M1",
            "1.4.13": "Spring Boot >=2.4.0-M1 and <2.5.0-M1",
            "1.5.14": "Spring Boot >=2.5.0-M1 and <2.6.0-M1",
            "1.6.12": "Spring Boot >=2.6.0-M1 and <2.7.0-M1",
            "1.7.4": "Spring Boot >=2.7.0-M1 and <3.0.0-M1",
            "2.0.0-M5": "Spring Boot >=3.0.0-M1 and <3.1.0-M1"
        },
        "spring-shell": {
            "2.1.3": "Spring Boot >=2.7.0 and <3.0.0-M1",
            "3.0.0-M2": "Spring Boot >=3.0.0-M1 and <3.1.0-M1"
        },
        "vaadin": {
            "14.8.20": "Spring Boot >=2.1.0.RELEASE and <2.6.0-M1",
            "23.2.6": "Spring Boot >=2.6.0-M1 and <2.8.0-M1"
        },
        "wavefront": {
            "2.0.2": "Spring Boot >=2.1.0.RELEASE and <2.4.0-M1",
            "2.1.1": "Spring Boot >=2.4.0-M1 and <2.5.0-M1",
            "2.2.2": "Spring Boot >=2.5.0-M1 and <2.7.0-M1",
            "2.3.0": "Spring Boot >=2.7.0-M1 and <3.0.0-M1"
        }
    },
    "dependency-ranges": {
        "native": {
            "0.9.0": "Spring Boot >=2.4.3 and <2.4.4",
            "0.9.1": "Spring Boot >=2.4.4 and <2.4.5",
            "0.9.2": "Spring Boot >=2.4.5 and <2.5.0-M1",
            "0.10.0": "Spring Boot >=2.5.0-M1 and <2.5.2",
            "0.10.1": "Spring Boot >=2.5.2 and <2.5.3",
            "0.10.2": "Spring Boot >=2.5.3 and <2.5.4",
            "0.10.3": "Spring Boot >=2.5.4 and <2.5.5",
            "0.10.4": "Spring Boot >=2.5.5 and <2.5.6",
            "0.10.5": "Spring Boot >=2.5.6 and <2.5.9",
            "0.10.6": "Spring Boot >=2.5.9 and <2.6.0-M1",
            "0.11.0-M1": "Spring Boot >=2.6.0-M1 and <2.6.0-RC1",
            "0.11.0-M2": "Spring Boot >=2.6.0-RC1 and <2.6.0",
            "0.11.0-RC1": "Spring Boot >=2.6.0 and <2.6.1",
            "0.11.0": "Spring Boot >=2.6.1 and <2.6.2",
            "0.11.1": "Spring Boot >=2.6.2 and <2.6.3",
            "0.11.2": "Spring Boot >=2.6.3 and <2.6.4",
            "0.11.3": "Spring Boot >=2.6.4 and <2.6.6",
            "0.11.5": "Spring Boot >=2.6.6 and <2.7.0-M1",
            "0.12.0": "Spring Boot >=2.7.0-M1 and <2.7.1",
            "0.12.1": "Spring Boot >=2.7.1 and <3.0.0-M1"
        },
        "okta": {
            "1.4.0": "Spring Boot >=2.2.0.RELEASE and <2.4.0-M1",
            "1.5.1": "Spring Boot >=2.4.0-M1 and <2.4.1",
            "2.0.1": "Spring Boot >=2.4.1 and <2.5.0-M1",
            "2.1.6": "Spring Boot >=2.5.0-M1 and <3.0.0-M1"
        },
        "mybatis": {
            "2.1.4": "Spring Boot >=2.1.0.RELEASE and <2.5.0-M1",
            "2.2.2": "Spring Boot >=2.5.0-M1"
        },
        "camel": {
            "3.5.0": "Spring Boot >=2.3.0.M1 and <2.4.0-M1",
            "3.10.0": "Spring Boot >=2.4.0.M1 and <2.5.0-M1",
            "3.13.0": "Spring Boot >=2.5.0.M1 and <2.6.0-M1",
            "3.17.0": "Spring Boot >=2.6.0.M1 and <2.7.0-M1",
            "3.19.0": "Spring Boot >=2.7.0.M1 and <3.0.0-M1"
        },
        "picocli": {
            "4.6.3": "Spring Boot >=2.4.0.RELEASE and <3.0.0-M1"
        },
        "open-service-broker": {
            "3.2.0": "Spring Boot >=2.3.0.M1 and <2.4.0-M1",
            "3.3.1": "Spring Boot >=2.4.0-M1 and <2.5.0-M1",
            "3.4.1": "Spring Boot >=2.5.0-M1 and <2.6.0-M1",
            "3.5.0": "Spring Boot >=2.6.0-M1 and <2.7.0-M1"
        }
    }
}
```

##### 三、如何选择SpringBoot与SpringCloud版本号

项目搭建初期，如何对SpringBoot和SpringCloud的一个相互兼容性版本号进行选择，这是很重要的一步，例如SpringCloud的Hoxton.SR3这个版本，他对应的"Spring Boot >=2.2.0.M4 and <2.3.0.BUILD-SNAPSHOT"版本，意思就是如果选择使用SpringCloud 的Hoxton.SR3这个版本，那么SpringBoot的版本需要大于等于2.2.0小于2.3.0即可满足兼容性。

###### 1 . 引入SpringCloud版本管理

```xml
 <dependencyManagement>
        <dependencies>
            <dependency>
                <groupId>org.springframework.cloud</groupId>
                <artifactId>spring-cloud-dependencies</artifactId>
                <version>Hoxton.SR3</version>
                <type>pom</type>
                <scope>import</scope>
            </dependency>
        </dependencies>
 </dependencyManagement>
```

###### 2 使用Spring Boot

`Spring Boot`可以也像父工程那样管理自己内部的兼容版本号，如下：

```xml
<parent>
   <groupId>org.springframework.boot</groupId>
   <artifactId>spring-boot-starter-parent</artifactId>
   <version>2.2.5.RELEASE</version>
   <relativePath/> <!-- lookup parent from repository -->
</parent>
```

##### 四、SpringBoot、SpringCloud、SpringCloudAlibaba版本对应关系

由于`Spring Cloud`基于`Spring Boot`构建，而`Spring Cloud Alibaba`又基于`Spring Cloud Common`的规范实现，所以当我们使用``Spring Cloud Alibaba`来构建微服务应用的时候，需要知道这三者之间的版本关系。

###### 毕业版本依赖关系(推荐使用)

由于 Spring Boot 2.4+ 和以下版本之间变化较大，目前企业级客户老项目相关 Spring Boot 版本仍停留在 Spring Boot 2.4 以下，为了同时满足存量用户和新用户不同需求，社区以 Spring Boot 2.4 为分界线，同时维护 2.2.x 和 2021.x 两个分支迭代。

###### 2021.x 分支

适配 Spring Boot 2.4，Spring Cloud 2021.x 版本及以上的 Spring Cloud Alibaba 版本按从新到旧排列如下表（最新版本用*标记）： *(注意，该分支 Spring Cloud Alibaba 版本命名方式进行了调整，未来将对应 Spring Cloud 版本，前三位为 Spring Cloud 版本，最后一位为扩展版本，比如适配 Spring Cloud 2021.0.1 版本对应的 Spring Cloud Alibaba 第一个版本为：2021.0.1.0，第个二版本为：2021.0.1.1，依此类推)*

| Spring Cloud Alibaba Version | Spring Cloud Version  | Spring Boot Version |
| ---------------------------- | --------------------- | ------------------- |
| 2021.0.4.0*                  | Spring Cloud 2021.0.4 | 2.6.11              |
| 2021.0.1.0                   | Spring Cloud 2021.0.1 | 2.6.3               |
| 2021.1                       | Spring Cloud 2020.0.1 | 2.4.2               |

###### 2.2.x 分支

适配 Spring Boot 为 2.4，Spring Cloud Hoxton 版本及以下的 Spring Cloud Alibaba 版本按从新到旧排列如下表（最新版本用*标记）：

| Spring Cloud Alibaba Version      | Spring Cloud Version        | Spring Boot Version |
| --------------------------------- | --------------------------- | ------------------- |
| 2.2.9.RELEASE*                    | Spring Cloud Hoxton.SR12    | 2.3.12.RELEASE      |
| 2.2.8.RELEASE                     | Spring Cloud Hoxton.SR12    | 2.3.12.RELEASE      |
| 2.2.7.RELEASE                     | Spring Cloud Hoxton.SR12    | 2.3.12.RELEASE      |
| 2.2.6.RELEASE                     | Spring Cloud Hoxton.SR9     | 2.3.2.RELEASE       |
| 2.1.4.RELEASE                     | Spring Cloud Greenwich.SR6  | 2.1.13.RELEASE      |
| 2.2.1.RELEASE                     | Spring Cloud Hoxton.SR3     | 2.2.5.RELEASE       |
| 2.2.0.RELEASE                     | Spring Cloud Hoxton.RELEASE | 2.2.X.RELEASE       |
| 2.1.2.RELEASE                     | Spring Cloud Greenwich      | 2.1.X.RELEASE       |
| 2.0.4.RELEASE(停止维护，建议升级) | Spring Cloud Finchley       | 2.0.X.RELEASE       |
| 1.5.1.RELEASE(停止维护，建议升级) | Spring Cloud Edgware        | 1.5.X.RELEASE       |

##### 五. Spring Cloud Alibaba与组件版本关系

###### 组件版本关系

每个 Spring Cloud Alibaba 版本及其自身所适配的各组件对应版本如下表所示（注意，Spring Cloud Dubbo 从 2021.0.1.0 起已被移除出主干，不再随主干演进）：

| Spring Cloud Alibaba Version                              | Sentinel Version | Nacos Version | RocketMQ Version | Dubbo Version | Seata Version |
| --------------------------------------------------------- | ---------------- | ------------- | ---------------- | ------------- | ------------- |
| 2.2.9.RELEASE                                             | 1.8.5            | 2.1.0         | 4.9.4            | ~             | 1.5.2         |
| 2021.0.4.0                                                | 1.8.5            | 2.0.4         | 4.9.4            | ~             | 1.5.2         |
| 2.2.8.RELEASE                                             | 1.8.4            | 2.1.0         | 4.9.3            | ~             | 1.5.1         |
| 2021.0.1.0                                                | 1.8.3            | 1.4.2         | 4.9.2            | ~             | 1.4.2         |
| 2.2.7.RELEASE                                             | 1.8.1            | 2.0.3         | 4.6.1            | 2.7.13        | 1.3.0         |
| 2.2.6.RELEASE                                             | 1.8.1            | 1.4.2         | 4.4.0            | 2.7.8         | 1.3.0         |
| 2021.1 or 2.2.5.RELEASE or 2.1.4.RELEASE or 2.0.4.RELEASE | 1.8.0            | 1.4.1         | 4.4.0            | 2.7.8         | 1.3.0         |
| 2.2.3.RELEASE or 2.1.3.RELEASE or 2.0.3.RELEASE           | 1.8.0            | 1.3.3         | 4.4.0            | 2.7.8         | 1.3.0         |
| 2.2.1.RELEASE or 2.1.2.RELEASE or 2.0.2.RELEASE           | 1.7.1            | 1.2.1         | 4.4.0            | 2.7.6         | 1.2.0         |
| 2.2.0.RELEASE                                             | 1.7.1            | 1.1.4         | 4.4.0            | 2.7.4.1       | 1.0.0         |
| 2.1.1.RELEASE or 2.0.1.RELEASE or 1.5.1.RELEASE           | 1.7.0            | 1.1.4         | 4.4.0            | 2.7.3         | 0.9.0         |
| 2.1.0.RELEASE or 2.0.0.RELEASE or 1.5.0.RELEASE           | 1.6.3            | 1.1.1         | 4.4.0            | 2.7.3         | 0.7.1         |

##### 六、依赖管理

Spring Cloud Alibaba BOM 包含了它所使用的所有依赖的版本。

###### RELEASE 版本

**Spring Cloud Hoxton**

如果需要使用 Spring Cloud Hoxton 版本，请在 dependencyManagement中添加如下配置

```xml
<dependency>
    <groupId>com.alibaba.cloud</groupId>
    <artifactId>spring-cloud-alibaba-dependencies</artifactId>
    <version>2.2.3.RELEASE</version>
    <type>pom</type>
    <scope>import</scope>
</dependency>
```

然后在dependencies 中添加自己所需使用的依赖即可使用。

**Spring Cloud Greenwich**

如果需要使用 Spring Cloud Greenwich版本，请在 dependencyManagement中添加如下配置

```xml
<dependency>
    <groupId>com.alibaba.cloud</groupId>
    <artifactId>spring-cloud-alibaba-dependencies</artifactId>
    <version>2.1.3.RELEASE</version>
    <type>pom</type>
    <scope>import</scope>
</dependency>
```

然后在 dependencies中添加自己所需使用的依赖即可使用。

**Spring Cloud Finchley**

如果需要使用 Spring Cloud Finchley版本，请在 dependencyManagement中添加如下配置

```xml
<dependency>
    <groupId>com.alibaba.cloud</groupId>
    <artifactId>spring-cloud-alibaba-dependencies</artifactId>
    <version>2.0.3.RELEASE</version>
    <type>pom</type>
    <scope>import</scope>
</dependency>
```

然后在dependencies中添加自己所需使用的依赖即可使用。

**Spring Cloud Edgware**

如果需要使用 Spring Cloud Edgware 版本，请在 dependencyManagement中添加如下配置

```xml
<dependency>
    <groupId>com.alibaba.cloud</groupId>
    <artifactId>spring-cloud-alibaba-dependencies</artifactId>
    <version>1.5.1.RELEASE</version>
    <type>pom</type>
    <scope>import</scope>
</dependency>
```

然后在 dependencies中添加自己所需使用的依赖即可使用。

###### 版本管理规范

项目的版本号格式为 x.x.x 的形式，其中 x 的数值类型为数字，从 0 开始取值，且不限于 0~9 这个范围。项目处于孵化器阶段时，第一位版本号固定使用 0，即版本号为 0.x.x 的格式。

由于 `Spring Boot 1 和 Spring Boot 2 在 Actuator 模块的接口和注解有很大的变更，且 spring-cloud-commons 从 1.x.x 版本升级到 2.0.0 版本也有较大的变更，因此我们采取跟 SpringBoot 版本号一致的版本:

**1.5.x 版本适用于 Spring Boot 1.5.x**

**2.0.x 版本适用于 Spring Boot 2.0.x**

**2.1.x 版本适用于 Spring Boot 2.1.x**

**2.2.x 版本适用于 Spring Boot 2.2.x**

##### 参考

1. Spring-Cloud-Alibaba版本说明：[https://github.com/alibaba/spring-cloud-alibaba/wiki/版本说明](https://github.com/alibaba/spring-cloud-alibaba/wiki/版本说明) 

2. SpringCloudAlibaba中文社区地址: [https://github.com/alibaba/spring-cloud-alibaba/blob/master/README-zh.md]( https://github.com/alibaba/spring-cloud-alibaba/blob/master/README-zh.md) 
3. SpringCloud官方文档： [Spring Cloud Gateway](https://cloud.spring.io/spring-cloud-static/spring-cloud-gateway/2.2.1.RELEASE/reference/html/) 

#### 2 记录java.lang.NoClassDefFoundError: org/springframework/boot/logging/DeferredLogFactory错误

今天学习springboot出现java.lang.NoClassDefFoundError: org/springframework/boot/logging/DeferredLogFactory 错误，原因是修改了springboot版本，导致boot版本与cloud版本不一致导致的。

原本的boot版本为2.7.5，被我修改为了2.3.2.RELEASE，因此需要修改cloud的版本.

```xml
<properties>
    <java.version>1.8</java.version>
    <spring-cloud.version>2021.0.4</spring-cloud.version>
</properties>
```

原本的 spring-cloud 的版本。需要修改成和 boot 对应的版本，需要查询到对应的版本，地址： https://github.com/spring-cloud/spring-cloud-release/wiki/Spring-Cloud-Hoxton-Release-Notes 

spring boot版本是：

```xml
<parent>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-parent</artifactId>
    <version>2.3.2.RELEASE</version>
    <relativePath/> <!-- lookup parent from repository -->
</parent>
```

可以参考：https://blog.csdn.net/m0_37824308/article/details/122717359 

springboot 和spring cloud的版本对应

![image-20221101115537193](media/images/image-20221101115537193.png)

需要将版本改成：

```xml
<properties>
    <java.version>1.8</java.version>
    <spring-cloud.version>Hoxton.SR12</spring-cloud.version>
</properties>
```

#### 3 spring boot 项目时间映射错误，while it seems to fit format ‘yyyy-MM-dd‘T‘HH:mm:ss.SSSZ，

> nested exception is com.fasterxml.jackson.databind.exc.InvalidFormatException: Cannot deserialize value of type `java.util.Date` from String "2022-10-28 09:36:10.100": not a valid representation (error: Failed to parse Date value '2022-10-28 09:36:10.100': Cannot parse date "2022-10-28 09:36:10.100": while it seems to fit format 'yyyy-MM-dd'T'HH:mm:ss.SSSX', parsing fails (leniency? null))

报错的是 jackson 的一个解析异常，搜索网上解决方案，在配置文件里加上一个配置：

```yaml
spring: 
  jackson:
    date-format: yyyy-MM-dd HH:mm:ss
```

正常的spring mvc 是在字段上加上注解 `@DateTimeFormat(pattern = "yyyy-MM-dd HH:mm:ss")`。

![image-20221101140829033](media/images/image-20221101140829033.png)

此时请求成功。