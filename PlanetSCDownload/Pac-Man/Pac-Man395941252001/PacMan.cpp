#include"e:\tcc\bin\pcman\extra.hpp"
#include"e:\tcc\bin\pcman\point.hpp"
#include"e:\tcc\bin\pcman\figures.hpp"

#include<bios.h>
#include<conio.h>
#include<stdlib.h>

#define NORMAL  24
#define BLASTED 13
#define DELAY   130

Points point;
class Muncher;

class Eater{
	int ex,ey;
	int bex,bey;
	int pdir;
	static char status;
	static int count;
	int working;
	static int workCount;
	PicturePtr eater;
	static Picture blastedEater;
	Muncher* target;
	public:
		Eater(const char*,Muncher*);
		~Eater();
		void resetPosition();
		void clearPosition();
		void sendHome(int,int);
		int isPossible(int);
		static void blastEaters();
		int checkGameStatus();
		void move(int);
		void init1();
		void init2();
		 int attack1();
		 int attack2();
		 int attack3();
		void getXY(int&,int&);
};


class Muncher{
	int mx,my;
	PicturePtr mu,mr,md,ml;
	public:
		Muncher();
		~Muncher();
		void resetPosition();
		int isPossible(int);
		 int moveUp();
		 int moveLeft();
		 int moveRight();
		 int moveDown();
		void getXY(int&,int&);
};

Muncher::Muncher() {
	mx = 11;
	my = 9;
	mu = new Picture(SIZE,mUp);
	mr = new Picture(SIZE,mRight);
	md = new Picture(SIZE,mDown);
	ml = new Picture(SIZE,mLeft);
}

Muncher::~Muncher() {
	mx = 0;
	my = 0;
	if(mu) delete mu;
	if(mr) delete mr;
	if(md) delete md;
	if(ml) delete ml;
}

void Muncher::resetPosition() {
	mx = 11;
	my = 9;
	mr->displayPicture(mx,my);
}

inline void Muncher::getXY(int& x,int& y) {
	x = mx;
	y = my;
}

int Muncher::isPossible(int dir) {
if(mx%12 !=0 || my%12 != 0) return 0;
int returnValue = 1;
      switch(dir) {
	case UPDIR :
		returnValue = (Level::getValue(mx,my-1)!=1);
		break;
	case DOWNDIR:
		returnValue = (Level::getValue(mx,my+1)!=1);
		break;
	case RIGHTDIR:
		returnValue = (Level::getValue(mx+1,my)!=1);
		break;
	case LEFTDIR:
		returnValue = (Level::getValue(mx-1,my)!=1);
		break;
      }
return returnValue;
//to make sure a turning takes place only at the corner (a multiple of PICSIZE)
 //this is true. Think about it till u r sure if you change it.
}

 int Muncher::moveUp(void) {
	switch(Level::getValue(mx,my-1)) {
		case 2:
			point.increment(10);
			Level::decrement();
			Level::setValue(mx,my-1,0);
			sound(200);delay(4);nosound();
			//no break required here.
		case 0:
			mu->clearPicture(mx,my);
			mu->displayPicture(mx,--my);
			break;
		case 5:
			point.increment(50);
			Level::setValue(mx,my-1,0);
			Eater::blastEaters();
			sound(700);delay(60);nosound();
			mu->clearPicture(mx,my);
			mu->displayPicture(mx,--my);
			break;
		case 1: break;
		default : break;
	}
	return (Level::getPixelCount()==0);
}

 int Muncher::moveDown(void) {
	switch(Level::getValue(mx,my+1)) {
		case 2:
			point.increment(10);
			Level::decrement();
			Level::setValue(mx,my+1,0);
			sound(200);delay(4);nosound();
			//no break required here.
		case 0:
			md->clearPicture(mx,my);
			md->displayPicture(mx,++my);
			break;
		case 5:
			point.increment(50);
			Level::setValue(mx,my+1,0);
			Eater::blastEaters();
			sound(700);delay(60);nosound();
			md->clearPicture(mx,my);
			md->displayPicture(mx,++my);
			break;
		case 1: break;
		default : break;
	}
	return (Level::getPixelCount()==0);
}

 int Muncher::moveRight(void) {
	switch(Level::getValue(mx+1,my)) {
		case 2:
			point.increment(10);
			Level::decrement();
			Level::setValue(mx+1,my,0);
			sound(200);delay(4);nosound();
			//no break required here.
		case 0:
			mr->clearPicture(mx,my);
			mr->displayPicture(++mx,my);
			break;
		case 5:
			point.increment(50);
			Level::setValue(mx+1,my,0);
			Eater::blastEaters();
			sound(700);delay(60);nosound();
			mr->clearPicture(mx,my);
			mr->displayPicture(++mx,my);
			break;
		case 1: break;
		default : break;
	}
	return (Level::getPixelCount()==0);
}

 int Muncher::moveLeft(void) {
	switch(Level::getValue(mx-1,my)) {
		case 2:
			point.increment(10);
			Level::decrement();
			Level::setValue(mx-1,my,0);
			sound(200);delay(4);nosound();
			//no break required here.
		case 0:
			ml->clearPicture(mx,my);
			ml->displayPicture(--mx,my);
			break;
		case 5:
			point.increment(50);
			Level::setValue(mx-1,my,0);
			Eater::blastEaters();
			sound(700);delay(60);nosound();
			ml->clearPicture(mx,my);
			ml->displayPicture(--mx,my);
			break;
		case 1: break;
		default : break;
	}
	return (Level::getPixelCount()==0);
}

