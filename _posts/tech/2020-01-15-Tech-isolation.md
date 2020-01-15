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




