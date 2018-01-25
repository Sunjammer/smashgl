package smashgl;

import opengl.GL;

enum ShaderSource{
	Vertex(src:String);
	Fragment(src:String);
	Other(src:String, type:Int);
}

typedef GLProgram = Int;
typedef GLShader = Int;
typedef GLUniformLocation = Int;
typedef GLAttributeLocation = Int;

class Shader {
	
	public var name:String;
	var program:GLProgram;
	var sources:Array<ShaderSource>;
	var linked:Bool;
	var isValid(get, never):Bool;
	static var allShaders:Array<Shader> = [];
	public function new(sources:Array<ShaderSource>, descriptiveName:String = "Shader"){
		this.sources = sources;
		this.name = descriptiveName;
		allShaders.push(this);
		
		build();
	}

	function get_isValid():Bool{
		return linked;
	}

	public static function reloadAll(){
		for(s in allShaders){
			s.build();
		}
	}

	public function build()
	{
		trace("Building "+name+"...");
		linked = false;
		destroy();
		program = GL.glCreateProgram();
		var error = false;
		for (source in sources)
		{
			var shader:GLShader = switch(source){
				case Fragment(src):
					compile(src, GL.GL_FRAGMENT_SHADER);
				case Vertex(src):
					compile(src, GL.GL_VERTEX_SHADER);
				case Other(src, type):
					compile(src, type);
			}
			if(shader==-1){
				error = true;
				break;
			}
			GL.glAttachShader(program, shader);
			GL.glDeleteShader(shader);
		}

		if(error){
			trace("Could not compile shaders for program "+name);
			destroy();
			return;
		}

		GL.glLinkProgram(program);
		var status = [];
		GL.glGetProgramiv(program, GL.GL_LINK_STATUS, status);
		if (status[0] == 0)
		{
			var log = GL.glGetProgramInfoLog(program);
			trace(name+": "+log);
			destroy();
			return;
		}
		#if debug
		trace("Successfully linked "+name);
		#end

		linked = true;
	}

	private function compile(source:String, type:Int):GLShader
	{
		var shader = GL.glCreateShader(type);
		untyped __cpp__("glShaderSource({0},1,&{1}.__s,0)", shader, source);
		GL.glCompileShader(shader);
		var status = [0];
		GL.glGetShaderiv(shader, GL.GL_COMPILE_STATUS, status);
		if (status[0] == 0)
		{
			var log = GL.glGetShaderInfoLog(shader);
			trace(this.name+": "+log);
			GL.glDeleteShader(shader);
			return -1;
		}

		return shader;
	}

	public inline function getAttribute(a:String):GLAttributeLocation
	{
		var pos =  GL.glGetAttribLocation(program, a);
		#if debug
		if(pos==-1)	throw "Couldn't find attribute "+a;
		#end
		return pos;
	}

	public inline function getUniform(u:String):GLUniformLocation
	{
		var pos = GL.glGetUniformLocation(program, u);
		return pos;
	}

	public function bind()
	{
		GL.glUseProgram(program);
	}

	public function release()
	{
		GL.glUseProgram(0);
	}

	public function destroy()
	{
		GL.glDeleteProgram(program);
	}

}