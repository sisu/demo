vec3 B[9];
float t = 300.*gl_Color.r;
float F(vec3 v) {
	float r=0;
	for(int i=0; i<9; ++i) {
		/*
		vec3 d=2.*sin(.4*t*B[i])-v;
		d.z+=9.;
		d.x += 0.04*sin(10*v.y);
		d.y += 0.04*sin(10*v.z+t+v.x);
		r += 1/length(d);
		*/
		r += 1/length(2.*sin(.4*t*B[i])-v+vec3(0.04*sin(10*v.y),0.04*sin(10*v.z+t+v.x),9));
	}
	return r-4;
}
/*
vec3 dF(vec3 v, float x) {
	float e=1e-3;
	vec3 h=vec3(e,0.,0.);
	return (vec3(F(v+h), F(v+h.yxz), F(v+h.yzx))-x)/e;
}
*/
void main() {
	vec2 f = gl_FragCoord.xy/vec2(800,600)-vec2(.5,.5);

	for(int i=0; i<9; ++i) B[i]=vec3(sin(i),sin(1+i),-sin(2+i));

	gl_FragColor=0;

	float x=0,y,t=50,l,o,e=1e-3;
	vec3 v = vec3(f,1.), c, d, L, g, h=vec3(e,0,0);

	while(t--) {
		c = x*v;
		y = F(c);
//		if (y>-0.01) break;
		g = (vec3(F(c+h), F(c+h.yxz), F(c+h.yzx))-y)/e;
		float d = abs(y)/length(g);
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
	if (y>-.1) {
		d = -normalize(g);
		L = normalize(vec3(sin(t),sin(1.1*t),-1));
		l = dot(d,L);
		o = dot(v, reflect(L, d));
		gl_FragColor = o*o;
//				dot(2*l*d - light,f);
		gl_FragColor.x+=l;
	}

//	gl_FragColor.g = F(vec3(0,0,1)*(8+3*f.x));
}
