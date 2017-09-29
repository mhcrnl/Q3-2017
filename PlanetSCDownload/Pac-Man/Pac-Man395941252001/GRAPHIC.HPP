#ifndef _PCMANGRAPHICS_
#define _PCMANGRAPHICS_
#include<dos.h>

#define GRAPHIC  0x13
#define TEXT     0x03


class Gr{
	private:
		static unsigned char* vga;
		Gr();
		~Gr();
	public:
		static void setMode(int);
		static void fillScreen(unsigned char);
		static void fillScreen(int,int,int,int,unsigned char);
		static void putPixel(int,int,unsigned char);
		static void drawRect(int,int,int,int,unsigned char);
};

unsigned char* Gr::vga = (unsigned char*)MK_FP(0xA000,0);

void Gr::setMode(int mode) {
	union REGS regs;
	regs.x.ax = mode;
	int86(0x10,&regs,&regs);
}

void Gr::fillScreen(int a,int b,int width,int height,unsigned char color) {
	int offset=0;
	for(int j=b;j<height;j++) {
		offset = (j<<6) + (j<<8);
		for(int i=a;i<width;i++)
			vga[i+offset] = color;
	}
}
void Gr::fillScreen(unsigned char color) {
	int offset=0;
	for(int j=199;j>=0;j--) {
		offset = (j<<6) + (j<<8);
		for(int i=319;i>=0;i--)
			vga[i+offset] = color;
	}
}

inline void Gr::putPixel(int px,int py,unsigned char color) {
	vga[px+(py<<6)+(py<<8)] = color;              		//px+py*320
}

void Gr::drawRect(int a,int b,int c,int d,unsigned char color) {
	for(int i=a;i<=c;i++)
		Gr::putPixel(i,b,color);
	for(i=a;i<=c;i++)
		Gr::putPixel(i,d,color);
	for(i=b;i<=d;i++)
		Gr::putPixel(a,i,color);
	for(i=b;i<=d;i++)
		Gr::putPixel(c,i,color);

}
#endif
