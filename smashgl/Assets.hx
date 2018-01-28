package smashgl;
import stb.Image;
import haxe.io.*;

typedef LoadedImage = {
    width:Int,
    height:Int, 
    data:BytesData
}

class Assets{
    public static inline function getText(path:String)
    {
        return sys.io.File.getContent(sys.FileSystem.absolutePath(#if dev "./bin/" +#end path));
    }

    public static inline function getBytes(path:String):Bytes
    {
        return sys.io.File.getBytes(#if dev "./bin/" +#end path);
    }

    public static inline function getImage(path:String):LoadedImage
    {
		var bytes = getBytes(path);
		var p:String = haxe.io.Path.extension(path).toLowerCase();
		var width:Int, height:Int;
		var data:haxe.io.Bytes;
		return switch(p){
			case "png":
                var imageData = Image.load_from_memory(bytes.getData(), bytes.length);
                { width:imageData.w, height:imageData.h, data:imageData.bytes };
			default:
				throw "Unknown image format "+p;
		}
    }
}