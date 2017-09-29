#ifndef RUN_MAIN_H_INCLUDED
#define RUN_MAIN_H_INCLUDED
/* INCLUDES */
#include <stdlib.h>		/* rand, srand */
#include <unistd.h>		/* getopt */
#include <ncurses.h>	/* ncurses */
#include <time.h>		/* time */
#include <string.h>		/* strcmp, strlen */
#include "sudoku.h"		/* sudoku functions */

/* DEFINES */
//#define VERSION				"0.1" //gets set via autotools
#define GRID_LINES			19
#define GRID_COLS			37
#define GRID_Y				3
#define GRID_X				3
#define INFO_LINES			19
#define INFO_COLS			20
#define INFO_Y				3
#define INFO_X				GRID_X + GRID_COLS + 5
#define GRID_NUMBER_START_Y 1
#define GRID_NUMBER_START_X 2
#define GRID_LINE_DELTA		4
#define GRID_COL_DELTA		2
#define STATUS_LINES		1
#define STATUS_COLS			GRID_COLS + INFO_COLS
#define STATUS_Y			1
#define STATUS_X			GRID_X
#define MAX_HINT_RANDOM_TRY	20
#define SUDOKU_LENGTH		STREAM_LENGTH - 1

#ifdef DEBUG
#define EXAMPLE_STREAM "4.....8.5.3..........7......2.....6.....8.4......1.......6.3.7.5..2.....1.4......"
#endif // DEBUG

/* GLOBALS */
static bool g_useColor = true;
static bool g_playing = false;
static char* g_provided_stream; /* in case of -s flag the user provides the sudoku stream */
static char plain_board[STREAM_LENGTH];
static char user_board[STREAM_LENGTH];
static DIFFICULTY g_level = D_EASY;
static WINDOW *grid, *infobox, *status;

static void print_version(void);
static void print_usage(void);
static bool is_valid_stream(char *s);
static void parse_arguments(int argc, char *argv[]);
static void cleanup(void);
static void init_curses(void);
static void _draw_grid();
static void init_windows(void);
static void fill_grid(char *board);
static void new_puzzle(void);
static bool hint(void);
int runMain(void);
#endif // RUN_MAIN_H_INCLUDED
