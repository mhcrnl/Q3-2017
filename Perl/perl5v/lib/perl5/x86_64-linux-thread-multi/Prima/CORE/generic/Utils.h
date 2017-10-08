/* This file was automatically generated.
 * Do not edit, you'll loose your changes anyway.
 * file: Utils.h  */
#ifndef Utils_H_
#define Utils_H_
#ifndef _APRICOT_H_
#include "apricot.h"
#endif

#ifdef __cplusplus
extern "C" {
#endif

extern void register_Utils_Package( void);

/* Local methods definitions */
extern SV * Utils_query_drives_map( char * firstDrive );
extern int Utils_get_os( );
extern int Utils_get_gui( );
extern long Utils_ceil( double x );
extern long Utils_floor( double x );


#ifdef __cplusplus
}
#endif
#endif
