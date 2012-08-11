#include "load.h"
#include <GL/gl.h>

//static const char vtx[] = {-1,-1,0,1,-1,0,0,1,0};
static const char vtx[] = {-1,-1,1,1,-1};
static void draw() {
	Begin(GL_TRIANGLE_FAN);
#if 1
	int i=3;
	do {
//		Vertex3fv(vtx+3*i);
		Vertex2s(vtx[i],vtx[i+1]);
	} while(i-->0);
#else
	int i;
	for(i=0; i<4; ++i)
		Vertex2s(vtx[i],vtx[i+1]);
#endif
	End();
	SwapBuffers();
}

void introloop() {
	SDL_Event e;
	do {
		draw();
		PollEvent(&e);
	} while(e.key.keysym.sym!=27);
}
