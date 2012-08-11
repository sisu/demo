void main() {
	float t = 10.*gl_Color.r;
	vec2 f = gl_FragCoord.xy/vec2(800,600);
	gl_FragColor.xy = sin(3*f+sin(vec2(3*t,4*t)));
//	gl_FragColor = vec4(t,1-t,0,1);
//	gl_FragColor = gl_FragCoord/800.;
//	gl_FragColor = vec4(1.,0.,0.,1.);
}
