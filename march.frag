float t = 300*gl_Color.x,y,r;
float F(vec3 v) {
	r=-4;
	for(int i=0; i<9; ++i)
		r += 1/length(2*sin(.4*t*sin(vec3(i,1+i,2-i)))-v+vec3(0.04*sin(10*v.y),0.04*sin(10*v.z+t+v.x),9));
	return r;
}
void main() {
//	float y,o;//,e=1e-3;
	vec3 v = vec3(gl_FragCoord.xy/vec2(800,600)-.5,1), c=0, g, h=0;
	h.x=1e-3;

	for(int i=0; i<50; ++i)
		y = F(c),
		g = vec3(F(c+h), F(c+h.yxz), F(c+h.yzx))-y,
		c += min(-2e-4*y/length(g),1)*v;

	g = -normalize(g);
	h = normalize(sin(vec3(t,1.1*t,-1)));
//	h = normalize(vec3(sin(t),sin(1.1*t),-1));
	y = dot(v, reflect(h, g));
	gl_FragColor = y*y;
	gl_FragColor.y+=dot(h,g);
//	gl_FragColor.y += sin(c.x)*sin(c.z+t);
}
