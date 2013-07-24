float t = 300*gl_Color.x;
float F(vec3 v) {
	float r=0;
	for(int i=0; i<9; ++i)
		r += 1/length(2*sin(.4*t*sin(vec3(i,1+i,2-i)))-v+vec3(0.04*sin(10*v.y),0.04*sin(10*v.z+t+v.x),9));
	return r-4;
}
void main() {
	float y,o;//,e=1e-3;
	vec3 v = vec3(gl_FragCoord.xy/vec2(800,600)-.5,1), c=0, L, g, h=0;
	h.x=1e-3;

	for(int i=0; i<50; ++i)
		y = F(c),
		g = vec3(F(c+h), F(c+h.yxz), F(c+h.yzx))-y,
		c += min(-.2e-3*y/length(g),1)*v;

	g = -normalize(g);
	L = normalize(sin(vec3(t,1.1*t,-1)));
//	L = normalize(vec3(sin(t),sin(1.1*t),-1));
	o = dot(v, reflect(L, g));
	gl_FragColor = o*o;
	gl_FragColor.x+=dot(L,g);
//	gl_FragColor.y += sin(c.x)*sin(c.z+t);
}
