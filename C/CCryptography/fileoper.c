/**
	@Author:	Mihai Cornel	Romania			mhcrnl@gmail.com
	@System:	Ubuntu 16.04	Code::Blocks 13.12	gcc 5.4.0
                	Fedora 24	Code::Blocks 16.01	gcc 5.3.1
			Windows Vista 	Code::Blocks 16.01
	@Copyright:	2017
	@file:
*/
#include "fileoper.h"

void readFile(char filename[]){
    int c;
    FILE *fp;
    fp = fopen(filename, "r");
    if(fp){
        while((c = getc(fp)) != EOF)
            putchar(c);
    }
    fclose(fp);
}

void createFile(char filename[]){

    FILE *fp;

    if((fp=fopen(filename, 'w'))==NULL){
        printf("Cannot open file.\n");
        exit(1);
    }
    fclose(fp);
}
