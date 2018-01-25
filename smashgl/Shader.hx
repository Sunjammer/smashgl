package smashgl;

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
		program = SmashGL.CreateProgram();
		var error = false;
		for (source in sources)
		{
			var shader:GLShader = switch(source){
				case Fragment(src):
					compile(src, SmashGL.GL_FRAGMENT_SHADER);
				case Vertex(src):
					compile(src, SmashGL.GL_VERTEX_SHADER);
				case Other(src, type):
					compile(src, type);
			}
			if(shader==-1){
				error = true;
				break;
			}
			SmashGL.AttachShader(program, shader);
			SmashGL.DeleteShader(shader);
		}

		if(error){
			trace("Could not compile shaders for program "+name);
			destroy();
			return;
		}

		SmashGL.LinkProgram(program);
		var status = [];
		SmashGL.GetProgramiv(program, SmashGL.GL_LINK_STATUS, status);
		if (status[0] == 0)
		{
			var log = SmashGL.GetProgramInfoLog(program);
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
		var shader = SmashGL.CreateShader(type);
		untyped __cpp__("glShaderSource({0},1,&{1}.__s,0)", shader, source);
		SmashGL.CompileShader(shader);
		var status = [0];
		SmashGL.GetShaderiv(shader, SmashGL.GL_COMPILE_STATUS, status);
		if (status[0] == 0)
		{
			var log = SmashGL.GetShaderInfoLog(shader);
			trace(this.name+": "+log);
			SmashGL.DeleteShader(shader);
			return -1;
		}

		return shader;
	}

	public inline function getAttribute(a:String):GLAttributeLocation
	{
		var pos =  SmashGL.GetAttribLocation(program, a);
		#if debug
		if(pos==-1)	throw "Couldn't find attribute "+a;
		#end
		return pos;
	}

	public inline function getUniform(u:String):GLUniformLocation
	{
		var pos = SmashGL.GetUniformLocation(program, u);
		return pos;
	}

	public function bind()
	{
		SmashGL.UseProgram(program);
	}

	public function release()
	{
		SmashGL.UseProgram(0);
	}

	public function destroy()
	{
		SmashGL.DeleteProgram(program);
	}

}