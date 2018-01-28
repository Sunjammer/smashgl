package smashgl;
import smashgl.GL.RenderTarget;
class TextureUtils{

	public static function makeTarget(width:Int, height:Int, isFloat:Bool = true):RenderTarget
    {
        var fbo = GL.createFramebuffers()[0];
        var tex = GL.createTextures()[0];
		var t = isFloat?GL.RGBA16F:GL.RGBA;
        GL.bindFramebuffer(GL.FRAMEBUFFER, fbo);
        GL.bindTexture(GL.TEXTURE_2D, tex);
        GL.texImage2DAlloc(GL.TEXTURE_2D, 0, t, width, height, 0, t, GL.UNSIGNED_BYTE);
        GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.CLAMP_TO_EDGE);
        GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.CLAMP_TO_EDGE);
        GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.LINEAR);
        GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.LINEAR);
        GL.framebufferTexture2D(GL.FRAMEBUFFER, GL.COLOR_ATTACHMENT0, GL.TEXTURE_2D, tex, 0);
        
		GL.clearColor(0,0,0,0);
		GL.clear(GL.COLOR_BUFFER_BIT);
        

		var status = GL.checkFramebufferStatus(GL.FRAMEBUFFER);
		switch (status) {
			case GL.FRAMEBUFFER_INCOMPLETE_ATTACHMENT:
				trace("FRAMEBUFFER_INCOMPLETE_ATTACHMENT");
			case GL.FRAMEBUFFER_UNSUPPORTED:
				trace("FRAMEBUFFER_UNSUPPORTED");
			case GL.FRAMEBUFFER_COMPLETE:
			default:
				trace("Check frame buffer: " + status);
		}

        return { texture:tex, fbo:fbo };
    }

	static public inline function createRenderTargetTexture(width:Int, height:Int):Int{
        var tex = GL.createTextures()[0];
        GL.bindTexture(GL.TEXTURE_2D, tex);
        GL.texImage2DAlloc(GL.TEXTURE_2D, 0, GL.RGB16F, width, height, 0, GL.RGB, GL.UNSIGNED_BYTE);
        GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.CLAMP_TO_EDGE);
        GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.CLAMP_TO_EDGE);
        GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.NEAREST);
        GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.NEAREST);
		GL.bindTexture(GL.TEXTURE_2D, 0);
		return tex;
	}

	static public inline function createTexture(width:Int, height:Int, repeat:Bool = false, format:Int = GL.RGBA, filter:Int = GL.LINEAR):Int
	{
        var tex = GL.createTextures()[0];
		GL.bindTexture(GL.TEXTURE_2D, tex);
		GL.texImage2DAlloc(GL.TEXTURE_2D, 0, format, width, height,  0,  GL.RGB, GL.UNSIGNED_BYTE);
		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, repeat ? GL.REPEAT : GL.CLAMP_TO_EDGE);
		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, repeat ? GL.REPEAT : GL.CLAMP_TO_EDGE);
		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, filter);
		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, filter);
		GL.bindTexture(GL.TEXTURE_2D, 0);
		return tex;
	}
  
 	static public inline function createTextureFromBitmap(path:String, repeat:Bool = false):Int{
		var img = Assets.getImage(path);
		var tex = createTexture(img.width, img.height, repeat, GL.RGBA);
		GL.bindTexture(GL.TEXTURE_2D, tex);
		GL.texImage2D (GL.TEXTURE_2D, 0, GL.RGBA, img.width, img.height, 0, GL.RGBA, GL.UNSIGNED_BYTE, img.data.getData());
		GL.bindTexture(GL.TEXTURE_2D, 0);
		return tex;
	}
  
}