#ifndef _PCMANLEVEL_
#define _PCMANLEVEL_
#include"e:\tcc\bin\pcman\picture.hpp"
#include"e:\tcc\bin\pcman\font.hpp"
#include<conio.h>
#include<string.h>
#include<stdlib.h>
#include<fstream.h>
//width of the maze.
#define WIDTH 23
//height of the maze.
#define HEIGHT 15
//sets the Pixel color i.e is to be eaten.
#define PIXEL_COLOR 97
#define SIZE  12
// the direction values.
#define UP    0
#define RIGHT 1
#define DOWN  2
#define LEFT  3

#define UPDIR    0x4800
#define DOWNDIR  0x5000
#define RIGHTDIR 0x4d00
#define LEFTDIR  0x4b00

//walls must be a two dimensional array
// so as to allow each level to have a different wall tile.
const char boost[] ={
0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,4,4,0,0,0,0,0,
0,0,0,0,0,4,4,0,0,0,0,0,
0,0,0,4,4,4,4,4,4,0,0,0,
0,0,0,4,4,4,4,4,4,0,0,0,
0,0,0,0,0,4,4,0,0,0,0,0,
0,0,0,0,0,4,4,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0
};
Picture booster(SIZE,boost);

//levels must be a two dimensional array
// so as to allow each level to have a different maze.
// the class for all the levels;
class Level{
	private:
		static char presentLevel[345];     //points to the present maze
		static char presentWall[144];
		static int levelNo;
		static int numPixels;         //the number of pixels in present maze
		static int  readLevelData();
		static int  readWallData();
	public:
		//the level default constructor.
		Level();
		//the level destructor.
		~Level();
		//sets the level Number.
		static  int setLevel(void);
		//gets the value at a given point in the present Maze.
		static unsigned char getValue(int,int);
		//sets the value at a given point in the present Maze.
		static void setValue(int,int,unsigned char);
		// returns the number of pixels i.e value of numPixels.
		static int getPixelCount();
		// decrements the numPixels value by 1.
		static void decrement();
};

char Level::presentLevel[345] = {0};
char Level::presentWall[144] = {0};
int Level::numPixels = 0;
int Level::levelNo = 0;

Level::Level() {
	numPixels = 0;
	levelNo = 0;
}

Level::~Level() {
	numPixels = 0;
	levelNo = 0;
}

inline unsigned char Level::getValue(int x,int y) {
	return presentLevel[y*WIDTH+x];
}

inline void Level::setValue(int x,int y,unsigned char value) {
	presentLevel[y*WIDTH+x] = value;
}

inline int Level::getPixelCount(void) {
	return numPixels;
}

inline void Level::decrement(void) {
	numPixels--;
}

int Level::readLevelData() {
	char filename[12] ={"Level"};
	char temp[3];
	itoa(levelNo,temp,10);
	strcat(filename,temp);
	strcat(filename,".lvl");
	ifstream in(filename);
	if(!in) {
//		Gr::setMode(TEXT);
//		cout<<"\n Required Level file is Not present";
		return 0;
	}
	for(int i=0;i<345;i++) {
		presentLevel[i] = in.get() - 48;
	}
	in.close();
	return 1;
}

int Level::readWallData() {
	char filename[11] ={"Wall"};
	char temp[3];
	itoa(1,temp,10);
	strcat(filename,temp);
	strcat(filename,".wal");
	ifstream in(filename);
	if(!in) {
//		Gr::setMode(TEXT);
//		cout<<"\n Required Wall file is Not present";
		return 0;
	}
	for(int i=0;i<144;i++) {
		presentWall[i] = in.get() - 48;
	}
	in.close();
	return 1;
}

int Level::setLevel(void) {
	//presently level number is not implemented.
	Gr::fillScreen(0,0,276,180,0);
	levelNo++;
	Font::displayNumber(62,5,2,levelNo);
	if(!readLevelData()) return 0;
	if(!readWallData()) return 0;
//	presentLevel = levels;
	//presentWall points to the present wall Tile.
	PicturePtr presentWallPic = new Picture(SIZE,presentWall);  //WALLSZ = 12
	int temp=0;
	//draws the complete Maze.
	for(int i=0;i<HEIGHT;i++) {
		temp = i*WIDTH;
		for(int j=0;j<WIDTH;j++) {
//			delay(80);
			switch(presentLevel[temp+j]) {
				case 1: //if wall is to be present.
					presentWallPic->displayPicture(j,i);
					break;
				case 2: //if a Pixel is to be present.
					Gr::putPixel(j*SIZE+6,i*SIZE+6,PIXEL_COLOR);
					numPixels++;
					break;
				case 5:
					booster.displayPicture(j,i);
					break;
				case 9:
					presentLevel[temp+j] = 1;
					break;
				default://others.
					break;
			}
		}
	}
	delete presentWall;   //remove the space for the presentWall.
	return 1;
}

#endif