### MySQL 语句执行顺序 

参考：[Mysql, SQL statement execution order - Programmer All](https://www.programmerall.com/article/46272084291/) 

#### 1 SQL 语句执行顺序

```mysql
select  Candidate name, max(Overall result)  as  MAX total score 
from tb_Grade 
where  Candidate name is not null 
group by  Candidate name 
having max(Overall result)  > 600 
order by  MAX total score
```

（1）首先执行  FROM 子句，从TB_GRADE表组装数据源。

（2）执行 WHERE 子句，过滤所有表 TB_GRADE 中 is not null 的数据。

（3）执行 GROUP BY 子句，通过 Candidate name 列打包表 TB_GRADE 的数据。

（4）执行 max() 聚合函数，按“总分数”以找到总分中最大的值。

（5）执行 SELECT 语句，选择 candidate name 和 total score的统计信息和给别名。

（6）执行 ORDER BY 语句，通过 max total score 排序结果。

#### 2 有子查询的执行顺序 

##### 2.1 不依赖父查询的语句

```mysql
SELECT Sno，Sname，Sdept FROM Student WHERE SdeptIN (SELECTSdept FROM Student WHERE SNAME = Liu Chen);
```

子查询的查询条件不依赖于外部处理的父查询。也就是说，每个子查询在先前的查询处理之前解决，子查询结果用于建立其父查询的查找条件。

##### 2.2 依赖父查询的语句

子查询的查询条件依赖父查询，先第一个外查询的元组,根据处理内层查询与内部相关的属性值查询如果WHERE子句返回值是正确的,然后把这包结果表,然后将第二外层表的元组,重复此过程，直到完全检查外部表。

> The query conditions of the child depend on the father's query, first take The first tuple of the outer query, according to It, processes the inner layer query with the attribute value related to the inner query .If the WHERE clause return value is true, then take this packet into the result table, then take the next tuple of the outer layer table, repeat this process until the outer table is completely checke

```mysql
Query the student number and name of the course name "Information System"

SELECT Sno，Sname 
FROM  STUDENT 3 finally removes SNO and SNAME in the Student relationship
WHERE Sno  IN
       ( SELECT  SNO 2 and then find the student number of the 11th course in the SCI

                FROM    SC
                WHERE  Cno IN
                     ( SELECT Cno 
                       FROM Course
                       WHERE Cname=  'Information System' 1 First Find the "Information System" course number in the Course relationship, resulting in a course 3

                     )
              );
```

#### 3 表连接的执行顺序

First find the first tuple in Table 1, then start scanning table 2 from the head, find a tuple that meets the connector one by one, and then find the first tuning in Table 1 and the tuple, forming the result One tuple in the table.
After all of the table 2, then find the second tuple in Table 1, then start scanning table 2 from the beginning, find a tuple that meets the connection conditions one by one, and find the second tuple in Table 1 and the The tuples are spliced to form a tuple in the results table.
Repeat the above operation until all the tabs in Table 1 are processed