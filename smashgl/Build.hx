package smashgl;

import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;
import haxe.macro.Printer;
using Lambda;
using haxe.macro.ComplexTypeTools;
using haxe.macro.TypeTools;
using haxe.macro.ExprTools;
using haxe.macro.TypedExprTools;

#if macro
class Build{
    macro public static function init(sourceClassName:String):Array<Field>{
        var glType = Context.getType(sourceClassName);
        var glClass = haxe.macro.TypeTools.getClass(glType);
        var fields = Context.getBuildFields();
        var toInject:Array<Field> = [];

        inline function strip(input:String):String{
            if(input.indexOf("gl")==0)
                return input.substring(2);
            return input;
        }

        var raw = glClass.statics.get().filter(function(cf){
            if(!cf.isPublic) return false;
            for(f in fields){
                if(f.name==strip(cf.name))
                    return false;
            }
            return true;
        });
        trace(raw.length+" linc fields to map");

        function toFieldTypeVar(expr:TypedExpr):FieldType{
            expr.pos = Context.currentPos();
            var texpr = Context.getTypedExpr(expr);
            var type = expr.t.toComplexType();
            return FieldType.FVar(type, texpr);
        }

        function toFunctionArgs(args:Array<{t:haxe.macro.Type, opt:Bool, name:String}>):Array<FunctionArg>{
            return [for(input in args) {
                name:input.name,
                type:input.t.toComplexType(),
                opt:input.opt
            }];
        }

        function toShim(t:haxe.macro.Type, name:String):FieldType{
            switch(t){
                case TLazy(f):
                    return toShim(f(), name);
                case TFun(args, ret):
                    var hasReturn = switch(ret){
                        case TAbstract(ref,params):
                            ref.get().name!="Void";
                        case _:
                            true;
                    }
                    var outArgs = toFunctionArgs(args);
                    var exprStr = (hasReturn?'return ':'') + '$sourceClassName.$name('+outArgs.map(function(arg) return arg.name ).join(', ')+')';
                    var expr = Context.parse(exprStr, Context.currentPos());
                    var func = {
                        expr: expr,
                        ret: hasReturn?ret.toComplexType():null,
                        args:outArgs
                    };
                    return FieldType.FFun(func);
                default:
                    throw "Unexpected type "+t;
            }
        }


        try{
            for(f in raw){
                toInject.push(switch(f.kind){
                    case FieldKind.FVar(_,_):
                        var ex = f.expr();
                        {
                            name:strip(f.name),
                            access: [APublic, AStatic, AInline],
                            pos: Context.currentPos(),
                            kind: toFieldTypeVar(ex),
                            meta: [{name:":extern", pos:Context.currentPos()}]
                        };
                    case FieldKind.FMethod(kind):
                        {
                            name:strip(f.name),
                            access: [APublic, AStatic, AInline],
                            pos: Context.currentPos(),
                            kind: toShim(f.type, f.name),
                            meta: [{name:":extern", pos:Context.currentPos()}]
                        }
                });
            }

        }catch(e:Dynamic){
            trace("Erreur: "+e);
        }
        
        return fields.concat(toInject);
    }
}
#end