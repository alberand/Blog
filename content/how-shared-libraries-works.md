Title: How does shared libraries works?
Date: 03.04.2020
Modified: 03.04.2020
Status: draft
Tags: linux
Keywords: linux, shared library, so, global offset table, linker
Slug: shared-libs
Author: Andrey Albershtein
Summary: Are shared libraries really shared between processes? Let's test it on
the real processe
Lang: en

I was always wondering are the shared libraries really shared between processes?
How is it possible that multiple processes can use the same part of memory and
don't crush? Is glibc loaded only once in the system?

In this note I will try to describe my journey of answering these questions with
experiments.

### What is PIC (position-independent code)?

tramolines

TODO nice image of binary
Interactive svg image?


### Terminology

**relocations** are entries in binaries that are left to be filled in later
[4][4]

### References

* [Excelent article][5]
* [][]
* [][]
* [][]

[1]: https://stackoverflow.com/questions/39785280/how-shared-library-finds-got-section
[2]: https://stackoverflow.com/questions/32947936/locating-the-global-offset-table-in-an-elf-file
[3]: http://bottomupcs.sourceforge.net/csbu/x3824.htm
[4]: https://www.technovelty.org/linux/plt-and-got-the-key-to-code-sharing-and-dynamic-libraries.html
[5]: http://cseweb.ucsd.edu/~ricko/CSE131/the%20inside%20story%20on%20shared%20libraries%20and%20dynamic%20loading.pdf
[]: 
