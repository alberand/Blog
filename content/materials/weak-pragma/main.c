#pragma weak debug
extern void debug(char*);
void (*debugfunc)(char*) = debug;

int main(){
    if(debugfunc) (*debugfunc)("hello");
    return 0;
}
