---
title: "Go Channel"
date: 2020-03-06T17:24:41+08:00
draft: true
categories:
- 技术
tags:
- go
- channel
---

Go 的 `channel` 作为该语言很重要的特性，作为一个 gopher 有必要详细了解其实现原理。

## 使用

关于如何使用`channel` 我已经在之前一篇文章说过，可以看看，[传送门~](http://blog.yusank.space/Go%20Channel.html/)



## 原理解读

Go 语言的 `channel` 实现源码在`go/src/runtime/chan.go` 文件里。（go version ：1.13.4）

### 数据结构

首先看一下基础数据结构：

```go
// go 语言的 channel 结构以队列的形式实现
type hchan struct {
	qcount   uint           // total data in the queue，队列中元素总数
	dataqsiz uint           // size of the circular queue，循环队列的大小
	buf      unsafe.Pointer // points to an array of dataqsiz elements， 指向循环队列中元素的指针
	elemsize uint16 // 元素 size
	closed   uint32 // channel 是否关闭标志
	elemtype *_type // element type // channel 元素类型
	sendx    uint   // send index // 写入 channel 元素的索引
	recvx    uint   // receive index // 从 channel 读取的元素索引
	recvq    waitq  // list of recv waiters // 读取 channel 的等待队列（即阻塞的协程）
	sendq    waitq  // list of send waiters // 写入 channel 的等待队列

	// lock protects all fields in hchan, as well as several
	// fields in sudogs blocked on this channel.
	lock mutex // 互斥锁，用于协程阻塞
}

// 双向链表结构，其中每一个元素代表着等待读取或写入 channel 的协程
type waitq struct {
	first *sudog
	last  *sudog
}

```

通过源码数据结构，对 go 的 channel 实现有了初步的了解，解答了在我们读取或写入 channel 时，其中元素在哪儿，我们的协程在哪儿等待等数据相关问题。

- channel 底层实现是以队列作为载体，通过互斥锁保证在同一个时间点，只有一个待读取的协程读元素或待写入的协程写入元素。
- 如果有多个协程同时读取 channel 时，他们会进入读取等待队列：`recvq`，反之进入写入等待队列：`sendq`。
- `buf` 作为指针，指向 channel 中存储元素的数组的地址。
- `sendx`,`recvx` 作为channel 队列中写入和读取到元素的索引值。
- `closed` 为 channel 当前是否已被关闭标志。



