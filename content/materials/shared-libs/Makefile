
app:
	gcc -Wall -ggdb -L. -Wl,-rpath=. -o app main.c -lfoo

lib:
	gcc -c -Wall -Werror -fpic foo.c
	gcc -shared -o libfoo.so foo.o

lib-nopic:
	gcc -c -Wall -Werror foo.c
	gcc -shared -o libfoo.so foo.o
