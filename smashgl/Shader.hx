package smashgl;
import opengl.GL.*;
import smashgl.SGL.check;
using StringTools;

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

	public static function fromCombinedSource(src:String):Array<ShaderSource>{
        var lines = src.split("\n");
        var state:String = "common";
        var blocks = new Map<String,String>();
        var buf = [];
        for(l in lines){
            if(l.indexOf("#pragma")>-1){
                var tag = l.split(" ")[1].toLowerCase().trim();
                switch(tag){
                    case "vertex"|"fragment"|"common":
                        blocks[state] = buf.join("\n");
                        buf = [];
                        state = tag;
                    default:
                        buf.push(l);
                }
            }else{
                buf.push(l);
            }
        }
        blocks[state] = buf.join("\n");
        for(k in blocks.keys()){
            if(k=="common")continue;
            blocks[k] = blocks["common"] + blocks[k];
        }
        blocks.remove("common");
        return [Vertex(blocks["vertex"]), Fragment(blocks["fragment"])];
	}

	public var name:String;
	var program:GLProgram;
	var sources:Array<ShaderSource>;
	var linked:Bool;
	var isValid(get, never):Bool;
	public function new(sources:Array<ShaderSource>, descriptiveName:String = "Shader"){
		this.sources = sources;
		this.name = descriptiveName;
		
		build();
	}

	public function setSource(sources:Array<ShaderSource>){
		this.sources = sources;
		build(true);
	}

	function get_isValid():Bool{
		return linked;
	}

	public function build(reuseProgram:Bool = false)
	{
		trace("Building "+name+"...");
		linked = false;
		if(!reuseProgram){
			destroy();
			program = glCreateProgram();
			check();
		}
		var error = false;
		var shaders = [];
		for (source in sources)
		{
			var shader:GLShader = switch(source){
				case Fragment(src):
					compile(src, GL_FRAGMENT_SHADER);
				case Vertex(src):
					compile(src, GL_VERTEX_SHADER);
				case Other(src, type):
					compile(src, type);
			}
			if(shader==-1){
				error = true;
				break;
			}
			shaders.push(shader);
			glAttachShader(program, shader);
		}

		if(error){
			trace("Could not compile shaders for program "+name);
			destroy();
			return;
		}

		glLinkProgram(program);
		for(s in shaders){
			glDetachShader(program, s);
			glDeleteShader(s);
		}
		check();
		var status = [];
		glGetProgramiv(program, GL_LINK_STATUS, status);
		check();
		if (status[0] == 0)
		{
			var log = SGL.getProgramInfoLog(program);
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
		var shader = glCreateShader(type);
		check();
		untyped __cpp__("glShaderSource({0},1,&{1}.__s,0)", shader, source);
		check();
		glCompileShader(shader);
		check();
		var status = [0];
		glGetShaderiv(shader, GL_COMPILE_STATUS, status);
		check();
		if (status[0] == 0)
		{
			var log = SGL.getShaderInfoLog(shader);
		check();
			trace(this.name+": "+log);
			glDeleteShader(shader);
		check();
			return -1;
		}

		return shader;
	}

	public inline function getAttribute(a:String):GLAttributeLocation
	{
		var pos =  glGetAttribLocation(program, a);
		#if debug
		if(pos==-1)	throw "Couldn't find attribute "+a;
		#end
		return pos;
	}

	public inline function getUniform(u:String):GLUniformLocation
	{
		var pos = glGetUniformLocation(program, u);
		return pos;
	}

	public function bind()
	{
		glUseProgram(program);
	}

	public function release()
	{
		glUseProgram(0);
	}

	public function destroy()
	{
		glDeleteProgram(program);
	}

}