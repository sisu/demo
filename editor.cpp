#include "SDL.h"
#include <GL/gl.h>
#include <iostream>
#include <cassert>
#include <string>
using namespace std;

extern "C" {
GLuint glCreateProgram(void);
GLuint glCreateShader(GLenum shaderType);
void glAttachShader(GLuint program, GLuint shader);
void glCompileShader(GLuint shader);
void glLinkProgram(GLuint program);
void glUseProgram(GLuint program);
void glShaderSource(GLuint shader, GLsizei count, const GLchar ** string, const GLint * length);
void glGetShaderiv(GLuint shader, GLenum pname, GLint *params);
void glGetShaderInfoLog(GLuint shader, GLsizei maxLength, GLsizei *length, GLchar *infoLog);
GLuint glDeleteProgram(GLuint program);
}

string loadFile(const char* file)
{
	const int MAX_SIZE = 1<<16;
	char buf[MAX_SIZE];
	FILE* f = fopen(file, "r");
	if (!f) {
		cout<<"failed opening "<<file<<'\n';
		return "";
	}
	int len = fread(buf, 1, MAX_SIZE, f);
	buf[len] = 0;
	fclose(f);
	return buf;
}
GLuint makeProgram(string str) {
	GLuint shader = glCreateShader(GL_FRAGMENT_SHADER);
	const char* cstr = str.c_str();
	glShaderSource(shader, 1, &cstr, 0);
	glCompileShader(shader);

	int status;
	glGetShaderiv(shader, GL_COMPILE_STATUS, &status);
	if (!status) {
		GLsizei elen;
		const int MAX_SIZE = 1<<16;
		char buf[MAX_SIZE];
		glGetShaderInfoLog(shader, MAX_SIZE, &elen, buf);
		fprintf(stderr, "Compiling shader failed: %s\n", buf);
		return 0;
	}

	GLuint prog = glCreateProgram();
	glAttachShader(prog, shader);
	glLinkProgram(prog);
	return prog;
}

int main(int argc, char* argv[]) {
	assert(argc>1);
	const char* file = argv[1];

	SDL_Init(SDL_INIT_VIDEO | SDL_INIT_TIMER);
	SDL_SetVideoMode(800, 600, 0, SDL_OPENGL);

	string prevStr;
	GLuint prevProg=0;

	int startT = SDL_GetTicks();
	Uint32 nextLoad = startT;
	while(1) {
		if (SDL_GetTicks()>=nextLoad) {
			nextLoad += 200;
			string pstr = loadFile(file);
			if (pstr != prevStr && !pstr.empty()) {
				prevStr = pstr;
				GLuint prog = makeProgram(pstr);
				if (prog) {
					cout<<"OK\n";
					glUseProgram(prog);
					if (prevProg) glDeleteProgram(prevProg);
					prevProg = prog;
					startT = SDL_GetTicks();
				}
			}
		}

		int t = SDL_GetTicks()-startT;
		glColor3us(t,0,0);
		glRecti(-1,-1,1,1);
		SDL_GL_SwapBuffers();
		SDL_Delay(20);

		SDL_Event e;
		while(SDL_PollEvent(&e)) {
			if (e.type==SDL_QUIT) goto end;
		}
	}
end:
	SDL_Quit();
}
