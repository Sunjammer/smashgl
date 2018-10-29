package smashgl;
import haxe.io.*;
import opengl.GL.*;

class SGL{

	public static inline function init() : Void
	{
		trace("Init glew");
		glew.GLEW.init();
	}
	
	public static inline function check(prefix:String = "", ?pos:haxe.PosInfos):Bool{
		#if debug
			var error:Int = 0;
			var e = true;
			var count = 0;
			while ((error = glGetError()) != 0 && count++ < 20) {
				e = false;
				haxe.Log.trace(prefix+': GL error: ' + error, pos);
			}
			return e;
		#else
			return true; //If not debug just pass thru
		#end

	}

	public inline static function toFloatArrayBytesData(a:Array<Float>):BytesData{
		return haxe.io.Float32Array.fromArray(a).getData().bytes.getData();
	}

	public static function createTextures(num:Int = 1, type:Int = GL_TEXTURE_2D):Array<Int>{
		var tmp = [];
		glGenTextures(num, tmp);
		return tmp;
	}

	public inline static function createFramebuffers(num:Int = 1):Array<Int>{
		var tmp = [];
		glGenFramebuffers(num, tmp);
		return tmp;
	}

	public inline static function createRenderbuffers(num:Int = 1):Array<Int>{
		var tmp = [];
		glGenRenderbuffers(num, tmp);
		return tmp;
	}

	public static inline function getProgramInfoLog(program:Int) : String
	{ 
		untyped __cpp__("char __buffer[4096]; glGetProgramInfoLog({0}, 4096, (GLsizei*)0, &__buffer[0]);", program); 
		return untyped __cpp__("::String(__buffer)");
	}

	public static inline function getShaderInfoLog(shader:Int) : String
	{ 
		untyped __cpp__("char __buffer[4096]; glGetShaderInfoLog({0}, 4096, (GLsizei*)0, &__buffer[0])", shader); 
		return untyped __cpp__("::String(__buffer)");
	}

	public static inline function texImage2DAlloc(target:Int, level:Int, internalformat:Int, width:Int, height:Int, border:Int, format:Int, type:Int) : Void
	{ 
		untyped __cpp__("glTexImage2D({0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, 0)", target, level, internalformat, width, height, border, format, type); 
	}

	
}