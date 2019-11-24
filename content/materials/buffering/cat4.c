#include <unistd.h>
#include <stdlib.h>

#define BUFSIZE 128

int main(){
    int rc = 1;
    int* c = malloc(BUFSIZE);
    read(0, c, BUFSIZE);

    while(rc > 0){
        write(1, c, BUFSIZE);
        rc = read(0, c, BUFSIZE);
    }

    return 0;
}