char Eater::status = NORMAL;
int Eater::count = 0;
int Eater::workCount = 0;
Picture Eater::blastedEater(SIZE,eaterdb);

Eater::Eater(const char* pptr,Muncher* tgt) {
	eater = new Picture(SIZE,pptr);
	ex = 0;
	ey = 0;
	pdir = RIGHT;
	target = tgt;
	working = 0;
}

Eater::~Eater() {
	if(eater) delete eater;
	ex = 0;
	ey = 0;
	count = 0;
	pdir = 0;
	eater = 0;
	target = 0;
	working = 0;
}

void Eater::clearPosition() {
	eater->clearPicture(ex,ey);
	Extras::displayExtra(ex,ey);
}

void Eater::sendHome(int a,int b) {
	ex = bex = a;
	ey = bey = b;
	eater->displayPicture(ex,ey);
	working = 0;
}

void Eater::resetPosition() {
	eater->clearPicture(ex,ey);
	ex = 11;
	ey = 5;
	if(status == NORMAL)
		eater->displayPicture(ex,ey);
	else blastedEater.displayPicture(ex,ey);
	working = 1;
}

inline void Eater::getXY(int& x,int& y) {
	x = ex;
	y = ey;
}

int Eater::isPossible(int dir) {
int returnValue = 1;
      switch(dir) {
	case UP :
//		if(ey%SIZE == 0)
		returnValue = (Level::getValue(ex,ey-1)!=1);
//		else return 0;
		break;
	case DOWN:
//		if(ey%SIZE == 0)
		returnValue = (Level::getValue(ex,ey+1)!=1);
//		else return 0;
		break;
	case RIGHT:
//		if(ex%SIZE == 0)
		returnValue = (Level::getValue(ex+1,ey)!=1);
//		else return 0;
		break;
	case LEFT:
//		if(ex%SIZE == 0)
		returnValue = (Level::getValue(ex-1,ey)!=1);
//		else return 0;
		break;
      }
//to make sure a turning takes place only at the corner (a multiple of PICSIZE)
   return returnValue;
//this is true. Think about it till u r sure if you change it.
}

void Eater::blastEaters() {
	status = BLASTED;
	count = 1;
}

void Eater::move(int dir) {
// 65 i.e waiting for approx 8 secs.
if(count == 0 || count == 78) {
       count = 0; status = NORMAL;
}
else count++;
	switch(dir) {
		case UP :
			eater->clearPicture(ex,ey);
			Extras::displayExtra(ex,ey);
			if(status == NORMAL)
			eater->displayPicture(ex,--ey);
			else blastedEater.displayPicture(ex,--ey);
			break;
		case DOWN :
			eater->clearPicture(ex,ey);
			Extras::displayExtra(ex,ey);
			if(status == NORMAL)
			eater->displayPicture(ex,++ey);
			else blastedEater.displayPicture(ex,++ey);
			break;
		case RIGHT :
			eater->clearPicture(ex,ey);
			Extras::displayExtra(ex,ey);
			if(status == NORMAL)
			eater->displayPicture(++ex,ey);
			else blastedEater.displayPicture(++ex,ey);
			break;
		case LEFT :
			eater->clearPicture(ex,ey);
			Extras::displayExtra(ex,ey);
			if(status == NORMAL)
			eater->displayPicture(--ex,ey);
			else blastedEater.displayPicture(--ex,ey);
			break;
	}
}

void Eater::init1() {
	if(pdir == UP || pdir == DOWN) {
		if(isPossible(RIGHT)) pdir = RIGHT;
		if(isPossible(LEFT)) pdir = LEFT;
	}
	else {
		if(isPossible(UP)) pdir = UP;
		if(isPossible(DOWN)) pdir = DOWN;
	}
	this->move(pdir);
}

void Eater::init2() {
	if(pdir == UP || pdir == DOWN) {
		if(isPossible(LEFT)) pdir = LEFT;
		if(isPossible(RIGHT)) pdir = RIGHT;
	}
	else {
		if(isPossible(DOWN)) pdir = DOWN;
		if(isPossible(UP)) pdir = UP;
	}
	this->move(pdir);
}

int Eater::checkGameStatus() {
	int mx,my;
	target->getXY(mx,my);
	if(mx == ex && my == ey) {
		if(status == NORMAL) {
				sound(600);delay(100);sound(350);delay(100);
				sound(200);delay(200);
				nosound();
				return 1;
		}
		else {
			sound(200);delay(200);sound(500);delay(300);nosound();
			sendHome(bex,bey);
			point.increment(250);
		}
	}
	return 0;
}

