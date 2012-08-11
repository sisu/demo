#define N (44100*10)
extern short music[N];
void genmusic() {
	int i = N-1;
	do {
		int t = i;
		music[i] = (t * ((t>>12|t>>8)&63&t>>4))<<8;
	} while(i-->0);
}
