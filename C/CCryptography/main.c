#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "crypto.h"
#include "fileoper.h"
#include "tictactoe.h"
//#include "run_main.h"

int main()
{
    int selectie;
    printf("Hello world! Cryptography Application\n");

    for(;;) {
        puts("\t\t 1.Criptare parola.");
        puts("\t\t 2.For read a file");
        puts("\t\t 3.Play tictactoe game.");
        puts("\t\t 4.Play sudoku game.");

        puts("\t\t 10.Close.\n");

        puts("\nSelectati o optiune din meniu: ");
        scanf("%d", &selectie);
        switch(selectie){
            case 1:
            {
                char password[20];
                printf("Enter the password: ");
                scanf("%s", password);
                encrypt(password, 21);
                printf("Password encrypted: %s\n", password);
                decrypt(password, 21);
                printf("Password decrypted: %s\n", password);
                break;
            }
            case 2:
            {

                //getc();
                char fname[10];
                printf("Enter the name of file: ");
                gets(fname);

                char filename[] ="main.c";
                readFile(filename);

                break;
            }
            case 3:
                run_program();
                break;
            case 4:
                //runMain();
                break;

            default:
                fprintf(stdout, "Alegerea dvs. nu corespunde cu meniul: %d \n!", selectie);
                break;
        }
        if(selectie == 10) break;
    }

    return 0;
}