int Eater::attack1() {
	if(checkGameStatus()) return 1;
	if(working == 0) {
		workCount++;
		if(workCount%40 == 0) { workCount++; resetPosition(); }
		return 0;
	}
	if(random(100)%4 == 0) init1();
	else init2();
	if(checkGameStatus()) return 1;
	return 0;
}

int Eater::attack2() {
	if(checkGameStatus()) return 1;
	if(working == 0) {
		workCount++;
		if(workCount%40 == 0) { workCount++; resetPosition(); }
		return 0;
	}
	int x = random(100)%5;
	if( x == 2 || x == 3) init2();
	else init1();
	if(checkGameStatus()) return 1;
	return 0;
}

int Eater::attack3() {
	if(checkGameStatus()) return 1;
	if(working == 0) {
		workCount++;
		if(workCount%40 == 0) { resetPosition(); workCount++; }
		return 0;
	}
	int x = random(100)%7;
	if(x&1 == 1) init1();
	else init2();
	if(checkGameStatus()) return 1;
	return 0;
}

Muncher muncher;
Eater eater1(eaterr,&muncher),eater2(eaterg,&muncher),eater3(eaterb,&muncher);

void getSpaceBar() {
	char c;
	while(1) {
		c = getch();
		if(c==' ')break;
	}
}

void main() {
Gr::setMode(GRAPHIC);
Font::initFont();
Font::displayString(17,14,"PAC MAN");
getSpaceBar();
Gr::fillScreen(0);
//startup
int end=0;
int levelEnd=1;
int x=0;
int bypass=0;
chances.displayPict();
Font::displayString(26,27,"SCORE");
Font::displayString(41,02,"LEVEL");
while(1) {///no of chances loop;  //3 chances
if(levelEnd == 1) {
	Font::displayString(8,13,"PRESS SPACE BAR TO CONTINUE");
	getSpaceBar();
	if(!Level::setLevel())
		break;
}
muncher.resetPosition();
eater1.sendHome(10,7);
eater2.sendHome(11,7);
eater3.sendHome(12,7);
end=0;
levelEnd=0;
x=RIGHTDIR;
bypass=1;
while(1) {
	if(bypass == 0)
		x = bioskey(0);
	bypass=0;
	switch(x) {
		case UPDIR :
			while(1) {
			while(!kbhit()) {
				if(eater1.attack1()) { end = 1; break; }
				if(eater2.attack2()) { end = 1; break; }
				if(eater3.attack3()) { end = 1; break; }
				if(muncher.moveUp()) { levelEnd = 1; break;}
				delay(DELAY);
			}
			if(end == 1 || levelEnd == 1) break;
			x = bioskey(0);
			if(x!=UPDIR&&muncher.isPossible(x)) { bypass=1; break;}
			}
			break;
		case DOWNDIR:
			while(1) {
			while(!kbhit()) {
				if(eater1.attack1()) { end = 1; break; }
				if(eater2.attack2()) {end = 1; break;}
				if(eater3.attack3()) { end = 1; break;}
				if(muncher.moveDown()) {levelEnd = 1; break;}
				delay(DELAY);
			}
			if(end == 1 || levelEnd == 1) break;
			x = bioskey(0);
			if(x!=DOWNDIR&&muncher.isPossible(x)) {bypass=1; break;}
			}
			break;
		case RIGHTDIR:
			while(1) {
			while(!kbhit()) {
				if(eater1.attack1()) { end = 1; break; }
				if(eater2.attack2()) {end = 1; break;}
				if(eater3.attack3()) { end = 1; break;}
				if(muncher.moveRight()) {levelEnd =1; break;}
				delay(DELAY);
			}
			if(end == 1 || levelEnd == 1) break;
			x = bioskey(0);
			if(x!=RIGHTDIR&&muncher.isPossible(x)) {bypass=1; break;}
			}
			break;
		case LEFTDIR :
			while(1) {
			while(!kbhit()) {
				if(eater1.attack1()) { end = 1; break; }
				if(eater2.attack2()) {end = 1; break;}
				if(eater3.attack3()) { end = 1; break;}
				if(muncher.moveLeft()) {levelEnd = 1; break;}
				delay(DELAY);
			}
			if(end == 1 || levelEnd == 1) break;
			x = bioskey(0);
			if(x!=LEFTDIR&&muncher.isPossible(x)) {bypass=1; break;}
			}
			break;
		case 0x4400:	end = 1;
				chances.setValue(1);
				break;
		default:
				//Eater::blastEaters();
				break;
	}
	if(end==1) {
		eater1.clearPosition();
		eater2.clearPosition();
		eater3.clearPosition();
		break;
	}
	if(levelEnd == 1) {
			point.increment(500);
			sound(1000);delay(300);
			sound(1000);delay(300);
			sound(1000);delay(300);nosound();
			break;
	}
}
if(levelEnd == 0) {
	chances.decrement();
	if(chances.getValue() == 0) break;
}
}
//shutdown()
Gr::fillScreen(0);
Font::displayString(15,20,"WRITTEN BY MANTRAVADI ÊRALI");
Font::displayString(8,11,"PRESS SPACE TO QUIT");
getSpaceBar();
Font::deinitFont();
Gr::setMode(TEXT);
}