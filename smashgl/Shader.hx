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
		program = GL.createProgram();
		var error = false;
		for (source in sources)
		{
			var shader:GLShader = switch(source){
				case Fragment(src):
					compile(src, GL.FRAGMENT_SHADER);
				case Vertex(src):
					compile(src, GL.VERTEX_SHADER);
				case Other(src, type):
					compile(src, type);
			}
			if(shader==-1){
				error = true;
				break;
			}
			GL.attachShader(program, shader);
			GL.deleteShader(shader);
		}

		if(error){
			trace("Could not compile shaders for program "+name);
			destroy();
			return;
		}

		GL.linkProgram(program);
		var status = [];
		GL.getProgramiv(program, GL.LINK_STATUS, status);
		if (status[0] == 0)
		{
			var log = GL.getProgramInfoLog(program);
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
		var shader = GL.createShader(type);
		untyped __cpp__("glShaderSource({0},1,&{1}.__s,0)", shader, source);
		GL.compileShader(shader);
		var status = [0];
		GL.getShaderiv(shader, GL.COMPILE_STATUS, status);
		if (status[0] == 0)
		{
			var log = GL.getShaderInfoLog(shader);
			trace(this.name+": "+log);
			GL.deleteShader(shader);
			return -1;
		}

		return shader;
	}

	public inline function getAttribute(a:String):GLAttributeLocation
	{
		var pos =  GL.getAttribLocation(program, a);
		#if debug
		if(pos==-1)	throw "Couldn't find attribute "+a;
		#end
		return pos;
	}

	public inline function getUniform(u:String):GLUniformLocation
	{
		var pos = GL.getUniformLocation(program, u);
		return pos;
	}

	public function bind()
	{
		GL.useProgram(program);
	}

	public function release()
	{
		GL.useProgram(0);
	}

	public function destroy()
	{
		GL.deleteProgram(program);
	}

}