#include <iostream>
#include "GuessNumber.h"

using namespace std;

int main()
{
    cout << "Hello world, from GuessNumber" << endl;
    cout << "** mhcrnl's guess number game **\n";
    cout << "The goal of this game is to guess a number. You will be ask to type\n";
    cout << "a number (you have 5 guess)\n";
    cout << "Jackpot will then tell you if this number is too big of too small ";
    cout <<  "compared to the secret number to find\n\n";
    GuessNumber gn;
    gn.Start();

    return 0;
}
