Title: How does "#pragma weak" work
Date: 16.12.2019
Modified: 15.01.2020
Status: published
Category: Article
Slug: weak-directive
Authors: Andrey Albershtein
Summary: Using Linker's directive to define optional functions
lang: en

From this very [interesting article][1] about linking of executables I find out
that there exist a `#pragma weak foofunction` directive. It tells linker to
handle the following function as weakly defined. What it means is that if linker
fails to find definition (implementation) of the function it will skip it and
won't show any errors. In this note I will demonstrate how does it work.

#### Prepare application

Firstly, let's create a simple example to work with:

{% include_code weak-pragma/main.c lang:c :hideall: %}

At line 2 we define debug function with an `extern` keyword. That means that
this function can be defined in any of the application source files (or in other
words in any object file). The next line contains pointer (named `debugfunc`) to
this function.

In the `main()` in the if-condition we check that if `debugfunc` have anything
but zero. If it is not zero we call it, otherwise application terminates.

Next, let's create second file with the implementation of `debug` function. It
is very very simple:

{% include_code weak-pragma/debug.c lang:c :hideall: %}

#### Interesting part

See what happens if we compile `main.c` only:

    andrew at andrew-laptop in /tmp/mainfun
    ➔ gcc -Wall -o app main.c

    andrew at andrew-laptop in /tmp/mainfun
    ➔ ./app

Nothing =). But if we compile `debug.c` and then link it together with newly
compiled `main.c`, then:

    andrew at andrew-laptop in /tmp/mainfun
    ➔ gcc -Wall -c main.c

    andrew at andrew-laptop in /tmp/mainfun
    ➔ gcc -Wall -c debug.c
    
    andrew at andrew-laptop in /tmp/mainfun
    ➔ gcc -Wall -o app main.o debug.o
    
    andrew at andrew-laptop in /tmp/mainfun
    ➔ ./app
    [DEBUG] hello

Note that to compile files separately without linking you need to use `-c`
argument.

In the first case linker couldn't find implementation for `debug()` and replace it
with zero. Therefore, at all places where we reference `debug()` we get
zero. As `debugfunc` pointer points to the `debug()` and also contains 0 it
isn't called.  In the second case linker found implementation for `debug()` and
treat it as a normal function. In this case `debugfunc` is pointing to the
`debug()` (non-zero address in memory) and therefore will be called.

#### Look inside

Let's look what is really happening in the binaries and if it is true what is
described in the previous paragraph. Firstly, let's compile both examples as two
separated binaries for further comparison:

    andrew at andrew-laptop in /tmp/mainfun
    ➔ gcc -Wall -o app main.o
    
    andrew at andrew-laptop in /tmp/mainfun
    ➔ gcc -Wall -o appd main.o debug.o

Next let's look what is the difference between them. With `nm` utility we can see
that in the first binary there no `debug` symbol (reference to the function) at
all.

    andrew at andrew-laptop in /tmp/mainfun
    ➔ nm app | grep debug
    0000000000004028 D debugfunc

    andrew at andrew-laptop in /tmp/mainfun
    ➔ nm appd | grep debug
    0000000000001160 T debug
    0000000000004030 D debugfunc

Actually, there quite a lot of small discrepancies between two binaries. You can
look on the differences with the following command:

    andrew at andrew-laptop in /tmp/mainfun
    ➔ vimdiff <(objdump -d app) <(objdump -d appd)

Disassembly of the main function should be similar to this:

    0000000000001119 <main>:
        1119:       55                      push   %rbp
        111a:       48 89 e5                mov    %rsp,%rbp
        111d:       48 8b 05 04 2f 00 00    mov    0x2f04(%rip),%rax    # 4028 <debugfunc>
        1124:       48 85 c0                test   %rax,%rax
        1127:       74 10                   je     1139 <main+0x20>
        1129:       48 8b 05 f8 2e 00 00    mov    0x2ef8(%rip),%rax    # 4028 <debugfunc>
        1130:       48 8d 3d cd 0e 00 00    lea    0xecd(%rip),%rdi     # 2004 <_IO_stdin_used+0x4>
        1137:       ff d0                   callq  *%rax
        1139:       b8 00 00 00 00          mov    $0x0,%eax
        113e:       5d                      pop    %rbp
        113f:       c3                      retq

