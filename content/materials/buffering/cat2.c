#include <stdio.h>

int main(){
    int rc = 1;
    int c = fread(&c, 1, 1, stdin);

    while(rc > 0){
        fwrite(&c, 1, 1, stdout);
        rc = fread(&c, 1, 1, stdin);
    }

    return 0;
}
