### elasticsearch

> [14.Elasticsearch上篇（原理） (passjava.cn)](http://www.passjava.cn/#/01.PassJava/02.PassJava_Architecture/14.Elasticsearch原理.md) 

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

#### 使用 Dev Tools 来创建索引

es的测试数据地址： [elasticsearch/accounts.json at 7.5 · elastic/elasticsearch (github.com)](https://github.com/elastic/elasticsearch/blob/7.5/docs/src/test/resources/accounts.json) 

命令：

```sh
POST /bank/account/_bulk
{"index":{"_id":"1"}}
{"account_number":1,"balance":39225,"firstname":"Amber","lastname":"Duke","age":32,"gender":"M","address":"880 Holmes Lane","employer":"Pyrami","email":"amberduke@pyrami.com","city":"Brogan","state":"IL"}
{"index":{"_id":"6"}}
......
```

### 中文分词

[Release v7.6.2 · medcl/elasticsearch-analysis-ik (github.com)](https://github.com/medcl/elasticsearch-analysis-ik/releases/tag/v7.6.2) 

下载中文分词器，ik分词器