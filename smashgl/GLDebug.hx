package smashgl;

import haxe.macro.Context;
import haxe.macro.Expr;

using Lambda;

class GLDebug {

  public static function build():Array<Field> {
    var fields = Context.getBuildFields();
    #if debug
    for(f in fields){
      switch(f){
        case {meta:[{name:"gldebug"}]}:
          switch(f.kind){
            case FFun(fn):
              switch(fn.expr.expr){
                case EBlock(exprs):
                  var toAdd:Array<{expr:Expr, offset:Int}> = [];
                  var i = 0;
                  for(e in exprs){
                    switch(e.expr){
                      case ECall({expr:EField({expr:EConst(CIdent("GL"))},_)}, _):
                        var outExpr = Context.parse("
                            {
                                var error:Int;
                                if ((error =  opengl.GL.glGetError()) != 0) {
                                  trace('GL error: ' + error);
                                }
                            }", e.pos);
                        toAdd.push({expr:outExpr, offset:i});
                      case _:
                    }
                    i++;
                  }
                  for(e in toAdd){
                    exprs.insert(e.offset+1, e.expr);
                  }
                default:
              }
            default:
          }
        default:
      }
    }
    #end
    return fields;
  }
}