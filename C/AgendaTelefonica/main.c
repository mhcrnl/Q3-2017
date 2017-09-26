#include <stdio.h>
#include <stdlib.h>
#include <string.h>

//https://github.com/irLinja/Phonebook/blob/master/Phonebook.c sursa
struct Agenda {
    char nume[15];
    char prenume[15];
    char telefon[15];
};
/**Variabile globale*/
struct Agenda agenda[100];
int cont = 0;

/**Functii declarare*/
void adaugaContact();
void stergeContact();
int cauta(char nume[15], char prenume[15]);
void afisareContacte();
void editareContact();
void cautaContact();
void stergeToateContactele();
void randomContact();
void salveazaContacte();
void incarcaContacte();

int main()
{
    int selectie;
    printf("\t\t AGENDA TELEFONICA!\n\n");

    for(;;){
        puts("\t\t 1.\tAdauga contact.");
        puts("\t\t 2.\tSterge contact.");
        puts("\t\t 3.\tAfisare contacte.");
        puts("\t\t 4.\tEditare contact.");
        puts("\t\t 5.\tCautare contact.");
        puts("\t\t 6.\tSterge toate contactele.");
        puts("\t\t 7.\tGenerare aleatoare a unui contact.");
        puts("\t\t 8.\tSalveaza contactele intr-o fila.");
        puts("\t\t 9.\tIncarca contactele dintr-o fila.");

        puts("\t\t 10.\tInchideti aplicatia.");

        puts("\nSelectati o optiune din meniu: ");
        scanf("%d", &selectie);

        switch(selectie){
            case 1:
                adaugaContact();
                break;
            case 2:
                stergeContact();
                break;
            case 3:
                afisareContacte();
                break;
            case 4:
                editareContact();
                break;
            case 5:
                cautaContact();
                break;
            case 6:
                stergeToateContactele();
                break;
            case 7:
                randomContact();
                break;
            case 8:
                salveazaContacte();
                break;
            case 9:
                incarcaContacte();
                break;

            case 10:
                puts("A-ti ales sa iesiti din aplicatie.");
                break;

            default:
                fprintf(stdout, "Alegerea dvs. nu corespunde cu meniul: %d \n!", selectie);
                break;
        }
        if(selectie == 10) break;
    }

    return 0;
}

void incarcaContacte(){
    char filename[15];
    FILE *fp;
    do{
        printf("Introduce-ti numele filei pe care dori-ti sa o incarcati ex: agenda.txt: ");
        scanf("%s", &filename);
        if(fopen(filename, "r")== NULL){
            puts("Fila nu a fost gasita!");
        }
    }while(fopen(filename, "r") == NULL);
    fp = fopen(filename, "r");
    cont =0;
    char incarca[100];
    while(fgets(incarca, 100, fp)!= NULL){
        printf("%s \n", incarca); //split(incarca, " ");
        cont++;
    }
    fclose(fp);
    puts("Fila s-a incarcat cu succes!");
}

void salveazaContacte(){
    FILE *fp;
    char filename[15];
    int i;

    puts("Introduce-ti numele filei(EX: agenda.txt): ");
    scanf("%s", &filename);

    fp=fopen(filename, "a+");

    for(i=0; i<cont; i++){
        if(agenda[i].nume != '\0'){
            fprintf(fp, "%s %s %s", agenda[i].nume, agenda[i].prenume, agenda[i].telefon);
        }
    }
    fclose(fp);
    puts("Contactele au fost salvate cu succces");
}

void randomContact(){
    int nrRand = 0;
    int x = 0;

    nrRand = rand() % cont;
    x= nrRand;

    srand(time (NULL));

    printf("Numele contactului ales: %s %s \n", agenda[x].nume, agenda[x].prenume);
    printf("Numarul de telefon: %s .\n", agenda[x].telefon);
}

void cautaContact(){
    int x = 0;
    char cautNume[15];
    char cautPrenume[15];

    puts("Care este numele contactului pt. care cautati numarul de telefon?");
    printf("Introduce-ti numele: ");
    scanf("%s", cautNume);
    printf("Introduce-ti prenumele: ");
    scanf("%s", cautPrenume);

    for(x=0; x<cont; x++){
        if(strcmp(cautNume, agenda[x].nume)== 0)
            if(strcmp(cautPrenume, agenda[x].prenume)== 0){
                printf("Contactul %s %s are numarul de telefon: %s.\n",
                    agenda[x].nume, agenda[x].prenume, agenda[x].telefon);
                return;
            } else
                puts("Contatul nu a fost gasit, mai incercati!");
    }
}

void stergeToateContactele(){

    int i;
    char nul[15] = {'\0'};

    for(i=0; i<cont; i++){
        strcpy(agenda[i].nume, nul);
        strcpy(agenda[i].prenume, nul);
        strcpy(agenda[i].telefon, nul);

    }
    cont = 0;
    puts("Toate contactele au fost sterse.");
}

void editareContact(){

    char editNume[15];
    char editPrenume[15];
    int editIndex = -1;

    puts("Care este numele contactului pt care doriti editarea numarului de telefon?");
    printf("Introduce-ti numele: ");
    scanf("%s", &editNume);
    printf("Introduce-ti prenumele: ");
    scanf("%s", &editPrenume);

    editIndex = cauta(editNume, editPrenume);
    if(editIndex != -1){
        printf("Introduce-ti noul nume: ");
        scanf("%s", agenda[editIndex].nume);
        printf("Introduce-ti noul Prenume: ");
        scanf("%s", agenda[editIndex].prenume);
        printf("Introduce-ti noul numar de telefon: ");
        scanf("%s", agenda[editIndex].telefon);
        puts("Contactul a fost actualizat cu succes!");
    } else {
        puts("Contactul nu a fost gasit. Mai incearca.");
    }
}

void afisareContacte(){
    int i;
    for(i=0; i<cont; i++){
        printf("Contactul cu numarul: %d \n", i+1);
        printf("Nume: %s ; Prenume: %s ; Telefon: %s.\n",
                agenda[i].nume, agenda[i].prenume, agenda[i].telefon);
    }
}

int cauta(char nume[15], char prenume[15]){

    int x, index = -1;

    for(x=0; x<cont; x++){
        if(strcmp(nume, agenda[x].nume) == 0){
            if(strcmp(prenume, agenda[x].prenume) == 0)
                index = x;
        }
    }
    return index;

}

void stergeContact(){

    int x=0, i=0;
    char nume[15], prenume[15];

    printf("Introduce-ti numele: ");
    scanf("%s", &nume);
    printf("Introduce-ti prenumele: ");
    scanf("%s", &prenume);

    if((x = cauta(nume, prenume)) != -1 ){
        for(i=x; i<cont-1; i++){
            strcmp(agenda[i].nume, agenda[i+1].nume);
            strcmp(agenda[i].prenume, agenda[i+1].prenume);
            strcmp(agenda[i].telefon, agenda[i+1].telefon);
        }
        puts("Contactul a fost sters din agenda.");
        --cont;
        return;
    } else {
        puts("Contactul nu a fost gasit mai incercati!");
    }
}

void adaugaContact(){

    cont++;

    printf("Introduce-ti numele: ");
    scanf("%s", &agenda[cont-1].nume);

    printf("Introduce-ti prenumele: ");
    scanf("%s", &agenda[cont-1].prenume);

    printf("Introduce-ti numarul de telefon: ");
    scanf("%s", &agenda[cont-1].telefon);

    puts("Contactul a fost adaugat cu succes!");
}
