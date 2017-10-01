#include <iostream>

using namespace std;

int main()
{
    cout << "Hello world, from Cpp Lambda!" << endl;
    /**
        Functiile lambda incep cu []
    */
    auto func = [](){cout<<"Salut, lambda!";};
    func();

    return 0;
}
