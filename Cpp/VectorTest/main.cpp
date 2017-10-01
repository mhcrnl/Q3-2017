#include <iostream>
#include <vector>

using namespace std;

class Rectangle{
    int width, height;
public:
    void set_value(int, int);
    int area(){
        return width*height;
    }
};

void Rectangle::set_value(int x, int y){
    width = x;
    height = y;
}

int main()
{
    cout << "Hello world, from Vector test!" << endl;
    //use constructors from vector class
    vector<int> vint;
    vector<double> vdouble(4, 2.34);
    vector<float> vfloat(vdouble.begin(), vdouble.end());
    vector<char> vchar={'a', 'b', 'c','d'};
    //add element to vector vint
    vint.push_back(2);
    vint.push_back(10);
    //iterate in vector and print elements
    cout<<"The content of vector vint: ";
    for(vector<int>::iterator it = vint.begin(); it!=vint.end(); ++it)
        cout<<" "<<*it;
    cout<<"\n";

    cout<<"The content of vector vdouble: ";
    for(vector<double>::iterator it = vdouble.begin(); it!=vdouble.end(); ++it)
        cout<<" "<<*it;
    cout<<"\n";

    cout<<"The content of vector vfloat: ";
    for(vector<float>::iterator it = vfloat.begin(); it!=vfloat.end(); ++it)
        cout<<" "<<*it;
    cout<<"\n";

    cout<<"The content of vector vchar: ";
    for(vector<char>::iterator it = vchar.begin(); it!=vchar.end(); ++it)
        cout<<" "<<*it;
    cout<<"\n";

    Rectangle rect;
    rect.set_value(2,8);
    cout<<"Area: "<< rect.area()<<endl;

    vector<Rectangle> vrects;
    vrects.push_back(rect);

    cout<<"The content of vector vrects: ";
    for(vector<Rectangle>::iterator it = vrects.begin(); it!=vrects.end(); ++it)
        cout<<" "<<(*it).area();
    cout<<"\n";

    return 0;
}
