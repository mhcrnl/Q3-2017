#ifndef _NUMPCMAN_
#define _NUMPCMAN_
#include"e:\tcc\bin\pcman\picture.hpp"
const char numbers[][25] = {
{
41,41,41,41,41,
42,0,0,0,42,
43,0,0,0,43,
42,0,0,0,42,
41,41,41,41,41
},
{
0,0,0,0,41,
0,0,0,0,42,
0,0,0,0,43,
0,0,0,0,42,
0,0,0,0,41
},
{
41,41,41,41,41,
0,0,0,0,42,
43,43,43,43,43,
42,0,0,0,0,
41,41,41,41,41
},
{
41,41,41,41,41,
0,0,0,0,42,
43,43,43,43,43,
0,0,0,0,42,
41,41,41,41,41
},
{
41,0,0,0,41,
42,0,0,0,42,
43,43,43,43,43,
0,0,0,0,42,
0,0,0,0,41
},
{
41,41,41,41,41,
42,0,0,0,0,
43,43,43,43,43,
0,0,0,0,42,
41,41,41,41,41
},
{
41,41,41,41,41,
42,0,0,0,0,
43,43,43,43,43,
42,0,0,0,42,
41,41,41,41,41
},
{
41,41,41,41,41,
0,0,0,0,42,
0,0,0,0,43,
0,0,0,0,42,
0,0,0,0,41
},
{
41,41,41,41,41,
42,0,0,0,42,
43,43,43,43,43,
42,0,0,0,42,
41,41,41,41,41
},
{
41,41,41,41,41,
42,0,0,0,42,
43,43,43,43,43,
0,0,0,0,42,
41,41,41,41,41
}
};

class Numbers{
	static PicturePtr numPict[10];
	static void displayDigits(int,int,int,int);
	friend class Font;
	static void initialize();
	static void deinitialize();
};
PicturePtr Numbers::numPict[10]={0};

void Numbers::initialize() {
	if(numPict[0] == 0) {
		for(int i=0;i<10;i++)
		      numPict[i] = new Picture(5,numbers[i]);
	}
}

void Numbers::deinitialize() {
	if(numPict[0]) {
		for(int i=0;i<10;i++){
		      delete numPict[i];
		      numPict[i] = 0;
		 }
	}
}

void Numbers::displayDigits(int x,int y,int digit,int num) {
	for(int i=0;i<digit;i++)   {
	     numPict[num%10]->displayPicture(x-i*2,y);         //53,38
		num/=10;
	}
}
#endif