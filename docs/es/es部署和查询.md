### elasticsearch

> [14.Elasticsearch上篇（原理） (passjava.cn)](http://www.passjava.cn/#/01.PassJava/02.PassJava_Architecture/14.Elasticsearch原理.md)  [ElasticSearch 入门-江南一点雨](https://juejin.cn/post/6898582477514752007)
>
> 官方学习链接：[Elastic：开发者上手指南_csdn elastic开发者上手指南-CSDN博客](https://elasticstack.blog.csdn.net/article/details/102728604)

### 基本概念

#### Lucene

Lucene 是一个开源、免费、高性能、纯 Java 编写的全文检索引擎，可以算作是开源领域最好的全文检索工具包。Lucene 只是一个工具包，并非一个完整的搜索引擎，开发者可以基于 Lucene 来开发完整的搜索引擎。比较著名的有 Solr、ElasticSearch，不过在分布式和大数据环境下，ElasticSearch 更胜一筹。

Lucene 主要有如下特点：

- 简单
- 跨语言
- 强大的搜索引擎
- 索引速度快
- 索引文件兼容不同平台

#### ElasticSearch

Elasticsearch 是一个分布式的开源搜索和分析引擎，适用于所有类型的数据，包括文本、数字、地理空间、结构化和非结构化数据。简单来说只要涉及搜索和分析相关的，es都可以做，ElasticSearch 在分布式环境下表现优异，这也是它比较受欢迎的原因之一。它支持 PB 级别的结构化或非结构化海量数据处理，**非关系型数据库，NoSql**，整体上来说，ElasticSearch 有三大功能：数据搜集、数据分析、数据存储。

ElasticSearch 的主要特点：

1. 分布式文件存储。
2. 实时分析的分布式搜索引擎。
3. 高可拓展性。
4. 可插拔的插件支持

#### 本地单节点安装

[Past Releases of Elastic Stack Software | Elastic](https://www.elastic.co/cn/downloads/past-releases#elasticsearch)

下载版本7.14.0，同样kibana也要下载同样的版本1.14.0

![image-20240312110005808](media/images/image-20240312110005808.png)

进入到 bin 目录下，直接执行 ./elasticsearch 启动即可：windows下启动 elasticsearch.bat 文件

启动报错：

![image-20240312113852993](media/images/image-20240312113852993.png)

解决方案

可修改配置文件解决
在elasticsearch目录下的config目录中找到elasticsearch.yml文件，使用文本编辑器打开
添加以下代码

```java
ingest.geoip.downloader.enabled: false
```

保存退出
重新双击elasticsearch.bat开启服务，服务正常如下。访问：[http://127.0.0.1:9200](http://127.0.0.1:9200/) 或 [http://localhost:9200](http://localhost:9200/)

![image-20240312114536156](media/images/image-20240312114536156.png)

启动访问成功

![image-20240312114627983](media/images/image-20240312114627983.png)

#### 集群-分布式安装

将上面的节点复制出两份，首先修改 master 的 config/elasticsearch.yml 配置文件：

```yaml
node.master: true
network.host: 127.0.0.1
```

配置完成后，重启 master。将 es 的压缩包解压两份，分别命名为 slave01 和 slave02，代表两个从机。分别对其进行配置。

slave01/config/elasticsearch.yml：

```yaml
# 集群名称必须保持一致
cluster.name: javaboy-es
node.name: slave01
network.host: 127.0.0.1
http.port: 9201
discovery.zen.ping.unicast.hosts: ["127.0.0.1"]
```

slave02/config/elasticsearch.yml：

```yaml
#集群名称必须保持一致
cluster.name: javaboy-es
node.name: slave02
network.host: 127.0.0.1
http.port: 9202
discovery.zen.ping.unicast.hosts: ["127.0.0.1"]
```

我下载的版本中没有 discovery.zen.ping.unicast.hosts 配置，已经被 discovery.seed_hosts 取代了。所以需要配置这个，但是这个配置的默认值是有的，所以不需要配置了

```properties
# Pass an initial list of hosts to perform discovery when this node is started:
# The default list of hosts is ["127.0.0.1", "[::1]"]
#
#discovery.seed_hosts: ["host1", "host2"]
```

然后分别启动这个三个节点。可以分别访问这三个地址查看是否启动成功：[localhost:9200](http://localhost:9200/)、[localhost:9201](http://localhost:9201/)、[localhost:9202](http://localhost:9202/)

![image-20240312121021773](media/images/image-20240312121021773.png)

![image-20240312121007442](media/images/image-20240312121007442.png)

![image-20240312120955514](media/images/image-20240312120955514.png)

#### HEAD 插件安装

#####  浏览器插件安装

Chrome 直接在 App Store 搜索 Elasticsearch-head，点击安装即可。

##### 下载插件安装

- `git clone git://github.com/mobz/elasticsearch-head.git`
- `cd elasticsearch-head`
- `npm install`
- `npm run start`

注意，此时看不到集群数据。原因在于这里通过跨域的方式请求集群数据的，默认情况下，集群不支持跨域，所以这里就看不到集群数据。解决办法如下，修改 es 的 config/elasticsearch.yml 配置文件，添加如下内容，使之支持跨域：

```yaml
http.cors.enabled: true
http.cors.allow-origin: "*"
```

配置完成后，重启 es，此时 head 上就有数据了。访问：http://localhost:9100

#### docker 下创建实例

##### 1 下载镜像文件

```sh
docker pull elasticsearch:7.4.2
```

##### 2  创建实例

- 映射配置文件

```sh
配置映射文件夹
mkdir -p /mydata/elasticsearch/config

配置映射文件夹
mkdir -p /mydata/elasticsearch/data

设置文件夹权限任何用户可读可写
chmod 777 /mydata/elasticsearch -R

配置 http.host
echo "http.host: 0.0.0.0" >> /mydata/elasticsearch/config/elasticsearch.yml
```

- 启动 elasticsearch 容器

```sh
docker run --name elasticsearch -p 9200:9200 -p 9300:9300 \
-e "discovery.type"="single-node" \
-e ES_JAVA_OPTS="-Xms64m -Xmx128m" \
-v /mydata/elasticsearch/config/elasticsearch.yml:/usr/share/elasticsearch/config/elasticsearch.yml \
-v /mydata/elasticsearch/data:/usr/share/elasticsearch/data \
-v /mydata/elasticsearch/plugins:/usr/share/elasticsearch/plugins \
-d elasticsearch:7.4.2 
```

- 访问 elasticsearch 服务

访问：[42.193.160.246:9200](http://42.193.160.246:9200/) 

```java
{
  "name" : "2f7f7eb21d1d",
  "cluster_name" : "elasticsearch",
  "cluster_uuid" : "1SK-i3LvRcCyq9iTL0TBCg",
  "version" : {
    "number" : "7.6.2",
    "build_flavor" : "default",
    "build_type" : "docker",
    "build_hash" : "ef48eb35cf30adf4db14086e8aabd07ef6fb113f",
    "build_date" : "2020-03-26T06:34:37.794943Z",
    "build_snapshot" : false,
    "lucene_version" : "8.4.0",
    "minimum_wire_compatibility_version" : "6.8.0",
    "minimum_index_compatibility_version" : "6.0.0-beta1"
  },
  "tagline" : "You Know, for Search"
}
```

访问结果

![image-20221025171656229](media/images/image-20221025171656229.png)

### Kibana环境

```sh
docker pull kibana:7.6.2

docker run --name kibana -e ELASTICSEARCH_HOSTS=http://42.193.160.246:9200  -p 5601:5601 -d kibana:7.6.2
```

![image-20221025171627769](media/images/image-20221025171627769.png)

访问地址页面：http://42.193.160.246:5601/ 

![image-20221026092204314](media/images/image-20221026092204314.png)

#### 本地单机环境启动kibana

1. 配置 es 的地址信息（可选，如果 es 是默认地址以及端口，可以不用配置，具体的配置文件是 config/kibana.yml）
2. 执行 ./bin/kibana 文件启动
3. localhost:5601

我们在启动的时候添加了数据进去，可以看到有两个索引。

![image-20240312121944711](media/images/image-20240312121944711.png)

#### 查看集群启动

![image-20240312121834347](media/images/image-20240312121834347.png)

#### 使用 Dev Tools 来创建索引

es的测试数据地址： [elasticsearch/accounts.json at 7.5 · elastic/elasticsearch (github.com)](https://github.com/elastic/elasticsearch/blob/7.5/docs/src/test/resources/accounts.json) 

##### 批处理

命令：：一个好的起点是批量处理 1,000 到 5,000 个文档，总有效负载在 5MB 到 15MB 之间。如果我们的 payload 过大，那么可能会造成请求的失败。如果你想更进一步探讨的话，你可以使用文件 [accounts.json](https://raw.githubusercontent.com/elastic/elasticsearch/master/docs/src/test/resources/accounts.json) 来做实验。更多是有数据可以在地址 [加载示例数据 | Kibana 用户手册 | Elastic 进行下载](https://www.elastic.co/guide/cn/kibana/current/tutorial-load-dataset.html)。

```json
POST /bank/account/_bulk
{"index":{"_id":"1"}}
{"account_number":1,"balance":39225,"firstname":"Amber","lastname":"Duke","age":32,"gender":"M","address":"880 Holmes Lane","employer":"Pyrami","email":"amberduke@pyrami.com","city":"Brogan","state":"IL"}
{"index":{"_id":"6"}}
......
// https://elasticstack.blog.csdn.net/article/details/99481016 有操作方法
```

又或者

```json
POST _bulk
{ "index" : { "_index" : "twitter", "_id": 1} }
{"user":"双榆树-张三","message":"今儿天气不错啊，出去转转去","uid":2,"age":20,"city":"北京","province":"北京","country":"中国","address":"中国北京市海淀区","location":{"lat":"39.970718","lon":"116.325747"}}
{ "index" : { "_index" : "twitter", "_id": 2 }}
{"user":"东城区-老刘","message":"出发，下一站云南！","uid":3,"age":30,"city":"北京","province":"北京","country":"中国","address":"中国北京市东城区台基厂三条3号","location":{"lat":"39.904313","lon":"116.412754"}}
{ "index" : { "_index" : "twitter", "_id": 3} }
{"user":"东城区-李四","message":"happy birthday!","uid":4,"age":30,"city":"北京","province":"北京","country":"中国","address":"中国北京市东城区","location":{"lat":"39.893801","lon":"116.408986"}}
{ "index" : { "_index" : "twitter", "_id": 4} }
{"user":"朝阳区-老贾","message":"123,gogogo","uid":5,"age":35,"city":"北京","province":"北京","country":"中国","address":"中国北京市朝阳区建国门","location":{"lat":"39.718256","lon":"116.367910"}}
{ "index" : { "_index" : "twitter", "_id": 5} }
{"user":"朝阳区-老王","message":"Happy BirthDay My Friend!","uid":6,"age":50,"city":"北京","province":"北京","country":"中国","address":"中国北京市朝阳区国贸","location":{"lat":"39.918256","lon":"116.467910"}}
{ "index" : { "_index" : "twitter", "_id": 6} }
{"user":"虹桥-老吴","message":"好友来了都今天我生日，好友来了,什么 birthday happy 就成!","uid":7,"age":90,"city":"上海","province":"上海","country":"中国","address":"中国上海市闵行区","location":{"lat":"31.175927","lon":"121.383328"}}
```

可以使用delete 来删除一个已经创建好的文档

```json
POST _bulk
{ "delete" : { "_index" : "twitter", "_id": 1 }}
```

也可以是使用 update 来进行更新一个文档。

```json
POST _bulk
{ "update" : { "_index" : "twitter", "_id": 2 }}
{"doc": { "city": "长沙"}}
```



#### 启动有一些警告的处理

启动kibana时会有几个warning信息，具体如下：

https://www.cnblogs.com/hahaha111122222/p/12677691.html

但是警告不影响使用。

### 核心概念

### 中文分词

[Release v7.6.2 · medcl/elasticsearch-analysis-ik (github.com)](https://github.com/medcl/elasticsearch-analysis-ik/releases/tag/v7.6.2) 

下载中文分词器，ik分词器

### 查询语法

#### _cat 用法 

```json
GET /_cat/nodes: 查看所有节点
GET /_cat/health: 查看 es 健康状况
GET /_cat/master: 查看主节点
GET /_cat/indices: 查看所有索引

// 查询汇总：
/_cat/allocation
/_cat/shards
/_cat/shards/{index}
/_cat/master
/_cat/nodes
/_cat/tasks
/_cat/indices
/_cat/indices/{index}
/_cat/segments
/_cat/segments/{index}
/_cat/count
/_cat/count/{index}
/_cat/recovery
/_cat/recovery/{index}
/_cat/health
/_cat/pending_tasks
/_cat/aliases
/_cat/aliases/{alias}
/_cat/thread_pool
/_cat/thread_pool/{thread_pools}
/_cat/plugins
/_cat/fielddata
/_cat/fielddata/{fields}
/_cat/nodeattrs
/_cat/repositories
/_cat/snapshots/{repository}
/_cat/templates
```

#### copy为 cURL

![image-20240312160130969](media/images/image-20240312160130969.png)

```json
curl -XGET "http://localhost:9200/_cat/indices/kibana_sample_data_logs"
```

将这个粘贴到kibana中会变成：GET /_cat/indices/kibana_sample_data_logs

#### 索引一个文档

PUT 和 POST 都可以创建记录。

POST：如果不指定 id，自动生成 id。如果指定 id，则修改这条记录，并新增版本号。

PUT：必须指定 id，如果没有这条记录，则新增，如果有，则更新。

```json
PUT member/external/1
{
"name":"jay huang"
}
// 返回值
{
    "_index": "member", //在哪个索引
    "_type": "external",//在那个类型
    "_id": "2",//记录 id
    "_version": 7,//版本号
    "result": "updated",//操作类型
    "_shards": {
        "total": 2, // 一个是primary shard，一个是replica shard
        "successful": 1,
        "failed": 0
    },
    "_seq_no": 9,
    "_primary_term": 1
}

PUT twitter/_doc/1
{
  "user": "GB",
  "uid": 1,
  "city": "Beijing",
  "province": "Beijing",
  "country": "China"
}
// 结果
{
  "_index" : "twitter",
  "_type" : "_doc",
  "_id" : "1",
  "_version" : 3,
  "result" : "created",
  "_shards" : {
    "total" : 2,
    "successful" : 2,
    "failed" : 0
  },
  "_seq_no" : 2,
  "_primary_term" : 1
}
```

##### 过程

一旦一个文档被写入，它经历如下的一个过程：

![image-20240312161247339](media/images/image-20240312161247339.png)

在通常的情况下，新写入的文档并不能马上被用于搜索。新增的索引必须写入到 Segment 后才能被搜索到。需要等到 refresh 操作才可以。**在默认的情况下每隔一秒的时间 refresh 一次。这就是我们通常所说的近实时**。详细阅读请参阅文章 “Elasticsearch：Elasticsearch 中的 refresh 和 flush 操作指南”。在编程的时候，我们尤为需要注意这一点。比如我们通过 REST API 时写进一个文档，在写入的时候没有强制 refresh 操作，而是立即进行搜索。我们可能搜索不到刚写入的文档。

当我们建立一个索引的第一个文档时，如果你没有创建它的  schema，那么 Elasticsearch 会根据所输入字段的数据进行猜测它的数据类型，比如上面的 user 被被认为是 text 类型，而 uid 将被猜测为整数类型。这种方式我们称之为 schema on write，也即当我们写入第一个文档时，Elasticsearch 会自动帮我们创建相应的 schema。**在 Elasticsearch 的术语中，mapping 被称作为 Elasticsearch 的数据 schema**。文档中的所有字段都需要映射到 Elasticsearch 中的数据类型。 mapping 指定每个字段的数据类型，并确定应如何索引和分析字段以进行搜索。 在 SQL 数据库中定义表时，mapping 类似于 schema。 **mapping 可以显式声明或动态生成**。**一旦一个索引的某个字段的类型被确定下来之后，那么后续导入的文档的这个字段的类型必须是和之前的是一致，否则写入将导致错误**。schema on write 可能在某些时候不是我们想要的，那么在这种情况下，我们可以事先创建一个索引的 schema。
[Elasticsearch：Runtime fields 入门， Elastic 的 schema on read 实现 - 7.11 发布 (csdn.net)](https://elasticstack.blog.csdn.net/article/details/113813915)

在写入文档时，如果该文档的 ID 已经存在，那么就更新现有的文档；如果该文档从来没有存在过，那么就创建新的文档。如果更新时该文档有新的字段并且这个字段在现有的 mapping 中没有出现，那么 Elasticsearch 会根据 schem on write 的策略来推测该字段的类型，并更新当前的 mapping 到最新的状态。

如果我们想让我们的结果马上可以对搜索可见，我们可以用如下的方法：[refresh (elastic.co)](https://www.elastic.co/guide/en/elasticsearch/reference/7.5/docs-refresh.html)， 可以强制使 Elasticsearch 进行 refresh 的操作，当然这个是有代价的。频繁的进行这种操作，可以使我们的 Elasticsearch 变得非常慢。另外一种方式是通过设置 refresh=wait_for。这样相当于一个同步的操作，它等待下一个 refresh 周期发生完后，才返回

```json
PUT twitter/_doc/1?refresh=true
{
  "user": "GB",
  "uid": 1,
  "city": "Beijing",
  "province": "Beijing",
  "country": "China"
}
// 或
PUT twitter/_doc/1?refresh=wait_for
{
  "user": "GB",
  "uid": 1,
  "city": "Beijing",
  "province": "Beijing",
  "country": "China"
}
```

自从 Elasticsearch 6.0 以后，一个 index 只能有一个 type。如果我们创建另外一个 type 的话，系统会告诉我们是错误的。

我们每次执行那个 POST 或者 PUT 接口时，如果文档已经存在，那么相应的版本（_version）就会自动加1，之前的版本抛弃。如果这个不是我们想要的，那么我们可以使 _create 端点接口来实现：

```json
PUT twitter/_create/1
{
  "user": "GB",
  "uid": 1,
  "city": "Shenzhen",
  "province": "Guangdong",
  "country": "China"
}
```

如果文档已经存在的话，我们会收到一个错误的信息：

```json
{
  "error" : {
    "root_cause" : [
      {
        "type" : "version_conflict_engine_exception",
        "reason" : "[1]: version conflict, document already exists (current version [3])",
        "index_uuid" : "xqVmCrisQGGZc1aWHiNfcw",
        "shard" : "0",
        "index" : "twitter"
      }
    ],
    "type" : "version_conflict_engine_exception",
    "reason" : "[1]: version conflict, document already exists (current version [3])",
    "index_uuid" : "xqVmCrisQGGZc1aWHiNfcw",
    "shard" : "0",
    "index" : "twitter"
  },
  "status" : 409
}
```

##### 自动id

```json
POST twitter/_doc
{
  "user": "GB",
  "uid": 1,
  "city": "Beijing",
  "province": "Beijing",
  "country": "China"
}
```

其实在实际的应用中，这个并不必要。相反，当我们分配一个 ID 时，在数据导入的时候会检查这个 ID 的文档是否存在，如果是已经存在，那么就更新到版本。如果不存在，就创建一个新的文档。如果我们不指定文档的 ID，转而让 Elasticsearch 自动帮我们生成一个 ID，**这样的速度更快**。在这种情况下，我们必须使用 POST，而不是 PUT。



#### 查询文档

```json
请求：http://192.168.56.10:9200/member/external/2

Reposne:
{
    "_index": "member",   //在哪个索引
    "_type": "external",  //在那个类型
    "_id": "2",           //记录 id
    "_version": 7,        //版本号
    "_seq_no": 9,         //并发控制字段，每次更新就会+1，用来做乐观锁
    "_primary_term": 1,   //同上，主分片重新分配，如重启，就会变化
    "found": true,
    "_source": { //真正的内容
        "name": "jay huang"
 }
}

_seq_no 用作乐观锁
每次更新完数据后，_seq_no 就会+1，所以可以用作并发控制。
当更新记录时，如果_seq_no 与预设的值不一致，则表示记录已经被至少更新了一次，不允许本次更新。
```

如这个例子：

```json
// 查询所有的
GET users/_search
{
  "took" : 0,
  "timed_out" : false,
  "_shards" : {
    "total" : 1,
    "successful" : 1,
    "skipped" : 0,
    "failed" : 0
  },
  "hits" : {
    "total" : {
      "value" : 1,
      "relation" : "eq"
    },
    "max_score" : 1.0,
    "hits" : [
      {
        "_index" : "users",
        "_type" : "_doc",
        "_id" : "1",
        "_score" : 1.0,
        "_source" : {
          "age" : "18",
          "gender" : "Man",
          "userName" : "PassJava"
        }
      }
    ]
  }
}
查询具体的
GET users/_doc/1
{
  "_index" : "users",
  "_type" : "_doc",
  "_id" : "1",
  "_version" : 1,
  "_seq_no" : 0,
  "_primary_term" : 1,
  "found" : true,
  "_source" : {
    "age" : "18",
    "gender" : "Man",
    "userName" : "PassJava"
  }
}
```

##### 获取 _source

```json
GET twitter/_doc/1/_source 
// 或
// 7.0 之后用这个
GET twitter/_source/1 
{
  "user" : "GB",
  "uid" : 1,
  "city" : "Beijing",
  "province" : "Beijing",
  "country" : "China"
}
// 获取其中一两个字段
GET twitter/_doc/1?_source=city,age,province
{
  "_index" : "twitter",
  "_type" : "_doc",
  "_id" : "1",
  "_version" : 3,
  "_seq_no" : 2,
  "_primary_term" : 1,
  "found" : true,
  "_source" : {
    "province" : "Beijing",
    "city" : "Beijing"
  }
}
```

##### 一次请求查找多个文档

```json
POST twitter/_doc/2 
{
  "user": "quan",
  "uid": 2,
  "city": "shanghai",
  "province": "上海",
  "country": "China"
}
// _source 可选
GET _mget
{
  "docs": [
    {
      "_index": "twitter",
      "_id": 1,
      "_source":["uid", "city"]
    },
    {
      "_index": "twitter",
      "_id": 2,
      "_source":["province", "country"]
    }
  ]
}
// 或者
GET twitter/_doc/_mget
{
  "ids": ["1", "2"]
}
// 返回结果
{
  "docs" : [
    {
      "_index" : "twitter",
      "_type" : "_doc",
      "_id" : "1",
      "_version" : 3,
      "_seq_no" : 2,
      "_primary_term" : 1,
      "found" : true,
      "_source" : {
        "uid" : 1,
        "city" : "Beijing"
      }
    },
    {
      "_index" : "twitter",
      "_type" : "_doc",
      "_id" : "2",
      "_version" : 1,
      "_seq_no" : 3,
      "_primary_term" : 1,
      "found" : true,
      "_source" : {
        "country" : "China",
        "province" : "上海"
      }
    }
  ]
}
```

##### 统计索引总的数据

GET twitter/_count：使用 _count 命令来查询有多少条数据

##### 搜索所有的文档

```json
GET /_all/_search
GET /*/_search
GET /_search
```

我们也可以这样对多个 index 进行搜索：

```json
POST /index1,index2,index3/_search
```

上面，表明，我们可以针对 index1，index2，index3 索引进行搜索。当然，我们甚至也可以这么写：

```json
POST /index*,-index3/_search
```

上面表明，我们可以针对所有以 index 为开头的索引来进行搜索，但是排除 index3 索引。

#### 更新文档

POST 带 `_update` 的更新操作，如果原数据没有变化，则 repsonse 中的 result 返回 noop ( 没有任何操作 ) ，version 也不会变化。请求体中需要用 `doc` 将请求数据包装起来。

```json
POST 请求：http://192.168.56.10:9200/member/external/2/_update
{
    "doc":{
        "name":"jay huang",
         "age": 18  // 可以增加一个属性
 }
}
// 另一种写法也可以
/**
POST twitter/_update/1
{
  "doc": {
    "city": "上海市1" 
  }
}

POST twitter/_doc/1/_update
{
  "doc": {
     "city": "上海市2" 
  }
}
*/
响应：
{
    "_index": "member",
    "_type": "external",
    "_id": "2",
    "_version": 12,
    "result": "noop",
    "_shards": {
        "total": 0,
        "successful": 0,
        "failed": 0
    },
    "_seq_no": 14,
    "_primary_term": 1
}
```

使用场景：对于大并发更新，建议不带 `_update`。对于大并发查询，少量更新的场景，可以带_update，进行对比更新。

如果使用put请求则需要将所有的字段都写上，使用post的话可以只更新其中一部分字段。

###### 如果更新的文档不存在时，可以使用upsert。

```sh
POST 请求：http://192.168.56.10:9200/member/external/2/_update
{
    "doc":{
        "name":"jay huang",
         "age": 18  // 可以增加一个属性
	 },
	 "upsert": {
	 	"name":"lanlan",
	 	"age":20
	 }
}
```

##### 使用脚本语言更新

```json
POST twitter/_update_by_query
{
  "query": {
    "match": {
      "user": "GB"
    }
  },
  "script": {
    "source": "ctx._source.city = params.city;ctx._source.province = params.province;ctx._source.country = params.country",
    "lang": "painless",
    "params": {
      "city": "上海",
      "province": "上海",
      "country": "中国"
    }
  }
}
```

中文字段的话

```json
POST edd/_update_by_query
{
  "query": {
    "match": {
      "姓名": "张彬"
    }
  },
  "script": {
    "source": "ctx._source[\"签到状态\"] = params[\"签到状态\"]",
    "lang": "painless",
    "params" : {
      "签到状态":"已签到"
    }
  }
}
```

#### 检查一个文档是否存在

有时候我们想知道一个文档是否存在，我们可以使用如下的方法：

```json
HEAD twitter/_doc/1
// 返回
200 - OK
```



#### 删除文档和索引

```json
DELETE /member/external/2  // 删除文档
DELETE /member  // 删除索引
```

#### 批量导入

```json
POST /member/external/_bulk
{"index":{"_id":"1"}}
{"name":"Jay Huang"}
{"index":{"_id":"2"}}
{"name":"Jackson Huang"}
```

官方的测试数据： [elasticsearch/accounts.json at 7.5 · elastic/elasticsearch (github.com)](https://github.com/elastic/elasticsearch/blob/7.5/docs/src/test/resources/accounts.json)  拷贝之后在kibana中执行

```json
POST /bank/account/_bulk
{"index":{"_id":"1"}}
{"account_number":1,"balance":39225,"firstname":"Amber","lastname":"Duke","age":32,"gender":"M","address":"880 Holmes Lane","employer":"Pyrami","email":"amberduke@pyrami.com","city":"Brogan","state":"IL"}
{"index":{"_id":"6"}}
......
```

#### 查看索引

![image-20221116102537517](media/images/image-20221116102537517.png)

##### 索引统计

```json
GET twitter/_stats
GET twitter1,twitter2,twitter3/_stats
GET twitter*/_stats
```



### 高级查询用法

#### url后接参数

```json
GET bank/_search?q=*&sort=account_number: asc
```

查询出所有数据，共 1000 条数据，耗时 1ms，只展示 10 条数据 ( ES 分页 )

![image-20221116102827995](media/images/image-20221116102827995.png)

属性值说明

```json
took – ES 执行搜索的时间 ( 毫秒 )
timed_out – ES 是否超时
_shards – 有多少个分片被搜索了，以及统计了成功/失败/跳过的搜索的分片
max_score – 最高得分
hits.total.value - 命中多少条记录
hits.sort - 结果的排序 key 键，没有则按 score 排序
hits._score - 相关性得分
参考文档：
https://www.elastic.co/guide/en/elasticsearch/reference/current/getting-started-search.html
```

#### url加请求体，QueryDSL 语句

##### 全部匹配 match_all

```javascript
GET bank/_search
{
  "query": {
    "match_all": {}
  },
  "sort": [
    {
        "account_number": "asc"
    }
  ],
  "from": 10,
  "size": 10,
  "_source": ["balance", "account_number", "firstname"]
}
```

查询所有记录，按照 account_number 升序排序，只返回第 11 条记录到第 20 条记录，只显示 balance 和 firstname 字段和 account_number 字段。

##### 匹配查询 match

###### 基本类型 ( 非字符串 ) ，精确匹配

```json
GET bank/_search
{
  "query": {
    "match": {"account_number": "30"}
 }
}
```

###### 字符串，全文检索

```json
GET bank/_search 
{
  "query": {
    "match": {
      "address": "mill road"
    }
  },
  "from":0,
  "size": 3
}
```

全文检索按照评分进行排序，会对检索条件进行分词匹配。

查询 `address` 中包含 `mill` 或者 `road` 或者 `mill road` 的所有记录，并给出相关性得分。

查到了 32（value为32） 条记录，最高的一条记录是 Address = "990 Mill Road"，得分（_score）：8.926605. Address="198 Mill Lane" 评分 5.4032025，只匹配到了 Mill 单词。

```json
{
  "took" : 1,
  "timed_out" : false,
  "_shards" : {
    "total" : 1,
    "successful" : 1,
    "skipped" : 0,
    "failed" : 0
  },
  "hits" : {
    "total" : {
      "value" : 32,
      "relation" : "eq"
    },
    "max_score" : 8.926605,
    "hits" : [
      {
        "_index" : "bank",
        "_type" : "account",
        "_id" : "970",
        "_score" : 8.926605,
        "_source" : {
          "account_number" : 970,
          "balance" : 19648,
          "firstname" : "Forbes",
          "lastname" : "Wallace",
          "age" : 28,
          "gender" : "M",
          "address" : "990 Mill Road",
          "employer" : "Pheast",
          "email" : "forbeswallace@pheast.com",
          "city" : "Lopezo",
          "state" : "AK"
        }
      },
      {
        "_index" : "bank",
        "_type" : "account",
        "_id" : "136",
        "_score" : 5.4032025,
        "_source" : {
          "account_number" : 136,
          "balance" : 45801,
          "firstname" : "Winnie",
          "lastname" : "Holland",
          "age" : 38,
          "gender" : "M",
          "address" : "198 Mill Lane",
          "employer" : "Neteria",
          "email" : "winnieholland@neteria.com",
          "city" : "Urie",
          "state" : "IL"
        }
      },
      {
        "_index" : "bank",
        "_type" : "account",
        "_id" : "345",
        "_score" : 5.4032025,
        "_source" : {
          "account_number" : 345,
          "balance" : 9812,
          "firstname" : "Parker",
          "lastname" : "Hines",
          "age" : 38,
          "gender" : "M",
          "address" : "715 Mill Avenue",
          "employer" : "Baluba",
          "email" : "parkerhines@baluba.com",
          "city" : "Blackgum",
          "state" : "KY"
        }
      }
    ]
  }
}

```

##### 短语匹配 match_phase

将需要匹配的值当成一个整体单词 ( 不分词 ) 进行检索

```javascript
GET bank/_search
{
  "query": {
    "match_phrase": {
      "address": "mill road"
 	}
 }
}
```

查出 address 中包含 `mill road` 的所有记录，并给出相关性得分。

```json
{
  "took" : 73,
  "timed_out" : false,
  "_shards" : {
    "total" : 1,
    "successful" : 1,
    "skipped" : 0,
    "failed" : 0
  },
  "hits" : {
    "total" : {
      "value" : 1,
      "relation" : "eq"
    },
    "max_score" : 8.926605,
    "hits" : [
      {
        "_index" : "bank",
        "_type" : "account",
        "_id" : "970",
        "_score" : 8.926605,
        "_source" : {
          "account_number" : 970,
          "balance" : 19648,
          "firstname" : "Forbes",
          "lastname" : "Wallace",
          "age" : 28,
          "gender" : "M",
          "address" : "990 Mill Road",
          "employer" : "Pheast",
          "email" : "forbeswallace@pheast.com",
          "city" : "Lopezo",
          "state" : "AK"
        }
      }
    ]
  }
}
```

##### 复合查询 bool

复合语句可以合并任何其他查询语句，包括复合语句。复合语句之间可以相互嵌套，可以表达复杂的逻辑。

搭配使用 must,must_not,should

must: 必须达到 must 指定的条件。 ( 影响相关性得分 )

must_not: 必须不满足 must_not 的条件。 ( 不影响相关性得分 )

should: 如果满足 should 条件，则可以提高得分。如果不满足，也可以查询出记录。 ( 影响相关性得分 )

示例：查询出地址包含 mill，且性别为 M，年龄不等于 28 的记录，且优先展示 firstname 包含 Winnie 的记录。

```json
GET bank/_search
{
  "query": {
    "bool": {
      "must": [
        {
          "match": {
            "address": "mill"
          }
        },
        {
          "match": {
            "gender": "M"
          }
        }
      ],
      "must_not": [
        {
          "match": {
            "age": "28"
          }
        }
      ],
      "should": [
        {
          "match": {
            "firstname": "Winnie"
          }
        }
      ]
    }
  }
}
```

结果：

```json
{
  "took" : 157,
  "timed_out" : false,
  "_shards" : {
    "total" : 1,
    "successful" : 1,
    "skipped" : 0,
    "failed" : 0
  },
  "hits" : {
    "total" : {
      "value" : 2,
      "relation" : "eq"
    },
    "max_score" : 12.585751,
    "hits" : [
      {
        "_index" : "bank",
        "_type" : "account",
        "_id" : "136",
        "_score" : 12.585751,
        "_source" : {
          "account_number" : 136,
          "balance" : 45801,
          "firstname" : "Winnie",
          "lastname" : "Holland",
          "age" : 38,
          "gender" : "M",
          "address" : "198 Mill Lane",
          "employer" : "Neteria",
          "email" : "winnieholland@neteria.com",
          "city" : "Urie",
          "state" : "IL"
        }
      },
      {
        "_index" : "bank",
        "_type" : "account",
        "_id" : "345",
        "_score" : 6.0824604,
        "_source" : {
          "account_number" : 345,
          "balance" : 9812,
          "firstname" : "Parker",
          "lastname" : "Hines",
          "age" : 38,
          "gender" : "M",
          "address" : "715 Mill Avenue",
          "employer" : "Baluba",
          "email" : "parkerhines@baluba.com",
          "city" : "Blackgum",
          "state" : "KY"
        }
      }
    ]
  }
}
```

##### filter 过滤

不影响相关性得分，查询出满足 filter 条件的记录。在 bool 中使用。

```json
GET bank/_search
{
  "query": {
    "bool": {
      "filter": [
        {
          "range": {
            "age": {
              "gte": 18,
              "lte": 30
            }
          }
        }
      ]
    }
  }
}
```

##### term查询

匹配某个属性的值。

全文检索字段用 match，其他非 text 字段匹配用 term

keyword：文本精确匹配 ( 全部匹配 )

match_phase：文本短语匹配

```json
非 text 字段精确匹配
GET bank/_search
{
  "query": {
    "term": {
      "age": "20"
 }
 }
}
```

##### 聚合操作 aggregations

聚合：从数据中分组和提取数据。类似于 SQL GROUP BY 和 SQL 聚合函数。

Elasticsearch 可以将命中结果和多个聚合结果同时返回。

语法

```json
"aggregations" : {
    "<聚合名称 1>" : {
        "<聚合类型>" : {
            <聚合体内容>
        }
        [,"元数据" : {  [<meta_data_body>] }]?
        [,"aggregations" : { [<sub_aggregation>]+ }]?
    }
    [,"聚合名称 2>" : { ... }]*
}
```

- 示例 1：搜索 address 中包含 mill 的所有人的年龄分布 ( 前 10 条 ) 以及平均年龄，以及平均薪资

```json
GET bank/_search
{
  "query": {
    "match": {
      "address": "mill"
 }
  },
  "aggs": {
    "ageAggr": {
      "terms": {
        "field": "age",
        "size": 10
       }
    },
    "ageAvg": {
      "avg": {
        "field": "age"
      }
    },
    "balanceAvg": {
      "avg": {
        "field": "balance"
      }
   }
 }
}
```

![image-20221116105239587](media/images/image-20221116105239587.png)

- 示例 2：按照年龄聚合，并且查询这些年龄段的平均薪资

```json
GET bank/_search
{
  "query": {
    "match_all": {}
  },
  "aggs": {
    "ageAggr": {
      "terms": {
        "field": "age",
        "size": 10
      },
      "aggs": {
        "ageAvg": {
          "avg": {
          "field": "balance"
        }
        }
      }
    }
  }
}
```

从结果可以看到 31 岁的有 61 个，平均薪资 28312.9，其他年龄的聚合结果类似

![image-20221116115245776](media/images/image-20221116115245776.png)

- 示例 3：按照年龄分组，然后将分组后的结果按照性别分组，然后查询出这些分组后的平均薪资

```json
GET bank/_search
{
  "query": {
    "match_all": {
 }
  },
  "aggs": {
    "ageAggr": {
      "terms": {
        "field": "age",
        "size": 10
      },
      "aggs": {
        "genderAggr": {
          "terms": {
            "field": "gender.keyword",
            "size": 10
          },
          "aggs": {
            "balanceAvg": {
              "avg": {
                "field": "balance"
          }
        }
      }
    }
  }
 }
  },
  "size": 0
}
```

从结果可以看到 31 岁的有 61 个。其中性别为 `M` 的 35 个，平均薪资 29565.6，性别为 `F` 的 26 个，平均薪资 26626.6。其他年龄的聚合结果类似。

![image-20221116115352639](media/images/image-20221116115352639.png)

##### Mapping 映射

Mapping 是用来定义一个文档 ( document ) ，以及它所包含的属性 ( field ) 是如何存储和索引的。

- 定义哪些字符串属性应该被看做全文本属性 ( full text fields )
- 定义哪些属性包含数字，日期或地理位置
- 定义文档中的所有属性是否都能被索引 ( _all 配置 )
- 日期的格式
- 自定义映射规则来执行动态添加属性

Elasticsearch7 去掉 tpye 概念：

关系型数据库中两个数据库表示是独立的，即使他们里面有相同名称的列也不影响使用，但 ES 中不是这样的。elasticsearch 是基于 Lucence 开发的搜索引擎，而 ES 中不同 type 下名称相同的 field 最终在 Lucence 中的处理方式是一样的。

为了区分不同 type 下的同一名称的字段，Lucence 需要处理冲突，导致检索效率下降

ES7.x 版本：URL 中的 type 参数为可选。

ES8.x 版本：不支持 URL 中的 type 参数

###### 数据类型

![image-20240312162816680](media/images/image-20240312162816680.png)

所有类型可以参考文档：https://www.elastic.co/guide/en/elasticsearch/reference/current/mapping-types.html

可以参考  [ElasticSearch 23 种映射参数详解](https://juejin.cn/post/6901852757137817614)

为了在索引中获得更好的结果和性能，我们有时需要需要手动定义映射。 微调映射带来了一些优势，例如：

- 减少磁盘上的索引大小（禁用自定义字段的功能）
- 仅索引感兴趣的字段（一般加速）
- 用于快速搜索或实时分析（例如聚合）
- 正确定义字段是否必须分词为多个 token 或单个 token
- 定义映射类型，例如地理点、suggester、向量等

###### 创建索引并指定映射

如创建 my-index 索引，有三个字段 age,email,name，指定类型为 interge, keyword, text

```json
PUT /my-test-index
{
  "mappings": {
    "properties": {
      "age": {
        "type": "integer"
      },
      "email": {
        "type": "keyword"
      },
      "name": {
        "type": "text"
      }
    }
  }
}
```

###### 查看索引的映射

```json
GET /my-index/_mapping
返回结果：
{
  "my-index" : {
    "mappings" : {
      "properties" : {
        "age" : {
          "type" : "integer"
        },
        "email" : {
          "type" : "keyword"
        },
        "employee-id" : {
          "type" : "keyword",
          "index" : false
        },
        "name" : {
          "type" : "text"
      }
    }
  }
 }
}
```

###### 得到某个字段的映射

```json
GET twitter/_mapping/field/city

{
  "twitter" : {
    "mappings" : {
      "city" : {
        "full_name" : "city",
        "mapping" : {
          "city" : { // 这是一个multi-field字段
            "type" : "text",
            "fields" : {
              "keyword" : {
                "type" : "keyword",
                "ignore_above" : 256
              }
            }
          }
        }
      }
    }
  }
}
```

比如在上面，我们定义字段 city 为 [text](https://www.elastic.co/guide/en/elasticsearch/reference/current/text.html) 类型。text 类型的数据在摄入的时候会分词，这样它可以实现搜索的功能。同时，这个字段也被定义为 [keyword](https://www.elastic.co/guide/en/elasticsearch/reference/current/keyword.html) 类型的数据。这个类型的数据可以让我们针对它进行精确匹配（比如区分大小写，空格等符号），聚合和排序。其实，上面的第一个 keyword 可以是你定义的任何词，而第二个 keyword 才是它的类型定义。比如，我们可以这样来定义这个字段：

```json
"city" : {
    "type" : "text",
    "fields" : {
        "raw" : {
            "type" : "keyword",
            "ignore_above" : 256
        }
    }
}
```



###### 添加新的字段映射

如在 my-index 索引里面添加 employ-id 字段，指定类型为 keyword

```json
PUT /my-index/_mapping
{
  "properties": {
    "employee-id": {
      "type": "keyword",
      "index": false
    }
 }
}
```

###### 更新映射

我们不能更新已经存在的映射字段，必须创建新的索引进行数据迁移。

###### 数据迁移

```json
POST _reindex
{
  "source": {
    "index": "twitter"
  },
  "dest": {
    "index": "new_twitter"
 }
}
```

#### 创建索引，添加定制的分析器

```sh
PUT /my-analyzer-index 
{
  "settings": {
    "number_of_shards": 2,
    "number_of_replicas": 1,
    "index" : {
      "analysis": {
        "analyzer":  {
          "myCustomAnalyzer": {
            "type": "custom",
            "tokenizer": "myCustomTokenizer",
            "filter" :["myCustomFilter1", "myCustomFilter2"],
            "char_filter": ["myCustomCharFilter"]
          }
        },
        "tokenizer": {
          "myCustomTokenizer": {
            "type": "letter"
          }
        },
        "filter": {
          "myCustomFilter1": {
            "type": "lowercase"
          },
          "myCustomFilter2": {
            "type": "kstem"
          }
        },
        "char_filter": {
          "myCustomCharFilter": {
            "type": "mapping",
            "mappings": ["ph=>f", "u=>you"]
          }
        }
      }
    }
  }
}
```

返回的结果：

```sh
{
  "acknowledged" : true,
  "shards_acknowledged" : true,
  "index" : "my-analyzer-index"
}
```

查看 setting

```sh
GET my-analyzer-index/_settings

{
  "my-analyzer-index" : {
    "settings" : {
      "index" : {
        "number_of_shards" : "2",
        "provided_name" : "my-analyzer-index",
        "creation_date" : "1679818880880",
        "analysis" : {
          "filter" : {
            "myCustomFilter1" : {
              "type" : "lowercase"
            },
            "myCustomFilter2" : {
              "type" : "kstem"
            }
          },
          "char_filter" : {
            "myCustomCharFilter" : {
              "type" : "mapping",
              "mappings" : [
                "ph=>f",
                "u=>you"
              ]
            }
          },
          "analyzer" : {
            "myCustomAnalyzer" : {
              "filter" : [
                "myCustomFilter1",
                "myCustomFilter2"
              ],
              "char_filter" : [
                "myCustomCharFilter"
              ],
              "type" : "custom",
              "tokenizer" : "myCustomTokenizer"
            }
          },
          "tokenizer" : {
            "myCustomTokenizer" : {
              "type" : "letter"
            }
          }
        },
        "number_of_replicas" : "1",
        "uuid" : "nnbgakhJRf6I9ADBUsf7OQ",
        "version" : {
          "created" : "7060299"
        }
      }
    }
  }
}
```

还可以在配置中添加自定义的分析器，在elasticsearch.yml 中。

然后在映射中为某个字段指定特定的分词器：

```sh
PUT my_index/_mapping/my_type
{
  "properties": {
    "content":{
      "type": "text",
      "analyzer": "my_analyzer"
    }
  }
}
```

使用自定义的分析器分析语句：

```sh
POST my-analyzer-index/_analyze
{
  "analyzer": "myCustomAnalyzer", 
  "text":"share your experience with nosql & big data technologies"
}
```

结果：

```sh
{
  "tokens" : [
    {
      "token" : "share",
      "start_offset" : 0,
      "end_offset" : 5,
      "type" : "word",
      "position" : 0
    },
    {
      "token" : "yoyour",
      "start_offset" : 6,
      "end_offset" : 10,
      "type" : "word",
      "position" : 1
    },
    {
      "token" : "experience",
      "start_offset" : 11,
      "end_offset" : 21,
      "type" : "word",
      "position" : 2
    },
    {
      "token" : "with",
      "start_offset" : 22,
      "end_offset" : 26,
      "type" : "word",
      "position" : 3
    },
    {
      "token" : "nosql",
      "start_offset" : 27,
      "end_offset" : 32,
      "type" : "word",
      "position" : 4
    },
    {
      "token" : "big",
      "start_offset" : 35,
      "end_offset" : 38,
      "type" : "word",
      "position" : 5
    },
    {
      "token" : "data",
      "start_offset" : 39,
      "end_offset" : 43,
      "type" : "word",
      "position" : 6
    },
    {
      "token" : "technology",
      "start_offset" : 44,
      "end_offset" : 56,
      "type" : "word",
      "position" : 7
    }
  ]
}
```

