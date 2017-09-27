#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "agendatelefonica.h"

void salveazaContacte(contact contacte[], char fileName[], int cont){
    FILE *fp;
    int i;
    fp = fopen(fileName, "a+");
    for(i=0; i<cont; i++){
        fprintf(fp,"%s,%s,%s,%s,%s\n", contacte[i].nume, contacte[i].prenume, contacte[i].adresa,
            contacte[i].orasul, contacte[i].telefon);
    }
    fclose(fp);
    puts("Salvarea contactelor s-a incheiat cu succes!");
}

void afisareContacte(contact contacte[], int cont){
    int i;
    for(i=0; i<cont; i++){
        printf("%s %s %s %s %s \n", contacte[i].nume, contacte[i].prenume, contacte[i].adresa,
            contacte[i].orasul, contacte[i].telefon);
    }
}

int adaugaContact(contact contacte[], int cont){

    printf("Introduce-ti numele: ");
    scanf("%s", contacte[cont].nume);
    //strcpy(contacte[cont].nume, nume);
    printf("Introduce-ti prenumele: ");
    scanf("%s", contacte[cont].prenume);
    printf("Introduce-ti adresa: ");
    scanf("%s", contacte[cont].adresa);
    printf("Introduce-ti orasul: ");
    scanf("%s", contacte[cont].orasul);
    printf("Introduce-ti numarul de telefon: ");
    scanf("%s", contacte[cont].telefon);

    cont++;
    return cont;
}
