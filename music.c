#include "SDL.h"
#include <math.h>
#include <string.h>

#define FREQ 44100
#define SAMPLES 256

// in msec
#define NOTE_TIME 420
#define SILENCE_TIME 70

typedef struct {
	int sfreq;
	int slowdown;
	int volume;
	int stime;
} instr;
instr instrs[] =  {
	{10500, 12, 180, FREQ*0.07},
//	{800, 0, 180, FREQ*0.07},
//	{105000000, 5, 180, FREQ*0.07},
};
unsigned char notes[] = { 10,11,12,10,6,8,12,10 };

#define TOTAL_TIME (4*NOTE_TIME)
#define MSIZE (FREQ*TOTAL_TIME/1000)
#define NSMP (int)(FREQ*NOTE_TIME/1000)
#define SSMP (int)(FREQ*SILENCE_TIME/1000)

Sint16 music[MSIZE+1024];
void genMusic() {
	int i,j;
	int icnt = sizeof(instrs)/sizeof(instrs[0]);
	for(j=0; j<icnt; ++j) {
		instr in = instrs[j];
		const int B = 20;
		int limit = NSMP - SSMP, silence = (1<<B)/SSMP;
//		int prev=0;
		for(i=0; i<MSIZE; ++i) {
			int nnum = i/NSMP;
			int npos = i%NSMP;
			int note = notes[nnum];
//			if (npos==0) printf("%d\n", note);
			int bfreq = in.sfreq * note;
			int a = ((int)(bfreq*npos/(10000+npos*in.slowdown)) & 127) * in.volume;
//			a = ((int)(prev/(10000)) & 127) * in.volume;
//			int add = bfreq-50*npos;
//			prev += add<0?0:add;
			if (npos>limit) {
				a = (a*((1<<B)-silence*(npos-limit)))>>B;
			}
			music[i] += a;
		}
	}
#if 0
	Uint16* stream = (Uint16*)s; len/=2;

	instr ins = instrs[0];
	const int sfreq = ins.sfreq, slowdown = ins.slowdown, volume = ins.volume, stime = ins.stime;

	const int limit = FREQ*TIME - stime, silence = (1<<20)/stime;

	int i;
// 	const int sfreq = 1050;
// 	const float sfreq = .0805f;
//	const int slowdown = 12;
//	const float slowdown = .000512f;
//	const int limit = FREQ*(TIME-STIME);
//	const int silence = (1<<20)/(FREQ*STIME);
	//	printf("starting freq: %f\n", sfreq-place*slowdown);
	for(i=0; i<len; ++i) {
		int k = place+i;
/*		if (sfreq - k*slowdown < 0) stream[i] = 0;
		else stream[i] = 127.9*sin((sfreq-k*slowdown)*k);*/
//		float a = 20000*sin(sfreq*k/(10000+k*slowdown));
//		float a = 20000*fmod(sfreq*k/(10000+k*slowdown),1);
		int a = ((int)(sfreq*k/(10000+k*slowdown)) & 127) * volume;
		if (k > limit) {
//			stream[i] /= 1+silence*(k-limit);
			a *= ((1<<20)-silence*(k-limit))>>20;
		}
		stream[i] = a;
	}
	place += len;
#endif
}

int place=0;
void callback(void* udata, Uint8* s, int len)
{
	if (place>=2*MSIZE) place=0,printf("reset\n");
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
	genMusic();
	SDL_Init(SDL_INIT_AUDIO | SDL_INIT_VIDEO | SDL_INIT_TIMER);
	SDL_OpenAudio(&spec, 0);
	SDL_PauseAudio(0);

	SDL_Delay(TOTAL_TIME);
	SDL_Quit();
	return 0;
}
