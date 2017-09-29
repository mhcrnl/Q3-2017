/**
	@Author:	Mihai Cornel	Romania			mhcrnl@gmail.com
	@System:	Ubuntu 16.04	Code::Blocks 13.12	gcc 5.4.0
                	Fedora 24	Code::Blocks 16.01	gcc 5.3.1
			Windows Vista 	Code::Blocks 16.01
	@Copyright:	2017
	@file:
*/
#include "crypto.h"

void encrypt(char password[], int key){
    unsigned int i;
    for(i=0; i<strlen(password); ++i){
        password[i] = password[i]-key;
    }
}

void decrypt(char password[], int key){
    unsigned int i;
    for(i=0; i<strlen(password); ++i){
        password[i] = password[i]+key;
    }
}
