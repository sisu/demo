void main() {
	float t = 300.*gl_Color.r;
	vec2 f = gl_FragCoord.xy/vec2(800,600)-vec2(.5+.07*sin(t),.5+.06*sin(t));
	float x = atan(f.x,f.y), y = 1/length(f)+t;
	gl_FragColor = vec4(.5*(1+sin(3*x + sin(y)+y)+.5*sin(y)), sin(x-y-t), 0,0);
//	float x = f.x, y = f.y;
//	float d=length(f), a=atan(f.y,f.x);
//	gl_FragColor.xyz = vec3(sin(32*d+3*a+40*t),d,sin(16*d+5*a+8*sin(6*d+5*t)));
//	gl_FragColor.xyz = vec3(sin(2*x+.2*y+5*sin(t)), sin(3*y+.1*x+4*t)+sin(t),atan(x+5,y+sin(t)));
//	gl_FragColor.xy = sin(3*f+sin(vec2(3*t,4*t)));
//	gl_FragColor = vec4(t,1-t,0,1);
//	gl_FragColor = gl_FragCoord/800.;
//	gl_FragColor = vec4(1.,0.,0.,1.);
}
