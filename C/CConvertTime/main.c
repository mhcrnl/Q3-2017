#include <stdio.h>
#include <time.h>
#include <stdlib.h>

int main(int argc, char *argv[]) {
 struct tm *tm_ptr;
 time_t the_time;

 if(argc == 2)
  the_time = atoi(argv[1]);
 else
 (void)time(&the_time);

 tm_ptr = gmtime(&the_time);

 printf("raw `UTC' : %ld\n", the_time);
 printf("ctime     : %s", ctime(&the_time));
 printf("gmtime    : %02d:%02d:%02d - %02d/%02d/%02d\n",
    tm_ptr->tm_hour, tm_ptr->tm_min, tm_ptr->tm_sec,
    tm_ptr->tm_year - 100, tm_ptr->tm_mon + 1, tm_ptr->tm_mday);

 return 0;
}
