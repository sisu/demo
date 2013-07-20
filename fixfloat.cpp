float fix(float x) {
	union {
		unsigned u;
		float f;
	} z;
	z.f = x;
	z.u += 1<<15;
	z.u &= ~((1<<16)-1);
	return z.f;
}

#include <iostream>
#include <iomanip>
using namespace std;
int main() {
	float x;
	while(cin>>x)
		cout<<setprecision(16)<<fix(x)<<'\n';
}
