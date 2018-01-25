package smashgl;


@:build(smashgl.Build.init("opengl.GL"))
class GL{

    public static inline function init() : Void
    {
        glew.GLEW.init();
    }

    public inline static function createTextures(num:Int = 1, type:Int = TEXTURE_2D):Array<Int>{
		var tmp = [];
        opengl.GL.glCreateTextures(type, num, tmp);
		return tmp;
	}

	public inline static function createFrameBuffers(num:Int = 1):Array<Int>{
		var tmp = [];
        opengl.GL.glCreateFramebuffers(num, tmp);
		return tmp;
	}

    public static inline function getProgramInfoLog(program:Int) : String
    { 
        untyped __cpp__("char __buffer[4096]; glGetProgramInfoLog({0}, 4096, (GLsizei*)0, &__buffer[0]);", program); 
        return untyped __cpp__("::String(__buffer);");
    }

    public static inline function getShaderInfoLog(shader:Int) : String
    { 
        untyped __cpp__("char __buffer[4096]; glGetShaderInfoLog({0}, 4096, (GLsizei*)0, &__buffer[0])", shader); 
        return untyped __cpp__("::String(__buffer)");
    }
    
}