#ifndef _PCMANEXTRA_
#define _PCMANEXTRA_
#include"e:\tcc\bin\pcman\level.hpp"
class Extras{
	private:
		Extras();
		~Extras();
	public:
		static void displayExtra(int,int);
};

void Extras::displayExtra(int a,int b) {
	switch(Level::getValue(a,b)) {
		case 0:
			break;
		case 2:
			Gr::putPixel(a*SIZE+6,b*SIZE+6,PIXEL_COLOR);
			break;
		case 5:
			booster.displayPicture(a,b);
			break;
	}
}

#endif
