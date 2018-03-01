package smashgl;
import opengl.GL.*;

class Quad {
	
    static var vbo:GLBuffer;

    static function prepare(){
		if (vbo != null) glDeleteBuffer(vbo);
			vbo = glCreateBuffer();
			
		var vertices:Array<Float> = [
			-1, -1, 0, 0,
			1, -1, 1, 0,
			1, 1, 1, 1,
			-1, 1, 0, 1
		];
		
		glBindBuffer(GL_ARRAY_BUFFER, vbo);
		glBufferData(GL_ARRAY_BUFFER, 4 * 4 * vertices.length, new Float32Array(vertices), GL_STATIC_DRAW);
		glBindBuffer(GL_ARRAY_BUFFER, null);
    }

    public static inline function bind(){
		if(vbo==null) prepare();
		glBindBuffer(GL_ARRAY_BUFFER, vbo);
    }
	public static inline function draw(){
		glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
	}
    public static inline function release(){
		glBindBuffer(GL_ARRAY_BUFFER, null);
    }
}