#ifndef TICTACTOE_H_INCLUDED
#define TICTACTOE_H_INCLUDED

#include <stdio.h>
#include <stdlib.h>

char matrix[3][3];

int run_program(void);
void init_matrix(void);
void get_payer_move(void);
void get_computer_move(void);
void display_matrix(void);
char check(void);

#endif // TICTACTOE_H_INCLUDED
