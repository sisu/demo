float t = 300.*gl_Color.r;
//vec3 B[9];
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
//		r += 1/length(2.*sin(.4*t*B[i])-v+vec3(0.04*sin(10*v.y),0.04*sin(10*v.z+t+v.x),9));
		r += 1/length(2*sin(.4*t*vec3(sin(i),sin(1+i),sin(2-i)))-v+vec3(0.04*sin(10*v.y),0.04*sin(10*v.z+t+v.x),9));
	}
	return r-4;
}
void main() {
//	vec2 f = gl_FragCoord.xy/vec2(800,600)-.5;
//	for(int i=0; i<9; ++i) B[i]=vec3(sin(i),sin(1+i),-sin(2+i));

//	gl_FragColor=0;

	float y,o,e=1e-3;
	vec3 v = vec3(gl_FragCoord.xy/vec2(800,600)-.5,1.), c=0, d, L, g, h=vec3(e,0,0);

	for(int i=0; i<50; ++i) {
		y = F(c);
//		if (y>-0.01) break;
		g = vec3(F(c+h), F(c+h.yxz), F(c+h.yzx))-y;
		c += min(0.2*e*abs(y)/length(g),1)*v;
	}
//	if (y>-.1) {
		d = -normalize(g);
		L = normalize(vec3(sin(t),sin(1.1*t),-1));
		o = dot(v, reflect(L, d));
		gl_FragColor = o*o;
//				dot(2*l*d - light,f);
		gl_FragColor.x+=dot(L,d);
//		gl_FragColor.y += sin(c.x)*sin(c.z+t);
//	}

//	gl_FragColor.g = F(vec3(0,0,1)*(8+3*f.x));
}
