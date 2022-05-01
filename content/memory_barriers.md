Title: Memory Barriers and Out-of-Order execution
Date: 28.01.2017
Modified: 28.01.2017
Status: draft
Tags: pelican, publishing
Keywords: pelican, publishing
Slug: memory_barriers
Author: Andrey Albershtein
Summary: Short version for index and feeds
Image: images/zephyr-logo.jpg
Lang: en

Gif animation of a problem (run single threaded -> ok, run multi-threaded -> not ok)

### Intro into how single threaded CPU can swap store/load instructions

Load instructions could have data dependencies (TODO find proof and example).
This cause CPU to swap it with instructions which could be executed while we
wait for data to be loaded.

### Intro into how multi threaded CPU with two threads can create double swap of
### instructions

Now imaging what will happen if CPU will swap to store/load instructions on both
CPU cores. We will get into this situation:

[DIAGRAM of what happens]

### Solution - Memory Barriers

This could be solved by memory barriers.

### Demonstration

### How memory barriers works?
It's a CPU instruction.

As a dependency:
```
Inserting a memory barrier tells the CPU and the compiler that what happened
before that command needs to stay before that command, and what happens after
needs to stay after.  
```

Find info regarding this:
```
The other thing a memory barrier does is force an update of the various CPU
caches - for example, a write barrier will flush all the data that was written
before the barrier out to cache, therefore any other thread that tries to read
that data will get the most up-to-date version regardless of which core or which
socket it might be executing by.
```

```shell
$ taskset -c ./test
```

READ this:
https://lwn.net/Articles/573436/
https://preshing.com/20120710/memory-barriers-are-like-source-control-operations/
https://stackoverflow.com/questions/19965076/gcc-memory-barrier-sync-synchronize-vs-asm-volatile-memory
https://mariadb.org/wp-content/uploads/2017/11/2017-11-Memory-barriers.pdf

Example:
https://peeterjoot.wordpress.com/2010/06/07/a-nice-simple-example-of-a-memory-barrier-requirement/

https://preshing.com/20120515/memory-reordering-caught-in-the-act/

Good explanation of cpp memory model and sync primitives
https://stackoverflow.com/questions/6319146/c11-introduced-a-standardized-memory-model-what-does-it-mean-and-how-is-it-g?rq=1
