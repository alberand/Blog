#include <stdio.h>
#include <stdlib.h>

#define BUFSIZE 512

int main(int argc, char** argv){
    int rc = 1;
    int bufsize = BUFSIZE;
    int* buf = malloc(BUFSIZE);

    fread(buf, 1, bufsize, stdin);

    while(rc > 0){
        fwrite(buf, 1, bufsize, stdout);
        rc = fread(buf, 1, bufsize, stdin);
    }

    return 0;
}
