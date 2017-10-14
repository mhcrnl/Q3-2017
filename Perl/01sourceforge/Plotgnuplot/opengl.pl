#! /usr/bin/perl

use OpenGL;

sub glInit {
		glpOpenWindow();
		glMatrixMode( GL_PROJECTION);
		glFrustum(-1.0, 1.0, -1.0, 1.0, 1.0, 20.0);
		glMatrixMode(GL_MODLVIEW);
	}
	
sub display {
		glShadeModel(GL_SMOOTH);
		
		glBegin(GL_POLYGON);
		glColor3f(40,0,0);
		glVertex3f(-20,20,19);
		glVertex3f(20,20,-19);
		glColor3f(0,0,1);
		glVertex3f(20,-20,-19);
		glVertex3f(-20,-20,-19);
		glEnd();
		glFlush();
		glXSwapBuffers();
}
glInit();	
display();
	print "Press return to exit\n"; 
	
while( <> ){ exit;}