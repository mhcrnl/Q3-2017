#ifndef AGENDATELEFONICA_H_INCLUDED
#define AGENDATELEFONICA_H_INCLUDED

typedef struct contact {
    char nume[20];
    char prenume[20];
    char adresa[100];
    char orasul[25];
    char telefon[15];
} contact;

int  adaugaContact    (contact contacte[], int cont);
void afisareContacte  (contact contacte[], int cont);
void salveazaContacte (contact contacte[], char filename[], int cont);
#endif // AGENDATELEFONICA_H_INCLUDED
