package smashgl;

import haxe.macro.Context;
import haxe.macro.Expr;

#if macro
class Build{
    macro public static function init():Array<Field>{
        return Context.getBuildFields();
    }
}
#end