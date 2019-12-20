Title: Template
Date: 16.12.2019
Modified: 16.12.2019
Status: draft
Category: Article
Slug: weak-directive
Authors: Andrey Albershtein
Summary: Using Linker's directive to define optional functions
lang: en

From this very [interesting article][1] about linking I find out that there
exist a `#pragma weak foofunction` directive which tells linked to handle the
function as weakly defined. What it means is that if linker fails to find
declaration (the code itself) of the function it will skip it and continue
linking.

#### Prepare application

Let's create simple example to work with:

{% include_code weak-pragma/main.c lang:c :hideall: %}

In this code

Next, let's create debugging function:

{% include_code weak-pragma/debug.c lang:c :hideall: %}



#### Look inside

#### Thoughts

Personally, I don't think that it is a good approach to base your debugging
function on this directive. As initially it was created for backward
compatibility and general definition of function in the libraries (function
overriding) [\[2\]][2], [\[3\]][3]. But if you are using third party library
with weak function you can define your for debugging. 

I search through some GNU project and other projects for the use cases of this
directive. It seems like it is not commonly used only in some specific use
cases, for example, in `pthreadlib` and `musl-libc`. However, I think it is very
convenient and interesting way to disable/enable debugging or development
features. Maybe in future I find a way how to use it.

#### References

* [The inside story on shared libraries and dynamic loading][1]
* [GCC docs - Weak Pragmas][2]
* [Wikipedia - Weak Symbol][3]

[1]: http://cseweb.ucsd.edu/~ricko/CSE131/the%20inside%20story%20on%20shared%20libraries%20and%20dynamic%20loading.pdf
[2]: https://gcc.gnu.org/onlinedocs/gcc/Weak-Pragmas.html
[3]: https://en.wikipedia.org/wiki/Weak_symbol
