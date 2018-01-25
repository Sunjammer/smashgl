package smashgl;


@:build(smashgl.Build.init("opengl.GL"))
class SmashGL{

    public static inline function init() : Void
    {
        glew.GLEW.init();
    }

    public static inline function GetProgramInfoLog(program:Int) : String
    { 
        untyped __cpp__("char __buffer[4096]; glGetProgramInfoLog({0}, 4096, (GLsizei*)0, &__buffer[0]);", program); 
        return untyped __cpp__("::String(__buffer);");
    }

    public static inline function GetShaderInfoLog(shader:Int) : String
    { 
        untyped __cpp__("char __buffer[4096]; glGetShaderInfoLog({0}, 4096, (GLsizei*)0, &__buffer[0])", shader); 
        return untyped __cpp__("::String(__buffer)");
    }
}