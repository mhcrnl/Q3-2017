#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "agendatelefonica.h"
//https://github.com/emam95/PhoneBook/blob/master/phonebook.h
int main()
{
    contact contacte[100];
    char filename[15] = "contacteV1.txt";
    int cont = 0;
    int selectie;

    printf("\tAgenda Telefonica Versiunea 01!\n\n");
    for(;;){
        puts("\t\t1.\tAdauga Contact.");
        puts("\t\t2.\tAfisare Contacte.");
        puts("\t\t3.\tSalvare Contacte.");

        puts("\t\t9.\tInchide aplicatia");

        printf("\nSelectati o optiune din meniu: ");
        scanf("%d", &selectie);

        switch(selectie){
            case 1:
                cont = adaugaContact(contacte, cont);
                break;
            case 2:
                afisareContacte(contacte, cont);
                break;
            case 3:
                salveazaContacte(contacte, filename, cont);
                break;

            case 9:
                puts("A-ti ales sa parasiti aplicatia!");
                break;
            default:
                puts("Alegerea dvs. nu corespunde meniului. Selectati din nou.");
                break;
        }

        if(selectie == 9) break;
    }


    return 0;
}
