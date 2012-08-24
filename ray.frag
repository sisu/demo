float T(vec3 d, vec3 v) {
	float a = dot(v,v), b = -2.*dot(v,d), c = dot(d,d)-1., disc = b*b-4.*a*c;
//	return (-b-sqrt(abs(disc)))/(2.*a);
	return disc>0.?(-b-sqrt(disc))/(2.*a):99;
}
void main() {
	float t = 300.*gl_Color.r;
	vec2 f = gl_FragCoord.xy/vec2(800,600)-vec2(.5,.5);

	vec3 B[9];
	for(int i=0; i<9; ++i) B[i]=vec3(sin(i),sin(1+i),-sin(2+i));
//	mat3 B = mat3(.4,.5,.6, -1.,.5,.3, .3,-.4,-.6);
	vec3 d = vec3(sin(1.2*t),sin(t),5), v = vec3(f,1.), cur=vec3(0,0,0);
	float phit=90;
	for(float part=.9; part>.5; part*=.7) {
		vec3 pt,dir;
		for(int i=0; i<9; ++i) {
			d=2*sin(.4*t*B[i])-cur;
			d.z+=9.;
			float hit = T(d,v);
			if (hit<phit&&hit>0) {
				phit=hit;
				pt = hit*v;
				dir = (pt-d);
				vec3 light = normalize(vec3(1.,1.,-1.));
//				gl_FragColor.rgb = vec3(abs(dot(light,dir)), abs(sin(hit)), length(pt-d));
				gl_FragColor.r = dot(light,dir);
			}
		}
		v = reflect(v, dir);
		cur=pt;
	}
}
