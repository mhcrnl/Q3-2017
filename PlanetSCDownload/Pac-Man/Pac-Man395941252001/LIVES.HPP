#ifndef _LIVEPCMAN_
#define _LIVEPCMAN_
const char mlive[] = {
0x00,0x00,0x0E,0x0E,0x0E,0x00,
0x00,0x0E,0x0E,0x0E,0x0E,0x0E,
0x0E,0x0E,0x0E,0x0E,0x00,0x00,
0x0E,0x0E,0x0E,0x0E,0x00,0x00,
0x00,0x0E,0x0E,0x0E,0x0E,0x0E,
0x00,0x00,0x0E,0x0E,0x0E,0x00
};
class Lives{
	int numLives;
	Picture *live;
	public:
		Lives(int,const char*);
		~Lives();
		void displayText();
		void displayPict();
		void decrement();
		void increment();
		int getValue();
		void setValue(int);
};


Lives::Lives(int a,const char* pict) {
 numLives = a-1;
 live = new Picture(6,pict);
}

Lives::~Lives() {
 if(live) delete live;
}

inline void Lives::decrement() {
	live->clearPicture(numLives*2+8-2,32);
	numLives--;
}

void Lives::increment() {
	if(numLives < 5) {
		numLives++;
	live->displayPicture(numLives*2+8-2,32);
	}
}

inline int Lives::getValue() {
	return numLives;
}

inline void Lives::setValue(int a) {
	numLives = a;
}

void Lives::displayPict() {
	Font::displayString(1,27,"LIVES");
	for(int i=0;i<numLives;i++)
		live->displayPicture(i*2+8,32);
}
Lives chances(3,mlive);
#endif