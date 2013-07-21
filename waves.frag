float t = 300.*gl_Color.r;
float F(vec3 v) {
	v.y += 1;
	float q = 0.7;
	return sin(q*v.x+0.5*t)*sin(q*v.z+2.1*t*log(t)) - v.y + 1e-3*v.x*v.x*(t) + 1e-4*v.z*v.z - 5;// + 0.2*sin(t);

	v.z -= 5;
	v.x -= 1;
//	return min(v.x, v.y, v.z);
//	return 1/length(v)-3;
	v = abs(v);
	return 0.5 - max(max(v.x,v.y),v.z);
	return 1-length(v);
}
void main() {
	float y,o,e=1e-3;
	vec3 v = vec3(gl_FragCoord.xy/vec2(800,600)-.5,1.), c=0, d, L, g, h=vec3(e,0,0);

	for(int i=0; i<50; ++i) {
		y = F(c);
		g = vec3(F(c+h), F(c+h.yxz), F(c+h.yzx))-y;
		c += min(-0.5*e*y/length(g),5)*v;
	}
	gl_FragColor=0;
	d = -normalize(g);
	if (y>-10.5) {
		L = normalize(vec3(sin(t),sin(1.1*t),-1));
		o = dot(v, reflect(L, d));
		gl_FragColor = o*o;
		gl_FragColor.x+=dot(L,d);
	} else {
		gl_FragColor.rgb = v;
	}
}