The first two instruction are used to save address of the previous stack frame
and switch to the frame local the current function (for more info see \[4\][4]).
The third one moves value located at address 0x4028 to the %rax register. This, in
turn, is used in the following `test` instruction which checks if it is equals
to zero and if so it sets `ZF` flag to 1\[5\][5]. The next instruction `je`
jumps to the address 1139 if `ZF` flag is equal to 1. The 1139 address is the
end of the function (`return 0;`).

The 0x4028 address is equal to 0x2f04 + %rip (0x1124 - the address of the next
instruction). The %rip is used for relative referencing (see \[6\][6]).

What is located at address 0x4028? As we know that it is global static variable
it should be somewhere in the `.data` section. We can find it out with following
command:

    ➔ objdump -s -j .data app
    app:     file format elf64-x86-64
    
    Contents of section .data:
     4018 00000000 00000000 20400000 00000000  ........ @......
     4028 00000000 00000000                    ........

As you can see it is all zeros. So, ZF will be 0 and `je` will jump to 1139.

In opposite case if there was something at 4028 then %rax wasn't zero, ZF was set
to zero and `je` didn't jump. Even though the second binary has a little bit
different addresses the `main()` is completely the same.

    0000000000001139 <main>:
        1139:       55                      push   %rbp
        113a:       48 89 e5                mov    %rsp,%rbp
        113d:       48 8b 05 ec 2e 00 00    mov    0x2eec(%rip),%rax    # 4030 <debugfunc>
        1144:       48 85 c0                test   %rax,%rax
        1147:       74 10                   je     1159 <main+0x20>
        1149:       48 8b 05 e0 2e 00 00    mov    0x2ee0(%rip),%rax    # 4030 <debugfunc>
        1150:       48 8d 3d ad 0e 00 00    lea    0xead(%rip),%rdi     # 2004 <_IO_stdin_used+0x4>
        1157:       ff d0                   callq  *%rax
        1159:       b8 00 00 00 00          mov    $0x0,%eax
        115e:       5d                      pop    %rbp
        115f:       c3                      retq

The address of the to which `debugfunc` points is 0x4030. Again, let's use
`objdump` to see what is in the `.data` section:

    ➔ objdump -s -j .data appd
    
    appd:     file format elf64-x86-64
    
    Contents of section .data:
     4020 00000000 00000000 28400000 00000000  ........(@......
     4030 60110000 00000000                    `.......

#### Thoughts

Personally, I don't think that it is a good approach to base your debugging
function on this directive. As initially it was created for backward
compatibility and general definition of function in the libraries (function
overriding) [\[2\]][2], [\[3\]][3]. But if you are using third party library
with weak function you can define your for debugging. 

I search through some GNU project and other projects for the use-cases of this
directive. It seems like it is not commonly used. Only in some specific
cases, for example, in `pthreadlib` and `musl-libc`. However, I think it is very
convenient and interesting way to disable/enable debugging or development
features. Maybe in future I will find a way how to use it.

#### References

* [The inside story on shared libraries and dynamic loading][1]
* [GCC docs - Weak Pragmas][2]
* [Wikipedia - Weak Symbol][3]
* [Stackoverflow question about stack frames][4]
* [TEST (x86 Instruction)][5]
* [What does “mov offset(%rip), %rax” do?][6]

[1]: http://cseweb.ucsd.edu/~ricko/CSE131/the%20inside%20story%20on%20shared%20libraries%20and%20dynamic%20loading.pdf
[2]: https://gcc.gnu.org/onlinedocs/gcc/Weak-Pragmas.html
[3]: https://en.wikipedia.org/wiki/Weak_symbol
[4]: https://stackoverflow.com/questions/41912684/what-is-the-purpose-of-the-rbp-register-in-x86-64-assembler
[5]: https://en.wikipedia.org/wiki/TEST_(x86_instruction)
[6]: https://stackoverflow.com/questions/29421766/what-does-mov-offsetrip-rax-do
