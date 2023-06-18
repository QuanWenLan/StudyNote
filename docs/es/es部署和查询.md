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

### 查询语法

#### _cat 用法 

```json
GET /_cat/nodes: 查看所有节点
GET /_cat/health: 查看 es 健康状况
GET /_cat/master: 查看主节点
GET /_cat/indices: 查看所有索引

查询汇总：
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

#### 索引一个文档

PUT 和 POST 都可以创建记录。

POST：如果不指定 id，自动生成 id。如果指定 id，则修改这条记录，并新增版本号。

PUT：必须指定 id，如果没有这条记录，则新增，如果有，则更新。

```json
PUT member/external/1
{
"name":"jay huang"
}
返回值
{
    "_index": "member", //在哪个索引
    "_type": "external",//在那个类型
    "_id": "2",//记录 id
    "_version": 7,//版本号
    "result": "updated",//操作类型
    "_shards": {
        "total": 2,
        "successful": 1,
        "failed": 0
    },
    "_seq_no": 9,
    "_primary_term": 1
}
```

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
查询所有的
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

如果更新的文档不存在时，可以使用upsert。

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



#### 删除文档和索引

```json
DELETE /member/external/2  // 删除文档
DELETE /member  // 删除所以
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

##### 查看索引索引

![image-20221116102537517](media/images/image-20221116102537517.png)

### 高级查询用法

#### url后接参数

```json
GET bank/_search?q=*&sort=account_number: asc
```

查询出所有数据，共 1000 条数据，耗时 1ms，只展示 10 条数据 ( ES 分页 )

![image-20221116102827995](media/images/image-20221116102827995.png)

属性值说明

```javascript
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

所有类型可以参考文档：https://www.elastic.co/guide/en/elasticsearch/reference/current/mapping-types.html

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

