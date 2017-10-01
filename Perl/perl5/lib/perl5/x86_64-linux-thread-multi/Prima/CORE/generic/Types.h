/* This file was automatically generated.
 * Do not edit, you'll loose your changes anyway.
 * file: Types.h  */
#ifndef TYPES_H_
#define TYPES_H_
#ifndef _APRICOT_H_
#include "apricot.h"
#endif

#ifdef __cplusplus
extern "C" {
#endif
typedef struct _Point {
	int x;
	int y;
} Point, *PPoint;

extern Point Point_buffer;

typedef struct _Rect {
	int left;
	int bottom;
	int right;
	int top;
} Rect, *PRect;

extern Rect Rect_buffer;

typedef struct _Font {
	int height;
	int width;
	int style;
	int pitch;
	double direction;
	int resolution;
	char name[256];
	int size;
	char encoding[256];
	char family[256];
	int vector;
	int ascent;
	int descent;
	int weight;
	int maximalWidth;
	int internalLeading;
	int externalLeading;
	int xDeviceRes;
	int yDeviceRes;
	int firstChar;
	int lastChar;
	int breakChar;
	int defaultChar;
	int utf8_flags;
} Font, *PFont;

extern Font * SvHV_Font( SV * hashRef, Font * strucRef, char * errorAt);
extern SV * sv_Font2HV( Font * strucRef);
extern Font Font_buffer;

typedef struct _NPoint {
	double x;
	double y;
} NPoint, *PNPoint;

extern NPoint NPoint_buffer;

typedef struct _PrinterInfo {
	char name[256];
	char device[256];
	Bool defaultPrinter;
} PrinterInfo, *PPrinterInfo;

extern PrinterInfo * SvHV_PrinterInfo( SV * hashRef, PrinterInfo * strucRef, char * errorAt);
extern SV * sv_PrinterInfo2HV( PrinterInfo * strucRef);
extern PrinterInfo PrinterInfo_buffer;

typedef U8 FillPattern[ 8];
extern FillPattern FillPattern_buffer;




#ifdef __cplusplus
}
#endif
#endif
