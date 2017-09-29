#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>

int main()
{
    printf("Hello world! Simple UNIX shell application\n");

    char command[BUFSIZ];
    int status;
    pid_t pid;

    for(;;){
        printf("simpsh: ");
        if(fgets(command, sizeof(command), stdin)==NULL){
            printf("\n");
            return 0;
        }

    command[strlen(command)-1]='\0';
    if((pid = fork())==0)
        execlp(command,command, 0);

    while(wait(&status)!=pid)
        continue;

    printf("\n");
    }

    return 0;
}
