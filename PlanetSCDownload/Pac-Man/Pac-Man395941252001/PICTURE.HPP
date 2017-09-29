#ifndef _PCMANPICTURE_
#define _PCMANPICTURE_
#include"e:\tcc\bin\pcman\graphic.hpp"
//all pictures are of size 12x12
//#define PICSIZE 12
//the class Picture.
class Picture{
	protected:
	//the actual picture array.
	int picSize;
	const char* array;
	public:
		//creates a picture with the specified array.
		Picture(int,const char*);
		//destructs the picture.
		~Picture();
		//displays the picture at the given x,y.
		void displayPicture(int,int);
		//clears the picture at the given x,y.
		void clearPicture(int,int);
};
typedef Picture* PicturePtr;

Picture::Picture(int size,const char* arr) {
	array =  arr;
	picSize = size;
}

Picture::~Picture() {
	array = 0;
	picSize = 0;
}

void Picture::displayPicture(int px,int py) {
	int base=0;
	px*=picSize;py*=picSize;
	//draws the picture pixel by pixel as if it was a rectangle.
	for(int i=0;i<picSize;i++) {
		base = i*picSize;
		for(int j=0;j<picSize;j++)
			Gr::putPixel(px+j,py+i,array[base+j]);
	}
}

void Picture::clearPicture(int px,int py) {
	// clears by drwaing a black rectangle at the given x,y.
	px*=picSize;py*=picSize;
	for(int i=0;i<picSize;i++) {
		for(int j=0;j<picSize;j++)
			Gr::putPixel(px+j,py+i,0);
	}
}

#endif