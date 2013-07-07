#include "SDL.h"
#define FREQ 44100
#define SAMPLES 1024
Sint16 music[150*FREQ];

void genmusic();
void genmusic2();
void genmusic3();

int place=0;
void callback(void* udata, Uint8* s, int len)
{
	memcpy(s,music+place/2,len);
	place += len;
	(void)udata;
}

SDL_AudioSpec spec = {
	FREQ, // freq
	AUDIO_S16, // format
	1, // channels
	0, // silence
	SAMPLES, // samples
	0, // padding
	0, // size
	callback, // callback
	0 // userdata
};

int main()
{
	genmusic3();
	SDL_Init(SDL_INIT_AUDIO | SDL_INIT_VIDEO | SDL_INIT_TIMER);
	SDL_OpenAudio(&spec, 0);
	SDL_PauseAudio(0);

	while(1) {
		SDL_Event e;
		while(SDL_PollEvent(&e)) {
			if (e.type==SDL_QUIT) goto end;
		}
		SDL_Delay(10);
		if (SDL_GetTicks()>10000) break;
	}
end:
	SDL_Quit();
	return 0;
}

