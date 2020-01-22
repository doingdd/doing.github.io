---
layout: post
category: 技术
title: 数据库原子性
---

**本文翻译自[wiki: atomicity](https://en.wikipedia.org/wiki/Atomicity_\(database_systems\) )**

原子性(atomicity),是数据库特性ACID中的A，一个原子化的事务是不可分割、无法简化的一些列数据库操作，只能全部发生，或者全部不发生。在某些“部分更新”会造成比“全部不更新”更坏的影响时，原子化可以保证“部分更新”不会发生。结果就是，一个原子化的事务是不会被其它数据库客户端感知到正在运行中这个状态的。在某一时刻，该事务还未发生，在下一时刻，它已经完全执行完成了(或者什么都没有执行)。

一个原子化的例子是从A银行给B银行转账，它包含两个步骤，从A银行减钱和给B银行加钱。这两个步骤的原子化保证了数据库一致性，如果任一步骤失败，钱都不会被减掉或者增加

## 正交

原子性并不和其它ACID中的特性完全正交(什么意思？)。比如，当隔离性错误时(比如死锁)，隔离性依赖原子性来rollback修改；违反一致性原则是，一致性也依赖rollback；最后，当外部故障发生时，原子性自身也依赖持久性。

所以，无法检测到错误并回滚包含的事务会引起隔离性和一致性的错误。


## 实现

一般系统会通过提供一些机制明确表明事务的开始和结束来实现原子化，或者通过在修改发生之前保留一份数据备份来实现。一些文件系统已经实现了避免使用多个备份数据的方法，比如[journaling](https://en.wikipedia.org/wiki/Journaling_file_system),数据库经常讲logging/journalling用在一些表中来记录变化，当变化成功生效后，系统会根据需要同步这些log。然后，故障恢复时会忽略那些不完整的条目，尽管实现方式因为并发问题会有很多不同，原子化--例如全成功或全失败--仍然保留了下来。

最终，任何应用层面的实现都依赖操作系统级别的功能。在操作系统级别，POSIX系统提供了系统级的调用方式，例如open(2),flock(2)来允许应用原子化的打开或者锁定一个文件。在进程级别，POSIX系统提供了足够多的同步原函数。

硬件级别的原子化需要像[test-and-set](https://en.wikipedia.org/wiki/Test-and-set)(写一块内存，同时返回旧内存的值),[fetch-and-add](https://en.wikipedia.org/wiki/Fetch-and-add)（将内存值加上某个值，并返回原值）,[compare-and-swap](https://en.wikipedia.org/wiki/Compare-and-swap)（将某个值和内存中的值对比，相同则给内存赋新值）, [Load-Link/Store-Conditional](https://en.wikipedia.org/wiki/Load-link/store-conditional)(load-link负责返回当前内存值，store-conditional之后会给内存set新值) 和[ memory barriers](https://en.wikipedia.org/wiki/Memory_barrier)(将内存操作按顺序约束，保证barrier屏障前发生的操作早于其后的操作执行).由于目前很少有硬件不支持并发执行(比如超线程，多进程)，便携操作系统不能简单的阻止中断来实现同步操作。








