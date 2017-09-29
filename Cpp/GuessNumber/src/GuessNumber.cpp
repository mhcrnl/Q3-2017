/**
	@Author:	Mihai Cornel	Romania			mhcrnl@gmail.com
	@System:	Ubuntu 16.04	Code::Blocks 13.12	gcc 5.4.0
                	Fedora 24	Code::Blocks 16.01	gcc 5.3.1
			Windows Vista 	Code::Blocks 16.01
	@Copyright:	2017
	@file:
*/

#include "GuessNumber.h"

void GuessNumber::GetResults()
{
     if (life <= 0)
        // if player has no more life then he lose
     {
        cout << "You lose !\n\n";
        Start();
     }

     cout << "Type a number: \n";
     cin >> i;          // read user's number

     if ((i>maxv) || (i<0)) // if the user number isn't correct, restart
     {
        cout << "Error : Number not between 0 and \n" << maxv;
        GetResults();
     }

     if (i == j)
     {
        cout << "YOU WIN !\n\n"; // the user found the secret number
        Start();
     }

     else if (i>j)
     {
        cout << "Too BIG\n";
        life = life - 1;    // -1 to the user's "life"
        cout << "Number of remaining life: " << life << "\n\n";
        GetResults();
     }

     else if (i<j)
     {
        cout << "Too SMALL\n";
        life = life - 1;
        cout << "Number of remaining life:\n" << life << "\n\n";
        GetResults();
     }
}

void GuessNumber::Start()
{
     i = 0;
     j = 0;
     life = 0;
     maxv = 6;

     cout << "Select difficulty mode:\n"; // the user has to select a difficutly level
     cout << "1 : Easy (0-15)\n";
     cout << "2 : Medium (0-30)\n";
     cout << "3 : Difficult (0-50)\n";
     cout << "or type another key to quit\n";

     cin >> c;                   // read the user's choice
     cout << "\n";

     switch (c)
     {
        case '1' : maxv = 15;  // the random number will be between 0 and max
        break;
        case '2' : maxv = 30;
        break;
        case '3' : maxv = 50;
        break;
        default : exit(0);
        break;
     }

     life = 5;         // number of lifes of the player
     srand( (unsigned)time( NULL ) ); // init Rand() function
     j = rand() % maxv;  // j get a random value between 0 and max

     GetResults();

}

GuessNumber::GuessNumber()
{
    //ctor
}

GuessNumber::~GuessNumber()
{
    //dtor
}
