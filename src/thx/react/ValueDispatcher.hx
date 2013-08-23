/**
 * ...
 * @author Franco Ponticelli
 */

package thx.react;

import haxe.ds.StringMap;
import haxe.ds.Option;

#if macro
import haxe.macro.Expr;
import haxe.macro.TypeTools;
import haxe.macro.Context;
using thx.macro.MacroTypes;
import haxe.macro.Type.ClassType;
#end

using thx.core.Types;
import thx.react.Binder;

class ValueDispatcher
{
#if macro
	public static function getTypeForExpression(value : Expr)
	{
		var t = Context.typeof(value);
		return TypeTools.toString(t);
	}

	public static function getTypeFromClassExpression(cls : ExprOf<Class<Dynamic>>)
	{
		return switch(cls.expr) {
			case EConst(CIdent(s)):
				return s;
			case x:
				trace(x);
				return throw "type must be a type identifier";
		};
	}
#end

	public var binder(default, null) : ValueBinder;

	public function new()
		binder = new ValueBinder();

	macro public function on<T>(ethis : ExprOf<Dispatcher>, handler : ExprOf<Option<T> -> Void>)
	{
		var type = Dispatcher.argumentTypes(handler, 1);
		return macro $ethis.binder.bind($v{type}, $handler);
	}

	macro public function one<T>(ethis : ExprOf<Dispatcher>, handler : ExprOf<Option<T> -> Void>)
	{
		var type = Dispatcher.argumentTypes(handler, 1);
		return macro $ethis.binder.bindOne($v{type}, $handler);
	}

	macro public function off<T>(ethis : ExprOf<Dispatcher>, handler : ExprOf<Option<T> -> Void>)
	{
		var type = Dispatcher.argumentTypes(handler, 1);
		return macro $ethis.binder.unbind($v{type}, $handler);
	}

	macro public function triggerNone<T>(ethis : ExprOf<Dispatcher>, cls : ExprOf<Class<Dynamic>>)
	{
		var type = 'haxe.ds.Option<${getTypeFromClassExpression(cls)}> haxe.ds.Option<Dynamic>';
		return macro $ethis.binder.dispatchNone($v{type});
	}

	macro public function triggerSome<T>(ethis : ExprOf<Dispatcher>, value : Expr)
	{
		var type = 'haxe.ds.Option<${getTypeForExpression(value)}> haxe.ds.Option<Dynamic>';
		return macro $ethis.binder.dispatchSome($v{type}, $value);
	}

	public function clear(?type : Class<Dynamic>, ?name : String)
	{
		if (null != type)
			binder.clear(Type.getClassName(type));
		else if (null != name)
			binder.clear(name);
		else
			binder.clear();
	}

	public function reset(?type : Class<Dynamic>, ?name : String)
	{
		if (null != type)
			binder.reset(Type.getClassName(type));
		else if (null != name)
			binder.reset(name);
		else
			binder.reset();
	}
}