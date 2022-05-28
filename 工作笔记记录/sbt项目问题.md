##### 1 sbt 排除依赖冲突

[Sbt 排除依赖冲突详细解析](https://blog.csdn.net/silentwolfyh/article/details/80820511)

##### 2 sbt 依赖下载慢问题：

两种覆盖默认mvn2仓库解决方案，使用阿里云镜像

1.项目覆盖

```
resolvers += "central" at "http://maven.aliyun.com/nexus/content/groups/public/"
externalResolvers :=
 Resolver.withDefaultResolvers(resolvers.value, mavenCentral = false)
```

2.全局覆盖

```tex
在~/.sbt/repositories添加如下内容（如果没有则创建这个文件）
[repositories]
local
my-maven-repo: http://maven.aliyun.com/nexus/content/groups/public

完成后，当在build.sbt添加依赖时，在idea的sbtShell可以看到如下内容
[info] downloading http://maven.aliyun.com/nexus/content/groups/public/junit/junit/4.2/junit-4.2-sources.jar ...
[info] 	[SUCCESSFUL ] junit#junit;4.2!junit.jar(src) (1011ms)
[info] Writing structure to /tmp/sbt-structure.xml...
[info] Done.
这就表明更换镜像成功了，另外，sbt解析依赖过程也稍微耗时，不可能修改build.sbt后立即完成
dump project structure from sbt 过程

ps:官方文档 
https://www.scala-sbt.org/0.13.2/docs/Detailed-Topics/Library-Management.html#override-all-resolvers-for-all-builds



更新
之前spark的jar包在阿里镜像上找不到，解析报错，于是又尝试了华为的镜像，可以正常使用，链接如下，在里面找到sbt即可
https://mirrors.huaweicloud.com/
推荐一个稳定速度还行的国外源
typesafe: http://repo.typesafe.com/typesafe/ivy-releases/, [organization]/[module]/(scala_[scalaVersion]/)(sbt_[sbtVersion]/)[revision]/[type]s/[artifact](-[classifier]).[ext], bootOnly
```

我的项目是这样的：


```properties
name := """HS_ERP"""

organization in ThisBuild := "com.etwealth.mo"
version in ThisBuild := "1.0.0-SNAPSHOT"
description := "Health Smart ERP"

scalaVersion in ThisBuild  := "2.12.2"

lazy val root = (project in file(".")).enablePlugins(PlayJava, SbtWeb)
//lazy val root = project.in(file(".")).enablePlugins(PlayJava, SbtWeb).dependsOn(module).aggregate(module)
//lazy val module = project.in(file("module"))

scalacOptions in ThisBuild ++= Seq("-target:jvm-1.8", "-encoding", "UTF-8", "-deprecation", "-feature", "-unchecked", "-language:implicitConversions", "-language:reflectiveCalls")
javacOptions in ThisBuild ++= Seq("-encoding", "UTF-8", "-g", "-source", "1.8", "-target", "1.8")
crossPaths in ThisBuild := false
publishArtifact in (Compile, packageDoc) := false
publishArtifact in (Compile, packageSrc) := false


val logbackVersion = "1.1.8"
val slf4jVersion = "1.7.22"
val commonsLangVersion = "3.6"
val nettyVersion = "4.1.8.Final"
val springVersion = "4.3.10.RELEASE"
val gsonVersion = "2.8.0"
val commonsIOVersion = "2.5"
val mysqlVersion = "5.1.46"
val oracleVersion = "12.2.0.1"
val itextpdfVersion = "5.5.12"
val itextAsianVersion = "5.2.0"
val jgroupsVersion = "4.0.4.Final"
val jasperreportsVersion = "6.7.0"
val poiOOXmlVersion = "3.16"

libraryDependencies += guice
libraryDependencies ++= Seq(
  javaJdbc,
  javaWs,
  "com.google.inject.extensions" % "guice-multibindings" % "4.1.0",
  "mysql" % "mysql-connector-java" % mysqlVersion,
  "oracle" % "ojdbc8" % oracleVersion,
  "ch.qos.logback" % "logback-classic" % logbackVersion,
  "org.slf4j" % "slf4j-api" % slf4jVersion,
  "org.apache.commons" % "commons-lang3" % commonsLangVersion,
  "io.netty" % "netty-all" % nettyVersion force(),
  "org.springframework" % "spring-core" % springVersion,
  "org.springframework" % "spring-aop" % springVersion,
  "org.springframework" % "spring-beans" % springVersion,
  "org.springframework" % "spring-context" % springVersion,
  "org.springframework" % "spring-expression" % springVersion,
  "org.springframework" % "spring-context-support" % springVersion,
  "com.google.code.gson" % "gson" % gsonVersion,
  "org.hibernate" % "hibernate-entitymanager" % "5.2.11.Final", // replace by your jpa implementation
  "commons-lang" % "commons-lang" % "2.6",
  "org.hibernate" % "hibernate-c3p0" % "5.2.11.Final",
  "org.hibernate" % "hibernate-core" % "5.2.11.Final",
  "org.infinispan" % "infinispan-core" % "9.1.0.Final",
  "org.hibernate" % "hibernate-search-orm" % "5.7.2.Final",
  "org.hibernate" % "hibernate-envers" % "5.2.11.Final",
  "org.springframework" % "spring-orm" % springVersion,
  "commons-beanutils" % "commons-beanutils" % "1.9.3",
  "org.webjars" % "requirejs" % "2.3.3",
  "org.javassist" % "javassist" % "3.22.0-GA",
  "javax.el" % "javax.el-api" % "3.0.1-b04",
  "org.glassfish.web" % "javax.el" % "2.2.6",
  "commons-io" % "commons-io" % commonsIOVersion,
  "net.sf.jgrapht" % "jgrapht" % "0.8.3",
  "net.sf.jasperreports" % "jasperreports" % jasperreportsVersion
    exclude("com.lowagie", "itext"),
  "org.apache.poi" % "poi-ooxml" % poiOOXmlVersion,
  "com.itextpdf" % "itextpdf" % itextpdfVersion,
  "com.itextpdf" % "itext-asian" % itextAsianVersion,
  "org.jgroups" % "jgroups" % jgroupsVersion,
  "xenport" % "font-ARIALUNI" % "1.1",
  "org.apache.httpcomponents" % "httpclient" % "4.5.3",
  "org.apache.httpcomponents" % "httpmime" % "4.5.3",
  "org.apache.httpcomponents" % "httpcore" % "4.4.6",
  "com.typesafe.play" %% "play-mailer" % "6.0.1",
  "com.typesafe.play" %% "play-mailer-guice" % "6.0.1",
  "org.apache.velocity" % "velocity" % "1.7",
  "com.lmax" % "disruptor" % "3.4.2",
  "org.apache.shiro" % "shiro-core" % "1.4.0",
  "org.apache.pdfbox" % "pdfbox" % "2.0.15",
  "org.jsoup" % "jsoup" % "1.13.1",
  "ar.com.fdvs" % "DynamicJasper" % "5.2.0"
)
resolvers in ThisBuild ++= Seq(
  "Local Maven Repository" at "file:////"+Path.userHome.absolutePath+"/.m2/repository",
  "etw-repo" at "http://202.130.86.228/maven/",
  "Scalaz Bintray Repo" at "https://dl.bintray.com/scalaz/releases",
  "Atlassian Releases" at "https://maven.atlassian.com/public/",
  "Sonatype OSS Snapshots" at "https://oss.sonatype.org/content/repositories/snapshots/",
  "jaspersoft third-party-ce-artifacts" at "http://jaspersoft.jfrog.io/jaspersoft/third-party-ce-artifacts/",
  "aliyun-maven-public" at "https://maven.aliyun.com/repository/public", 
  "aliyun-maven-central" at "https://maven.aliyun.com/repository/central",
  Resolver.jcenterRepo
)

EclipseKeys.preTasks := Seq(compile in Compile)

EclipseKeys.projectFlavor := EclipseProjectFlavor.Java           // Java project. Don't expect Scala IDE
EclipseKeys.createSrc := EclipseCreateSrc.ValueSet(EclipseCreateSrc.ManagedClasses, EclipseCreateSrc.ManagedResources)  // Use .class files instead of generated .scala files for views and routes

// Note if you are using sub-projects with aggregate, you would need to set skipParents // appropriately in build.sbt:
EclipseKeys.skipParents in ThisBuild := false

routesGenerator := InjectedRoutesGenerator

fork in run := false

unmanagedSourceDirectories in Compile += baseDirectory.value / "src/main/java"
unmanagedResourceDirectories in Compile += baseDirectory.value / "src/main/resources"

libraryDependencies += filters
```

新添加的内容：

```properties
  "aliyun-maven-public" at "https://maven.aliyun.com/repository/public", 
  "aliyun-maven-central" at "https://maven.aliyun.com/repository/central",
```

