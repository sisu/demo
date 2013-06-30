vec3 B[9];
float t = 300.*gl_Color.r;
float F(vec3 v) {
	float r=0;
	for(int i=0; i<9; ++i) {
		vec3 d=2.*sin(.4*t*B[i])-v;
		d.z+=9.;
		d.x += 0.04*sin(10*v.y);
		d.y += 0.04*sin(10*v.z+t+v.x);
		r += 1/length(d);
	}
	return r-4;
}
vec3 dF(vec3 v, float x) {
	float e=1e-1;
	vec3 h=vec3(e,0.,0.);
	return (vec3(F(v+h), F(v+h.yxz), F(v+h.yzx))-x)/e;
}
void main() {
	vec2 f = gl_FragCoord.xy/vec2(800,600)-vec2(.5,.5);

	for(int i=0; i<9; ++i) B[i]=vec3(sin(i),sin(1+i),-sin(2.+i));
	vec3 v = vec3(f,1.), cur=vec3(0.);


	gl_FragColor=0;

	float x=0;

	for(int t=0; t<50; ++t) {
		vec3 c = x*v;
		float y = F(c);
//		if (y>-0.01) break;
		float d = abs(y)/length(dF(c,y));
		x += min(0.2*d,1);
	}
	/*
	for(int t=0; t<50; ++t) {
		float y = F(x*v);
		float nx = x - y / dot(dF(x*v, y),v);
		x = min(x+0.5, nx);
	}
	/**/
//	gl_FragColor=0;
//	gl_FragColor.g = F(x*v)+1;
//	gl_FragColor.g = x/20;
	float y = F(x*v);
	if (y>-1e-1) {
		vec3 d = -normalize(dF(x*v, y));
		vec3 light = normalize(vec3(sin(t),sin(1.1*t),-1));
		float l = dot(d,light);
		gl_FragColor += pow(max(dot(v, reflect(light, d)),0),2);
//				dot(2*l*d - light,f);
		gl_FragColor.r+=l;
	}

//	gl_FragColor.g = F(vec3(0,0,1)*(8+3*f.x));
}
