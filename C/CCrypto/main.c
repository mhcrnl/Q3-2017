#include<stdio.h>
int main() {
    unsigned long int i=0;
    char ch;
    char name1[20],name2[20];
    FILE *fp,*ft;
    printf("ENTER THE SOURCE FILE:");
    gets(name1);
    printf("ENTER THE DESTINATION FILE:");
    gets(name2);
    fp=fopen(name1,"r");
    ft=fopen(name2,"w");
    if(fp==NULL) {
        printf("CAN,T OPEN THE FILE");
    }
    while(!feof(fp)) {
        ch=getc(fp);
        ch=~((ch^i));
        i+=2;
        if(i==100000) {
            i=0;
        }
        putc(ch,ft);
    }
    fclose(fp);
    fclose(ft);
    return 0;
}
