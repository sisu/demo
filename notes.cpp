#include <iostream>
#include <cmath>
using namespace std;
const float F = 44100, M=1;

unsigned short upb(float x) {
	union {
		unsigned u;
		float f;
	} z;
	z.f = x;
	return z.u>>16;
}

int main() {
	cout<<"dw\t";
	float x;
	while(cin>>x) {
		float f = 220*exp2(x/12);
		float y = M*f/F;
		cout<<upb(y)<<',';
	}
	cout<<'\n';
}
