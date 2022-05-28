#### 1 条件化简

我们编写的查询语句的搜索条件本质上是一个表达式，这些表达式可能比较繁杂，或者不能高效的执行， MySQL的查询优化器会为我们简化这些表达式。为了方便大家理解，我们后边举例子的时候都使用诸如 a 、 b 、 c 之类的简单字母代表某个表的列名。

##### 1.1 移除不必要的括号

有时候表达式里有许多无用的括号，比如这样：  

`((a = 5 AND b = c) OR ((a > c) AND (c < 5)))  `

优化器会把用不上的括号给干掉，就是这样：

`(a = 5 AND b = c) OR (a > c AND c < 5)  `

##### 1.2 常量传递 

有时候某个表达式是某个列和某个常量做等值匹配，比如这样：  a = 5  

当这个表达式和其他涉及列 a 的表达式使用 AND 连接起来时，可以将其他表达式中的 a 的值替换为 5 ，比如这样 ：a = 5 AND b > a   就可以转换成 a=5 AND b >5;

##### 1.3 等值传递 

a = b and b = c and c = 5  可以简化为 a = 5 and b = 5 and c = 5  ；

##### 1.4 移除没用的条件 

对于一些明显永远为 TRUE 或者 FALSE 的表达式，优化器会移除掉它们，比如这个表达式：  

(a < 1 and b = b) OR (a = 6 OR 5 != 5)   很明显 b=b这个永远为 TRUE，5 != 5 这个表达式永远为 FALSE ，所以简化后的表达式就是这样的：(a < 1 and TRUE) OR (a = 6 OR FALSE)  ，继续简化为 a < 1 OR a = 6  。

##### 1.5 表达式计算 

在查询开始执行之前，如果表达式中只包含常量的话，它的值会被先计算出来，比如这个：

a=5+1 ，会被简化成 a=6。

但是这里需要注意的是，如果某个列并不是以单独的形式作为表达式的操作数时，比如出现在函数中，出现在某个更复杂表达式中，就像这样  ：

ABS(a) > 5，**优化器是不会尝试对这些表达式进行化简的**。所以如果可以的话，**最好让索引列以单独的形式出现在表达式中**  。

##### 1.6 HAVING 子句和WHERE 子句的合并 

如果查询语句中没有出现诸如 SUM 、 MAX 等等的聚集函数以及 GROUP BY 子句，优化器就把 HAVING 子句和WHERE 子句合并起来  。

##### 1.7 常量表检测 

- 查询的表中一条记录没有，或者只有一条记录  
- 使用主键等值匹配或者唯一二级索引列等值匹配作为搜索条件来查询某个表 。

设计 MySQL 的大叔觉得这两种查询花费的时间特别少，少到可以忽略，所以也把**通过这两种方式查询的表称之为 常量表 （英文名： constant tables ）**。**优化器在分析一个查询语句时，先首先执行常量表查询，然后把查询中涉及到该表的条件全部替换成常数，最后再分析其余表的查询成本**，比方说这个查询语句：
 `SELECT * FROM table1 INNER JOIN table2 ON table1.column1 = table2.column2 WHERE table1.primary_key = 1;  `

很明显，这个查询可以使用主键和常量值的等值匹配来查询 table1 表，也就是在这个查询中 table1 表相当于常量表 ，在分析对 table2 表的查询成本之前，就会执行对 table1 表的查询，并把查询中涉及 table1 表的条件都替换掉，也就是上边的语句会被转换成这样：  

`SELECT table1表记录的各个字段的常量值, table2.* FROM table1 INNER JOIN table2
ON table1表column1列的常量值 = table2.column2;  ` 

#### 2 外连接消除

我们前边说过， 内连接 的驱动表和被驱动表的位置可以相互转换，而 左（外）连接 和 右（外）连接 的驱动表和被驱动表是固定的。这就导致 内连接 可能通过优化表的连接顺序来降低整体的查询成本而 外连接 却无法优化表的连接顺序。

我们把这种**在外连接查询中，指定的 WHERE 子句中包含被驱动表中的列不为 NULL 值的条件称之为 空值拒绝（英文名： reject-NULL ）**。在被驱动表的WHERE子句符合空值拒绝的条件后，外连接和内连接可以相互转换。这种转换带来的好处就是查询优化器可以通过评估表的不同连接顺序的成本，选出成本最低的那种连接顺序来执行查询。  

