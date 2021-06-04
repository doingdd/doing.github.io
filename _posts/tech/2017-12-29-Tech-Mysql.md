---
layout: post
category: 技术
title: MySQL基本概念
---

**本文介绍MySQL的基本概念，包括关系型/非关系型数据库的区别，InnoDB的介绍，索引机制，锁机制，mysql数据类型和约束等概念。**    

参考： [w3school](http://www.w3school.com.cn/sql/index.asp)  
[知乎](https://www.zhihu.com/question/24225007/answer/81501685)   


# MySQL

MySQL是一个流行的关系型数据库，属于Oracle旗下(但和Oracle数据库不一样)，使用通用的SQL语句。   
MySQL有社区办和商业版，社区版开源。  

## 1. 关系型和非关系型数据库

这里简单总结一下关系型和非关系型数据库的区别有优劣对比。  
非关系型数据库的优势：  
1. 性能NOSQL是基于键值对的，可以想象成表中的主键和值的对应关系，而且不需要经过SQL层的解析，所以性能非常高。  
2. 可扩展性同样也是因为基于键值对，数据之间没有耦合性，所以非常容易水平扩展。  

关系型数据库的优势：  
1. 复杂查询可以用SQL语句方便的在一个表以及多个表之间做非常复杂的数据查询。  
2. 事务支持使得对于安全性能很高的数据访问要求得以实现。对于这两类数据库，对方的优势就是自己的弱势，反之亦然。 

来源：[知乎](https://www.zhihu.com/question/24225007/answer/81501685)

## 2. MySQL的存储引擎：InnoDB 和 MyISAM

参考来源：   
[MySQL存储引擎－－MyISAM与InnoDB区别](http://blog.csdn.net/xifeijian/article/details/20316775)    
[官网-InnoDB instruction](https://dev.mysql.com/doc/refman/5.7/en/innodb-introduction.html)   
[MySQL--锁](http://blog.csdn.net/xifeijian/article/details/20313977)   

InnoDB是MySQL 5.7的默认引擎，如果在CREATE TABLE是不指定ENGINE=，则使用的就是InnoDB。  
InnoDB的优势简单总结：  

**行级锁：** 以record行为单位加锁，在MySQL中有表级锁，行级锁和页面锁，行级锁是InnoDB特有的，同时它也支持表级锁。从粒度上区分，有行锁，表锁，从锁的功能上区分则有共享锁(S)和排他锁(X)，还有InnoDB为了同时支持行锁和表锁而建立的意向共享锁(IS)和意向排他锁(IX)。  

**事务处理：** 事务(transaction)是由一组SQL语句组成的数据处理单元，具备四个属性，也叫ACID属性：A(Atomicity)指原子性，即事务作为一个最小执行单元，要么全部执行，要么全部不执行；C(Consistent)一致性，事务开始和完成时数据必须保持一致性和完整性，结构不发生变化；I(Isolation)隔离，事务执行时不能受其他并发事务的影响，数据库提供隔离机制；D(Durable)持久性，事务完成后，数据的修改是持久的，即使系统故障也能保持。  

**外键：**  Foreign Key机制保证了在不同表之间的增删改查的时候数据的一致性。  

关于锁和事务处理机制的解释可以**参考**这篇文章[MySQL--锁](http://blog.csdn.net/xifeijian/article/details/20313977)   
 
**注意： ** InnoDB的行锁实际上仅在where选取的域是其主键时有效，其他情况仍然是表锁。  

## 3. 索引

来源：[百度百科-MySQL](https://baike.baidu.com/item/mySQL/471251?fr=aladdin) 
[细说mysql索引](https://www.cnblogs.com/chenshishuo/p/5030029.html)  
[理解mysql索引与优化](https://www.cnblogs.com/hustcat/archive/2009/10/28/1591648.html)  
 

索引是一种特殊的文件（InnoDB 数据表上的索引是表空间的一个组成部分），它们包含着对数据表里所有记录的引用指针。索引不是万能的，索引可以加快数据检索操作，但会使数据修改操作变慢。每修改数据记录，索引就必须刷新一次。为了在某种程度上弥补这一缺陷，许多 SQL 命令都有一个 DELAY_KEY_WRITE 项。这个选项的作用是暂时制止 MySQL 在该命令每插入一条新记录和每修改一条现有之后立刻对索引进行刷新，对索引的刷新将等到全部记录插入/修改完毕之后再进行。

MySQL的索引分为**单列索引(主键索引，唯一索引，普通索引)** 和**组合索引**。  
### 主键索引

主键索引**不允许有空的值**，而且，在InnoDB引擎中，主键索引是用来实现行锁的，出于效率方面的考虑，InnoDB 数据表的数据行级锁定实际发生在它们的索引上，而不是数据表自身上。显然，数据行级锁定机制只有在有关的数据表有一个合适的索引可供锁定的时候才能发挥效力。  

主键索引的创建(将字段定义为主键或加上主键约束，它就会自动变成主键索引)：  
```python
CREATE TABLE `award` (
   `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '用户id',
   `aty_id` varchar(100) NOT NULL DEFAULT '' COMMENT '活动场景id',
   `nickname` varchar(12) NOT NULL DEFAULT '' COMMENT '用户昵称',
   `is_awarded` tinyint(1) NOT NULL DEFAULT 0 COMMENT '用户是否领奖',
   `award_time` int(11) NOT NULL DEFAULT 0 COMMENT '领奖时间',
   `account` varchar(12) NOT NULL DEFAULT '' COMMENT '帐号',
   `password` char(32) NOT NULL DEFAULT '' COMMENT '密码',
   `message` varchar(255) NOT NULL DEFAULT '' COMMENT '获奖信息',
   `created_time` int(11) NOT NULL DEFAULT 0 COMMENT '创建时间',
   `updated_time` int(11) NOT NULL DEFAULT 0 COMMENT '更新时间',
   PRIMARY KEY (`id`)
 ) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COMMENT='获奖信息表';
```

### 唯一索引  
唯一索引,与普通索引类似,但是不同的是唯一索引要求所有的类的值是唯一的,这一点和主键索引一样.但是他**允许有空值**。 

唯一索引的创建：
```python
CREATE UNIQUE INDEX account_UNIQUE_Index ON award(account);
```

### 普通索引

普通索引,这个是最基本的索引。  

其sql格式是 
`CREATE INDEX IndexName ON TableName(列名 (length))` 或者 `ALTER TABLE TableName ADD INDEX IndexName(列名 (length))`

第一种方式 :
```python
  CREATE INDEX account_Index ON award(account);
```
第二种方式: 
```python
ALTER TABLE award ADD INDEX account_Index(account)
```
### 组合索引

一个表中含有多个单列索引不代表是组合索引,通俗一点讲 组合索引是:包含多个字段但是只有索引名称

其sql格式是 CREATE INDEX IndexName On TableName(字段名 (length),字段名 (length),...);

```python
 CREATE INDEX mix_index ON award(nickname, account, created_time);
```
如果你建立了 组合索引(nickname_account_createdTime_Index) 那么他实际包含的是3个索引 (nickname) (nickname,account)(nickname,account,created_time)

在使用查询的时候遵循mysql组合索引的"最左前缀",下面我们来分析一下 什么是最左前缀:及索引where时的条件要按照建立索引的时候字段的排序方式

1、不按索引最左列开始查询（多列索引） 例如index(‘c1’, ‘c2’, ‘c3’) where ‘c2’ = ‘aaa’ 不使用索引,`where c2 = 'aaa' and c3='sss'` 不能使用索引

2、查询中某个列有范围查询，则其右边的所有列都无法使用查询（多列查询）

Where c1= ‘xxx’ and c2 like = ‘aa%’ and c3=’sss’ 改查询只会使用索引中的前两列,因为like是范围查询

3、不能跳过某个字段来进行查询,这样利用不到索引,比如我的sql 是 

explain select * from `award` where nickname > 'rSUQFzpkDz3R' and account = 'DYxJoqZq2rd7' and created_time = 1449567822; 那么这时候他使用不到其组合索引.

因为我的索引是 (nickname, account, created_time),如果第一个字段出现 **范围符号的查找**,那么将不会用到索引,如果我是第二个或者第三个字段使用范围符号的查找,那么他会利用索引,利用的索引是(nickname)

### 全文索引

文本字段上(text)如果建立的是普通索引,那么只有对文本的字段内容前面的字符进行索引,其字符大小根据索引建立索引时申明的大小来规定.

如果文本中出现多个一样的字符,而且需要查找的话,那么其条件只能是 where column like '%xxxx%' 这样做会让索引失效

.这个时候全文索引就祈祷了作用了
```python
ALTER TABLE tablename ADD FULLTEXT(column1, column2)
```
有了全文索引，就可以用SELECT查询命令去检索那些包含着一个或多个给定单词的数据记录了。
```python
SELECT * FROM tablename
WHERE MATCH(column1, column2) AGAINST(‘xxx′, ‘sss′, ‘ddd′)
```
这条命令将把column1和column2字段里有xxx、sss和ddd的数据记录全部查询出来。  

### 索引的失效条件
参考：[哪些情况下索引会失效](https://www.cnblogs.com/hongfei/archive/2012/10/20/2732589.html)  

总结起来就是：  
1. 使用"or"关键字而且不是每一个or的条件域都带索引。  
2. 通配符在前面：where sth like "%name"。  
3. 组合索引，没有使用“最左前缀”。  
4. 字符串没有使用引号括起来。  

## 4. MySQL 数据类型

数据类型|大小(字节)|用途|格式
---|---|---|---
INT|4|整数| 
FLOAT|4|单精度浮点数
DOUBLE|4|双精度浮点数
ENUM|NA|单选,比如性别|ENUM('a','b','c')
SET|NA|多选|SET('1','2','3')
DATE|3|日期|YYYY-MM-DD
TIME|3|时间点或持续时间|HH: MM:SS
YEAR|1|年份值|YYYY
CHAR|0~255|定长字符串
VARCHAR|0~255|变长字符串
TEXT|0~65535|长文本数据

## 5. 约束

### 主键
主键 (PRIMARY KEY)是用于约束表中的一行，作为这一行的标识符，在一张表中通过主键就能准确定位到一行，因此主键十分重要。行中的主键不能有重复且不能为空。  

创建一个主键约束：
```python
mysql> alter table employee add constraint pk_id primary key(id);
Query OK, 0 rows affected (0.55 sec)
Records: 0  Duplicates: 0  Warnings: 0

mysql> desc employee;
+--------+---------------+------+-----+---------+-------+
| Field  | Type          | Null | Key | Default | Extra |
+--------+---------------+------+-----+---------+-------+
| id     | int(10)       | NO   | PRI | 0       |       |
| name   | varchar(20)   | YES  |     | NULL    |       |
| gender | enum('F','M') | YES  |     | NULL    |       |
+--------+---------------+------+-----+---------+-------+
3 rows in set (0.00 sec)

```
### 默认值约束
默认值约束 (DEFAULT) 规定，当有 DEFAULT 约束的列，插入数据为空时，将使用默认值。


### 唯一约束
唯一约束 (UNIQUE) 比较简单，它规定一张表中指定的一列的值必须不能有重复值，即这一列每个值都是唯一的。   

创建唯一约束：
```python
mysql> alter table employee add constraint uq_name unique(name);
Query OK, 0 rows affected (0.05 sec)
Records: 0  Duplicates: 0  Warnings: 0

mysql> desc employee;
+--------+---------------+------+-----+---------+-------+
| Field  | Type          | Null | Key | Default | Extra |
+--------+---------------+------+-----+---------+-------+
| id     | int(10)       | NO   | PRI | 0       |       |
| name   | varchar(20)   | YES  | UNI | NULL    |       |
| gender | enum('F','M') | YES  |     | NULL    |       |
+--------+---------------+------+-----+---------+-------+
3 rows in set (0.00 sec)
```
### 检查约束
检查约束(check constraint)，某列取值范围限制，格式限制等等，例如年龄：
```python
mysql> alter table employee add constraint ck_name check(name='yidu' or name='hei');
mysql> alter table employee add constraint ck_age check(age between 1 and 100);
```
### 外键约束
外键 (FOREIGN KEY) 既能确保数据完整性，也能表现表之间的关系。
一个表可以有多个外键，每个外键必须 REFERENCES (参考) 另一个表的主键，被外键约束的列，取值必须在它参考的列中有对应值。

### 非空约束
非空约束 (NOT NULL),听名字就能理解，被非空约束的列，在插入值时必须非空。
在MySQL中违反非空约束，不会报错，只会有警告

**ps: ** 约束这里还有一些疑惑，某些约束创建失败，这个问题留待后查。 
