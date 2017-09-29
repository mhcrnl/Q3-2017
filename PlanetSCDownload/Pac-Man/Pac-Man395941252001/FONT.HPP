#ifndef _FNTPCMAN_
#define _FNTPCMAN_
#include"e:\tcc\bin\pcman\alpha.hpp"
#include"e:\tcc\bin\pcman\Number.hpp"
class Font {
	private:
		Font();
		~Font();
	public:
		static void initFont();
		static void deinitFont();
		static void displayString(int,int,const char*);
		static void displayNumber(int,int,int,int);
};
void Font::initFont(void) {
	Alphabets::initialize();
	Numbers::initialize();
}

void Font::deinitFont(void) {
	Alphabets::deinitialize();
	Numbers::deinitialize();
}

void Font::displayString(int x,int y,const char* string) {
	Alphabets::displayText(x,y,string);
}

void Font::displayNumber(int x,int y,int digits,int number) {
	Numbers::displayDigits(x,y,digits,number);
}

#endif


