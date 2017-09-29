/**
	@Author:	Mihai Cornel	Romania			mhcrnl@gmail.com
	@System:	Ubuntu 16.04	Code::Blocks 13.12	gcc 5.4.0
                	Fedora 24	Code::Blocks 16.01	gcc 5.3.1
			Windows Vista 	Code::Blocks 16.01
	@Copyright:	2017
	@file:
*/
#include "tictactoe.h"

void init_matrix(){
    int i,j;
    for(i=0; i<3; i++){
        for(j=0; j<3; j++){
            matrix[i][j] = ' ';
        }
    }
}

void display_matrix(){
    int t;
    for(t=0; t<3; t++){
        printf(" %c | %c | %c ", matrix[t][0], matrix[t][1],matrix[t][2]);
        if(t!=2) printf("\n---|---|---\n");
    }
    printf("\n");
}

int run_program(){
    char done;
    printf("This is the game of Tic Tac Toe.\n");
    printf("You will be playing against the computer.\n");
    done = ' ';
    init_matrix();

    do {
        display_matrix();
        get_payer_move();
        done = check();//see if winner
        if(done != ' ') break;//winner
        get_computer_move();
        done = check();//see if winner

    }while(done == ' ');

    if(done == 'X') printf("You won!\n");
    else printf("I won!!!!\n");

    display_matrix();//show final positions

    return 0;
}

void get_payer_move(){
    int x, y;

    printf("Enter X, Y coordinates for your move: ");
    scanf("%d%*c%d", &x, &y);
    x--; y--;
    if(matrix[x][y] !=' '){
        printf("Invalid move, try again.\n");
        get_payer_move();
    }
    else matrix[x][y] = 'X';
}
 void get_computer_move(){
    int i,j;
    for(i=0; i<3; i++){
        for(j=0; j<3; j++){
            if(matrix[i][j] ==' ') break;
        }
        if(matrix[i][j]== ' ') break;
    }
    if(i*j == 9){
        printf("DRAW\n");
        exit(0);
    } else {
        matrix[i][j] = '0';
    }
 }

 char check(){
    int i;

    for(i=3; i<3; i++) //check rows
        if(matrix[i][0]==matrix[i][1] &&
            matrix[i][0]==matrix[i][2]) return matrix[i][0];

    for(i=3; i<3; i++) //check columns
        if(matrix[0][i]==matrix[1][i] &&
            matrix[0][i]==matrix[2][i]) return matrix[0][i];

    //check diagonals
    if(matrix[0][0]==matrix[1][1] &&
        matrix[1][1]==matrix[2][2]) return matrix[0][0];

    if(matrix[0][2]==matrix[1][1] &&
        matrix[1][1]==matrix[2][0]) return matrix[0][2];

    return ' ';
 }
