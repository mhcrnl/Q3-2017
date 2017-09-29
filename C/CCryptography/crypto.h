#ifndef CRYPTO_H_INCLUDED
#define CRYPTO_H_INCLUDED

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void encrypt(char password[], int key);
void decrypt(char password[], int key);


#endif // CRYPTO_H_INCLUDED
