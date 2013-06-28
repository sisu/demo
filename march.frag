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
vec3 dF(vec3 v, float x) {
	float e=1e-5;
	vec3 h=vec3(e,0.,0.);
	return (vec3(F(v-h), F(v-h.yxz), F(v-h.yzx))-x)/e;
}
void main() {
	vec2 f = gl_FragCoord.xy/vec2(800,600)-vec2(.5,.5);

	for(int i=0; i<9; ++i) B[i]=vec3(sin(i),sin(1+i),-sin(2.+i));
	vec3 v = vec3(f,1.), cur=vec3(0.);

	gl_FragColor=0;
	for(int t=0; t<50; ++t) {
		float x=F(cur);
		if (x>3) {
			vec3 d = normalize(dF(cur, x));
			vec3 light = normalize(vec3(sin(t),1,-1));
			float l = dot(d,light);
			gl_FragColor = pow(max(dot(v, reflect(light, d)),0),2);
//				dot(2*l*d - light,f);
			gl_FragColor.r+=l;
			break;
		}
//		cur+=.2*v;
		float dist = (3-x)/length(dF(cur,x));
//		cur += (3.1-x)*v;
		cur += min(1.,.1+dist)*v;
	}
}
