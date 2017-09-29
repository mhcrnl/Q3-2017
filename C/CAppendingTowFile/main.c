#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

int main(int argc, char **argv)
{
    printf("Hello world!Appending tow files.\n");

    char buf[1024];
    int n, in, out;

    if(argc != 3){
        fprintf(stderr, "Usage: append Source Target\n");
        return 0;
    }
    //open first file for writing
    in = open(argv[1], O_RDONLY);
    //open the second file to writing
    out = open(argv[2], O_WRONLY|O_APPEND);

    while((n=read(in,buf,sizeof(buf)))>0)
    write(out,buf,n);

    return 0;
}
