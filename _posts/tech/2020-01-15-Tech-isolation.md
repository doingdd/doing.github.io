---
layout: post
category: 技术
title: 数据库隔离
---

**本文翻译自[wiki: isolation](https://en.wikipedia.org/wiki/Isolation_%28database_systems%29)**

在数据库系统中，隔离行决定了对其它用户或系统如何显示事务完整性。例如，一个user正在创建一个采购订单，已经创建完成了header，但是还没有具体的采购数据，此时这个header对其它用户/系统(并发的操作，比如以采购订单为报告)是可见的吗(只的是当前的而不是过去的数据库系统)？  

一个更低的隔离级别可以让多个用户同时访问相同的数据，但同时也增加了用户遇到的并发影响的次数(脏读或丢失更新)。相反的，一个高级别的隔离可以降低并发的影响，但是需要更多的系统资源，而且增加了事务被其它事务block的可能性

隔离通常是数据库级别的一个属性，定义了何时一个事务修改可以被其它事务可见。在老系统中，它可以系统的实现，比如通过临时表来实现。在双层系统中，需要事务处理管理器(transaction processing，TP)来保持隔离.在n层系统中(比如多个网页尝试预定同一班飞机的最后一个座位)，需要结合存储过程和事务管理来进行预定，并发送给客户确认信息

隔离是ACID特性之一：Atomicity原子性，consitency一致性，Isolation隔离性，durability可恢复性

## 1. 并发控制
并发控制包含了DBMS中处理隔离和保证正确性的基础机制。数据库和存储引擎大量使用它来保证并发事务正确性，以及(通过不同机制)其它DBMS进程的正确性.事务类的机制通常会将数据访问的操作时间(事务调度)约束成确定的顺序，以具备可序列化性和可恢复性。而这种约束通常以为这性能的降低(与执行频率有关)，所以，并发控制机制的设计就是为了保证在约束下的最优性能。 通常在不损害正确性的情况下，会损害可序列化来保证性能，但是可恢复性不能妥协，因为通常会数据库完整性被快速破坏。

two-phase locking两段锁，是DBMS中最流行的事务并发控制方式，具备可序列化行、可恢复性及正确性。为了访问数据库对象，事务首先要获取该对象的锁。如果有其它事务已经获取了该对象的锁，改事务的获取锁动作可能会被block和延迟，这取决与改事务的操作类型(读还是写)。

## 2. 读现象

当事务1读取事务2可能更改的对象时，ANSI/ISO标准引用了三种不同的读现象

以下面这个表格为例：

id|name|age
---|---|---
1|joe|20
2|jill|25

### 赃读(dirty read)

赃读发生在一个事务被允许读取另一个事务修改完成，但还没有提交的行，如下：  

Transaction 1:
```python

/* Query 1 */
SELECT age FROM users WHERE id = 1;
/* will read 20 */
```
Transaction 2:
```python
/* Query 2 */
UPDATE users SET age = 21 WHERE id = 1;
/* No commit here */
```
Transaction 1:
```python
/* Query 1 */
SELECT age FROM users WHERE id = 1;
/* will read 21 */
```
Transaction 2:
```python
ROLLBACK; /* lock-based DIRTY READ */
```

但实际上真正的值应该是20，以为transaction 2 rollback了

在read uncommited 隔离级别中，唯一需要避免的是乱序更新，及先更新的结果要早于后更新的结果出现在结果集中

### 不可重复读(non repeatable read)
在同一个事务中读取两次，得到的结果不一样，这一现象成为不可重复读。

不可重复度发生在：当select的时候还没有加读锁，或者读锁刚刚被释放   

Transaction 1
```python
/* Query 1 */
SELECT * FROM users WHERE id = 1;
```
Transaction 2
```python
/* Query 2 */
UPDATE users SET age = 21 WHERE id = 1;
COMMIT; /* in multiversion concurrency
   control, or lock-based READ COMMITTED */
```
Transaction 1
```python
/* Query 1 */
SELECT * FROM users WHERE id = 1;
COMMIT; /* lock-based REPEATABLE READ */
```
此例中，transaction2 commit成功，意味着它对row的修改已经可见了，但是transaction 1在之前就已经读到了另一个版本的值了。这是，对于SERIALIZABLE和REPEATABLE READ这两个隔离级别来说，在第二次读时，DBMS必须返回老的值。在read commit 和read uncommit隔离时，dbms必须返回新值，这就是不可重复读

两种方式避免不可重复读，一种是延后执行transaction 2，直到transaction 1 commit完成，也就是说在transaction 1上加锁，顺序执行T1,T2

第二种方式是想多版本并发控制一样，为了高并发，t2允许先commit，但是T1只能操作一个老版本的database的快照，当T1需要commit时，dbms先判断T1 commit后的结果是否严格满足T1,T2的先后顺序，如果满足，可以commit，如果不满足(也就是修改了T2commit的值)，则报serializtion failure且rollback

对于用锁的方式，在REPEATABLE READ隔离级别，T1会所致id=1的row，T2会hang住直到T1 commit或者rollback，在read commit隔离级别，第二次执行T1时，age已经变化了(这段不懂)

对于多版本的模式，在serializable级别，两次select都会返回一个database的snapshot，所以得到的是相同的值。但是，如果T2同时尝试更新改row，serialization fail，并且T1需要roll back； 在read commit级别，每次query都返回快照的结果，所以，每个query读到的内容是不一样的，不会发生serializable failuer， T1也不用重试

### 幻读(phantom reads)

幻读发生在当前事务读取了其它事务插入或者删除的rows

当select where没有加rank locks时会发生幻读，幻读是特殊的不可重复度，区别是两次读请求是一样的，而且两次读之间，T2插入了满足读条件的数据
Transaction 1
```python
/* Query 1 */
SELECT * FROM users
WHERE age BETWEEN 10 AND 30;
```
Transaction 2
```python
/* Query 2 */
INSERT INTO users(id,name,age) VALUES ( 3, 'Bob', 27 );
COMMIT;
```
Transaction 1
```python
/* Query 1 */
SELECT * FROM users
WHERE age BETWEEN 10 AND 30;
COMMIT;
```

T1的两次读请求是一样的，在最高级别的隔离时，两次读取的数据是完全一致的，但是，低一级的隔离时，会返回不同值

SERIALIZABLE隔离时，T1第一次query会lock住10-30(rang lock)，T2会等T1释放后才能操作；在REPEATABLE READ隔离，不会rang lock，所以第二次读到的值是T2插入后的值

## 隔离级别

在数据库ACID四个特性中，isolation是经常会被降低的，目的是减少lock带来的并发能力下降，这需要服务自己添加额外的逻辑来保证正确性

下面从上到下的隔离级别从高到低排列：

### Serializable
最高的隔离级别

在基于锁的DBMS实现中，Serializable读和写都加锁，select where时，还会加range lock，以防止幻读

### Repeatable reads

在此隔离级别下，读和写仍然会加锁，但是range lock不会加，所以会发生幻读

### Read committed

读不加锁，写加锁，所以“不可重复度”会发生

### Read uncommitted

最低级的隔离，会发生赃读

## 默认的隔离级别

不同的DBMS有不同的default隔离，很多还支持额外的语法来获取锁，比如select for update

##总结

### 未提交读(read uncommitted)  

最低级，就是完全没有隔离，A读数据，B此时在更新，但是还没有commit，rollback了，这时A读到的数据居然是B更新之后的，也就是脏的数据，赃读

### 提交读(read committed)

那加上一个限制吧，A读取的数据必须是其它人commit过后的，但还是有问题，A读了一次数据，B更新并commit，A又想读一次，发现和第一次不一样了，也就是“读”同一个数据的操作“不可重复”，发生了不可重复读。 也就是对一个事务来说，它“感知”到了其它事务的存在，仍然不太好

### 可重复读(read repeated)

那在加一个限制，A读数据的时候不让其它事务来捣乱，不许它们修改，这样保证一个事务内，“读”操作是稳定可重复的，但还是有个问题，别人update不可以，但是可以insert or delete，A重复读两次会发生"幻觉“,怎么两次的结果条数不一样，这就是”幻读“

### 序列化读(serializable)

最高级别，A事务读的时候不仅加了读锁、写锁，还有rang lock，阻止其它事务insert or delete数据，实现完全隔离，这时，每个事务都只能感知到自己在操作数据库。当然，这引入了更大的可能性：事务会被频繁block，影响服务性能，所以，隔离级别也不是越高越好，他是个balance的议题




