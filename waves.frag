float t = 300.*gl_Color.r;
float F(vec3 v) {
	v.y += 1;
	return sin(v.x+t)*sin(v.z+1.1*t) - v.y - 1 + 0.2*sin(t);

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
		c += min(0.2*e*abs(y)/length(g),2)*v;
	}
	gl_FragColor=0;
//	if (y>-.1) {
		d = -normalize(g);
		L = normalize(vec3(sin(t),sin(1.1*t),-1));
		o = dot(v, reflect(L, d));
		gl_FragColor = o*o;
		gl_FragColor.x+=dot(L,d);
//	}
}
