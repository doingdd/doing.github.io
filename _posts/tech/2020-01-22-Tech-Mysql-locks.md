---
layout: post
category: 技术
title: 记一个锁相关的问题+一些锁的基本概念
---

首先，从问题开始：有两个相同的进程同一时刻读取相同的表，需要在进程A读取之后，进程B可以直接跳过读取逻辑，不重复执行。

首先想到的就是加写锁实现：进程A读取时给改表加上互斥锁(或者叫悲观锁，写锁)，进程B读取时会自动等待hang住，直到进程A执行完当前的逻辑，commit之后才可以继续执行。但是由于代码逻辑原因导致，进程commit之后，实际上改表中的记录还没有被真正修改成进程A预期的值，这时不希望进程B读到它，但是这个加锁的方式，B一定会读到这个表里的数据，即使它被A的写锁hang了一段时间之后，简单的实现是这样的：

Transaction 1:
```python
mysql> set autocommit = 0;
Query OK, 0 rows affected (0.00 sec)

mysql> select * from roles for update;
+----+---------------+------------+------------+---------+
| id | name          | permission | project_id | default |
+----+---------------+------------+------------+---------+
|  1 | User          |          3 |          1 |       0 |
|  3 | Administrator |         15 |          1 |       0 |
|  4 | Anonymous     |          1 |          1 |       1 |
+----+---------------+------------+------------+---------+
3 rows in set (0.00 sec)
```
Transaction 2:
```python
mysql> select * from roles for update;
...hang until t1 commit
```
先复习一下mysql关于锁的知识，mysql的锁实际上是通过下面的引擎实现的，MyISAM和InnoDB两个引擎分别支持的锁粒度不同，后者可以支持行级锁，下面关于锁的描述来自[mysql官方文档](https://dev.mysql.com/doc/refman/5.7/en/innodb-locking.html)  


## 共享锁和排他锁

InnoDB支持两种行级锁：共享锁(shared locks,s),排他锁(exclusive locks,x)
 
1. 共享锁(s)：允许拿到锁的事务读数据    
2. 排他锁(x): 允许拿到锁的事务更新和删除数据  

如果事务1拿到了row r的共享锁，事务2的拿锁请求有如下情况：  
1. T2 请求s锁的话，可以立即成功，这是T1和T2都有s锁  
2. T2 请求x锁的话，需要等待T1释放s锁  

如果T1拿到row r的排他锁x，那T2的两种锁请求(s和x)都需要等待T1释放其锁  

## 意向锁
InnoDB支持不同粒度的锁，允许行级锁和表级锁共存。例如，`lock tables ... write`拿到的是一个表级锁。 意向锁是表级锁，在执行这句话时，实际上加了三个锁：mysql的意向排他锁，innoDB加的意向排他锁，和排他锁：

```python
mysql> lock tables resource_track write;
Query OK, 0 rows affected (0.00 sec)

mysql> SELECT * FROM performance_schema.metadata_locks;
+-------------+--------------------+----------------+-----------------------+----------------------+---------------+-------------+-------------------+-----------------+----------------+
| OBJECT_TYPE | OBJECT_SCHEMA      | OBJECT_NAME    | OBJECT_INSTANCE_BEGIN | LOCK_TYPE            | LOCK_DURATION | LOCK_STATUS | SOURCE            | OWNER_THREAD_ID | OWNER_EVENT_ID |
+-------------+--------------------+----------------+-----------------------+----------------------+---------------+-------------+-------------------+-----------------+----------------+
| GLOBAL      | NULL               | NULL           |       140337721235408 | INTENTION_EXCLUSIVE  | STATEMENT     | GRANTED     | sql_base.cc:5495  |          323270 |             40 |
| SCHEMA      | test_doing         | NULL           |       140337721066032 | INTENTION_EXCLUSIVE  | TRANSACTION   | GRANTED     | sql_base.cc:5480  |          323270 |             40 |
| TABLE       | test_doing         | resource_track |       140337721322880 | SHARED_NO_READ_WRITE | TRANSACTION   | GRANTED     | sql_parse.cc:5938 |          323270 |             40 |
| TABLE       | performance_schema | metadata_locks |       140337721118496 | SHARED_READ          | TRANSACTION   | GRANTED     | sql_parse.cc:5938 |          323270 |             41 |
+-------------+--------------------+----------------+-----------------------+----------------------+---------------+-------------+-------------------+-----------------+----------------+
4 rows in set (0.00 sec)

``` 

意向锁也分两种：   
1. 意向共享锁(intention shared lock, IS)，表示事务有加共享锁的意图。  
2. 意向排他锁(intention exclusive lock,IX),事务有加排他锁的意图。  

例如：`select ... for in share mode`会加一个IS，`select ... for update`加IX。  

意向锁的目的是为了避免每次请求锁的时候扫全表。  

比如，事务1加了个行级的排他锁，这时它有一个表级的意向排他锁锁和行级的排他锁，事务2也来请求排他锁，它发现表上已经有意向排他锁了，就不用扫每一行是否有锁了，直接再加个意向排他锁之后，开始阻塞。  

下表表示了锁与锁之间兼容性，不兼容表示阻塞，兼容表示可以共存：   

锁的兼容性|S|IS|X|IX
---|---|---|---|---
S|Compatable|Compatable|Conflict|Conflict
IS|Compatable|Compatable|Conflict|Compatable
X|Conflict|Conflict|Conflict|Conflict
IX|Conflict|Compatable|Conflict|Compatable

如果一个锁请求与已经存在的锁不兼容，而且会导致死锁，则会报错。  

意向锁不会加实际上的锁(`lock tables ... write`这种全表请求除外)，它的主要目的是表示有人正在锁定某个row，或者将要锁定某个row。  

## 记录锁(行锁)
行锁严格意义上并不是锁定一个整行，实际上它锁定的是该行的索引，例如`select c1 from t1 where c1 = 10 for update`,这个锁会阻止任何对c1=10这条记录的修改，删除和插入。

即使一个行它没有索引，InnoDB会建立一个隐藏的聚簇索引并用它来加锁，详见[cluster and secondary index](https://dev.mysql.com/doc/refman/5.7/en/innodb-index-types.html)  

行锁在show engine innodb status 大概长成这样：

```python
RECORD LOCKS space id 58 page no 3 n bits 72 index `PRIMARY` of table `test`.`t` 
trx id 10078 lock_mode X locks rec but not gap
Record lock, heap no 2 PHYSICAL RECORD: n_fields 3; compact format; info bits 0
 0: len 4; hex 8000000a; asc     ;;
 1: len 6; hex 00000000274f; asc     'O;;
2: len 7; hex b60000019d0110; asc        ;;
```

## gap locks间隙锁
间隙锁锁定的是索引之间的差值，或者锁定<某值或者>某值的索引范围。例如`SELECT c1 FROM t WHERE c1 BETWEEN 10 and 20 FOR UPDATE;`，由于整个10到20之间都被锁定，插入c1=15的请求会阻塞，无论是不是真的有一条记录的c1=15

一个gap的跨度可以是单一索引值，多个索引值和空值。  

Gap locks are part of the tradeoff between performance and concurrency, and are used in some transaction isolation levels and not others.
间隙锁是并发和性能之间的权衡，在一些隔离级别里不生效。  

当仅查询一个唯一索引的唯一行时，没有必要加间隙锁，比如，如果id是唯一索引时`SELECT * FROM child WHERE id = 100;`加的是一个行锁。  
如果id不是索引，或者不是唯一索引，上面的select会加一个间隙锁。

间隙锁是允许所冲突的，也就是多个同一范围的间隙锁可以共存，比如一个共享间隙锁，和一个排他间隙锁，锁定了同一个范围，这时如果范围内的索引删除了一条记录，这两个锁会被合并成一个。间隙锁的共享和排他没有区别，因为并不会互相不兼容。

## next-key locks 下一键锁


##死锁
当多个事务互相拿着对方所需要的锁时，可能发生死锁，因为每个事务都在等待对方执行完成，自己才完成，死锁的两种发生情景：  

1. 事务1请求了表A的锁，又去请求表B的锁；同时事务2请求了表B的锁，在请求表A的锁，这时，事务1等事务2执行完成，事务2又同时等事务1完成，就deadlock了。  
2. 另一种情况是事务想要获取range锁和gaps锁，由于时间原因，每个事务都拿到了其中一部分锁，等待其它锁。  

mysql关于死锁有自动检测机制，详见[deadlock](https://dev.mysql.com/doc/refman/5.7/en/glossary.html#glos_deadlock)  


这个机制没有任何问题，只是不能满足本次需求