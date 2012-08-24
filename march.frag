vec3 B[9];
float t = 300.*gl_Color.r;
float F(vec3 v) {
	float r=0;
	for(int i=0; i<6; ++i) {
		vec3 d=2.*sin(.4*t*B[i])-v;
		d.z+=9.;
		r += 1/length(d);
	}
	return r;
}
void main() {
	vec2 f = gl_FragCoord.xy/vec2(800,600)-vec2(.5,.5);

	for(int i=0; i<9; ++i) B[i]=vec3(sin(i),sin(1+i),-sin(2.+i));
	vec3 v = vec3(f,1.), cur;

	gl_FragColor=0;
	for(int t=0; t<100; ++t) {
		float x=F(cur);
		if (x>3) {
			float e=1e-5;
			vec3 d=normalize(vec3(F(cur-vec3(e,0,0))-x, F(cur-vec3(0,e,0))-x, F(cur-vec3(0,0,e))-x));
			vec3 light = normalize(vec3(sin(t),1,-1));
			gl_FragColor.r=dot(d,light);
			break;
		}
//		cur+=.2*v;
		cur += (3.1-x)*v;
	}
}
