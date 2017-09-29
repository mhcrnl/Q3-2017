#include <stdio.h>
#include <stdlib.h>
#include <ncurses.h>

int main()
{
    printf("Hello world!\n");
    int ch;

    initscr();
    raw();
    keypad(stdscr, TRUE);
    noecho();
    printw("Salut Romania!");
    ch = getch();

    if(ch == KEY_F(1))
        printw("F1 key pressed");

    refresh();
    getch();
    endwin();
    return 0;
}