`SELECT * FROM t1 LEFT JOIN t2 ON t1.m1 = t2.m2;  `

查询结果：

```mysql
+------+------+------+------+
| m1 | n1 | m2 | n2 |
+------+------+------+------+
| 2 | b | 2 | b |
| 3 | c | 3 | c |
| 1 | a | NULL | NULL |
+------+------+------+------+
```

优化：`SELECT * FROM t1 LEFT JOIN t2 ON t1.m1 = t2.m2 WHERE t2.n2 IS NOT NULL; ` 

或者指定一个不为null的值， `SELECT * FROM t1 LEFT JOIN t2 ON t1.m1 = t2.m2 WHERE t2.m2 = 2  `。也就等价于了：`SELECT * FROM t1 INNER JOIN t2 ON t1.m1 = t2.m2 WHERE t2.m2 = 2; `

```mysql
+------+------+------+------+
| m1 | n1 | m2 | n2 |
+------+------+------+------+
| 2 | b | 2 | b |
| 3 | c | 3 | c |
+------+------+------+------+
```

#### 3 子查询优化 

- select 语句中

  `SELECT (SELECT m1 FROM t1 LIMIT 1);  ` 第二个select语句

- from 语句中

  `SELECT m, n FROM (SELECT m2 + 1 AS m, n2 AS n FROM t2 WHERE m2 > 2) AS t;  ` 括号内的 select 语句。

- WHERE 或 ON 子句中

  `SELECT * FROM t1 WHERE m1 IN (SELECT m2 FROM t2); `

- ORDER BY 子句中
- GROUP BY 子句中

##### 3.1 按返回的结果集区分子查询 

因为子查询本身也算是一个查询，所以可以按照它们返回的不同结果集类型而把这些子查询分为不同的类型 ：

- 标量子查询

  那些只返回一个单一值的子查询称之为 标量子查询 ，比如这样：  

  SELECT (SELECT m1 FROM t1 LIMIT 1);  

  这个查询语句中的**子查询都返回一个单一的值，也就是一个 标量** 。这些**标量子查询可以作为一个单一值或者表达式的一部分出现在查询语句的各个地方**。  

- 行子查询

  顾名思义，就是返回一条记录的子查询，不过这条记录需要包含多个列 。

  SELECT * FROM t1 WHERE (m1, n1) = (SELECT m2, n2 FROM t2 LIMIT 1); 

- 列子查询

  列子查询自然就是查询出一个列的数据喽，不过这个列的数据需要包含多条记录。

  SELECT * FROM t1 WHERE m1 IN (SELECT m2 FROM t2); 

  其中的 (SELECT m2 FROM t2) 就是一个列子查询，表明查询出 t2 表的 m2 列的值作为外层查询 IN 语句的参数。   

- 表子查询  

  顾名思义，就是子查询的结果既包含很多条记录，又包含很多个列  

  SELECT * FROM t1 WHERE (m1, n1) IN (SELECT m2, n2 FROM t2);

  其中的 (SELECT m2, n2 FROM t2) 就是一个表子查询，这里需要和行子查询对比一下，行子查询中我们用了 LIMIT 1 来保证子查询的结果只有一条记录，表子查询中不需要这个限制。

。。。

##### 3.2 子查询在 MySQL 中是怎么执行的

还是之前的表 single_table

```mysql
CREATE TABLE single_table ( 
	id INT NOT NULL AUTO_INCREMENT, 
	key1 VARCHAR(100), 
	key2 INT, 
	key3 VARCHAR(100), 
	key_part1 VARCHAR(100), 
	key_part2 VARCHAR(100), 
	key_part3 VARCHAR(100), 
	common_field VARCHAR(100), 
	PRIMARY KEY (id), 
	KEY idx_key1 (key1), 
	UNIQUE KEY idx_key2 (key2), 
	KEY idx_key3 (key3), 
	KEY idx_key_part(key_part1, key_part2, key_part3) 
) Engine = InnoDB CHARSET = utf8;
-- 插入数据
CREATE PROCEDURE single_table_procedure()
BEGIN 
  declare i int;
  set i=1;
  while(i<=10000)do
    insert into single_table(key1,key2,key3,key_part1,key_part2,key_part3) 
    values(CONCAT("ab", i), i+1, CONCAT("bc",i), CONCAT("ab",CONCAT(i,"c")), CONCAT("bb", i+1), CONCAT("bc",CONCAT(i,"d")));
    set i=i+1;
  end while;
END;
```

