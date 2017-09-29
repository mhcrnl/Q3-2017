#ifndef _POINTPCMAN_
#define _POINTPCMAN_
#include"e:\tcc\bin\pcman\Number.hpp"
#include"e:\tcc\bin\pcman\lives.hpp"
class Points{
	int points;
	int scale;
	public:
		Points();
		~Points();
		void increment(int);
};
Points::Points() {
	points = 0;
	scale = 1;

}
Points::~Points() {
	points = 0;
	scale = 0;
}
void Points::increment(int x) {
	points+=x;
	if(points>=(4000*scale))  {
		chances.increment();
		scale++;
	}
	Font::displayNumber(53,38,5,points);
}

#endif