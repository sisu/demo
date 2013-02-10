#include "SDL.h"
#include <math.h>

#define FREQ 44100
#define SAMPLES 256

#define TIME .42f
#define STIME .07f

int place=0;
void callback(void* udata, Uint8* s, int len)
{
	(void)udata,(void)len;
	Uint16* stream = (Uint16*)s; len/=2;

	int i;
 	const int sfreq = 1050;
// 	const float sfreq = .0805f;
	const int slowdown = 12;
//	const float slowdown = .000512f;
	const int limit = FREQ*(TIME-STIME);
	const int silence = (1<<20)/(FREQ*STIME);
	//	printf("starting freq: %f\n", sfreq-place*slowdown);
	for(i=0; i<len; ++i) {
		int k = place+i;
/*		if (sfreq - k*slowdown < 0) stream[i] = 0;
		else stream[i] = 127.9*sin((sfreq-k*slowdown)*k);*/
//		float a = 20000*sin(sfreq*k/(10000+k*slowdown));
//		float a = 20000*fmod(sfreq*k/(10000+k*slowdown),1);
		int a = ((int)(100*sfreq*k/(10000+k*slowdown)) & 127) * 180;
		if (k > limit) {
//			stream[i] /= 1+silence*(k-limit);
			a *= ((1<<20)-silence*(k-limit))>>20;
		}
		stream[i] = a;
	}
	place += len;
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
	SDL_Init(SDL_INIT_AUDIO | SDL_INIT_VIDEO | SDL_INIT_TIMER);
	SDL_OpenAudio(&spec, 0);
	SDL_PauseAudio(0);

	int i;
	for(i=0; i<8; ++i) {
		SDL_LockAudio();
		place = 0;
		SDL_UnlockAudio();
		SDL_Delay(TIME*1000);
	}
	SDL_Quit();
	return 0;
}
