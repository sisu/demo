#pragma once
#include "SDL.h"
//extern void(*Vertex3fv)(const float*);
//extern void(*Vertex3f)(float,float,float);
extern void(*Vertex2i)(short,short);
extern void(*Begin)();
extern void(*End)();

extern int(*GetTicks)();
extern int(*PollEvent)(SDL_Event*);
extern void(*SwapBuffers)();
