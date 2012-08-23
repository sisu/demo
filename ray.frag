float T(vec3 d, vec3 v) {
	float a = dot(v,v), b = -2.*dot(v,d), c = dot(d,d)-1., disc = b*b-4.*a*c;
//	return disc>0.?(-b-sqrt(disc))/2.*a:9.;
	return (-b-sqrt(disc))/2.*a;
}
void main() {
	float t = 300.*gl_Color.r;
	vec2 f = gl_FragCoord.xy/vec2(800,600)-vec2(.5,.5);
	float x = atan(f.x,f.y), y = 1./length(f)+t;
	gl_FragColor = vec4(.5*(1.+sin(3.*x + sin(y)+y)+.5*sin(y)), sin(x-y-t), 0.,0.);

	mat3 B = mat3(.5,.6,.7, -1.,.5,.3, .3,-.4,-.6);
	vec3 d = vec3(sin(1.2*t),sin(t),5), v = vec3(f,1.);
	float hit = T(d,v);
	if (hit<9.) {
		vec3 pt = hit*v;
		vec3 dir = normalize(pt-d);
		vec3 light = normalize(vec3(1.,1.,-1.));
		gl_FragColor.rgb = vec3(abs(dot(light,dir)), abs(sin(hit)), length(pt-d));
	}
}
