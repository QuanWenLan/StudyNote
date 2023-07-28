博客链接：https://blog.csdn.net/wanxiaoderen/article/details/107043218

#### 核心项目

- org.objectweb.asm 和 org.objectweb.asm.signature 包定义了基于事件的API，并提供了类分析器和写入器组件。它们包含在 asm.jar 中。 
- org.objectweb.asm.util 包，位于asm-util.jar中，提供各种基于核心 API 的工具，可以在开发和调试 ASM 应用程序时使用。 
- org.objectweb.asm.commons 包提供了几个很有用的预定义类转换器，它们大多是基于核心 API 的。这个包包含在 asm-commons.jar中。
- org.objectweb.asm.tree 包，位于asm-tree.jar 存档文件中，定义了基于对 象的 API，并提供了一些工具，用于在基于事件和基于对象的表示方法之间进行转换。 
- 1.2.5 org.objectweb.asm.tree.analysis 包提供了一个类分析框架和几个预定义的 类 分析器，它们以树 API 为基础。这个包包含在 asm-analysis.jar 文件中。

#### maven仓库地址

https://mvnrepository.com/artifact/org.ow2.asm

#### maven 依赖 asm 配置

```xml
<properties>  
    <asm.version>9.4</asm.version>
</properties>
<dependency>
    <artifactId>asm</artifactId>
    <groupId>org.ow2.asm</groupId>
    <version>${asm.version}</version>
</dependency>
<dependency>
    <artifactId>asm-tree</artifactId>
    <groupId>org.ow2.asm</groupId>
    <version>${asm.version}</version>
</dependency>

<dependency>
    <artifactId>asm-analysis</artifactId>
    <groupId>org.ow2.asm</groupId>
    <version>${asm.version}</version>
</dependency>

<dependency>
    <artifactId>asm-commons</artifactId>
    <groupId>org.ow2.asm</groupId>
    <version>${asm.version}</version>
</dependency>

<dependency>
    <artifactId>asm-util</artifactId>
    <groupId>org.ow2.asm</groupId>
    <version>${asm.version}</version>
</dependency>
<!--这个的最高版本没有8.0.1-->
<!--<dependency>
    <artifactId>asm-xml</artifactId>
    <groupId>org.ow2.asm</groupId>
    <version>${asm.version}</version>
</dependency>-->

<dependency>
    <artifactId>asm-commons</artifactId>
    <groupId>org.ow2.asm</groupId>
    <version>${asm.version}</version>
</dependency>

<dependency>
    <artifactId>asm-util</artifactId>
    <groupId>org.ow2.asm</groupId>
    <version>${asm.version}</version>
</dependency>
```

#### idea插件

`ASM Bytecode outline` 和 `hexview`

#### ASM Bytecode outline

