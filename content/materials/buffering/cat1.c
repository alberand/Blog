#include <unistd.h>

int main(){
    int rc = 1;
    int c = read(0, &c, 1);

    while(rc > 0){
        write(1, &c, 1);
        rc = read(0, &c, 1);
    }

    return 0;
}
