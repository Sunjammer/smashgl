package smashgl;

@:build(smashgl.Build.init())
class SmashGL{
    public static inline function init(){
        glew.GLEW.init();
    }
}