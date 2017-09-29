#ifndef GUESSNUMBER_H
#define GUESSNUMBER_H

#include <iostream>

using namespace std;

class GuessNumber
{
    int  i, j, life, maxv;
    char c;

    public:
        GuessNumber();
        virtual ~GuessNumber();

        void Start();
        void GetResults();
    protected:

    private:
};

#endif // GUESSNUMBER_H
