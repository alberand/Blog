Title: How does shared libraries works?
Date: 03.04.2020
Modified: 03.04.2020
Status: draft
Tags: linux
Keywords: linux, shared library, so, global offset table, linker
Slug: how-shared-libraries-works
Author: Andrey Albershtein
Summary: Are shared libraries really shared between processes? Let's test it on
the real processe
Lang: en

I was always wondering are the shared libraries really shared between processes?
How is it possible that multiple processes can use the same part of memory and
don't crush? Is glibc loaded only once in the system?

In this note I will try to describe my journey of answering these questions with
experiments.

###


### References

* [][]
* [][]
* [][]
* [][]

[1]: https://stackoverflow.com/questions/39785280/how-shared-library-finds-got-section
[2]: https://stackoverflow.com/questions/32947936/locating-the-global-offset-table-in-an-elf-file
[3]: http://bottomupcs.sourceforge.net/csbu/x3824.htm
[]: 
[]: 
[]: 
