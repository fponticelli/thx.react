/**
 * ...
 * @author Franco Ponticelli
 */

package thx.react;

import haxe.ds.StringMap;

#if macro
import haxe.macro.Expr;
import haxe.macro.TypeTools;
import haxe.macro.Context;
using thx.macro.MacroTypes;
#end

using thx.core.Types;
import thx.react.Binder;

class ValueDispatcher
{
#if macro
	public static function typeInheritance(value : Expr)
	{
		var type = Context.typeof(value),
			types = type.typeInheritance();
		if(types[types.length-1] != "Dynamic")
			types.push("Dynamic");
		return types.join(TYPE_SEPARATOR);
	}

	public static function typeInheritanceFromClass(cls : Expr)
	{
		var types = cls.typeInheritance();
		if(types[types.length-1] != "Dynamic")
			types.push("Dynamic");
		return types.join(TYPE_SEPARATOR);
	}
#end
	public static function valueTypes(value : Dynamic)
	{
		var type  = Type.typeof(value),
			types = type.typeInheritance();
		if(types[types.length-1] != "Dynamic")
			types.push("Dynamic");
		return types.join(Dispatcher.TYPE_SEPARATOR);
	}
	
	public var binder(default, null) : ValueBinder;
	
	public function new()
		binder = new ValueBinder();
	
	macro public function on<T>(ethis : ExprOf<Dispatcher>, handler : ExprOf<T -> Void>)
	{
		var types = Dispatcher.argumentTypes(handler, 1);
		return macro $ethis.binder.bind($v{types}, $handler);
	}

	macro public function one<T>(ethis : ExprOf<Dispatcher>, handler : ExprOf<T -> Void>)
	{
		var types = Dispatcher.argumentTypes(handler, 1);
		return macro $ethis.binder.bindOne($v{types}, $handler);
	}

	macro public function off<T>(ethis : ExprOf<Dispatcher>, handler : ExprOf<T -> Void>)
	{
		var types = Dispatcher.argumentTypes(handler, 1);
		return macro $ethis.binder.unbind($v{types}, $handler);
	}

	macro public function triggerNone<T>(ethis : ExprOf<Dispatcher>, type : Class<Dynamic>)
	{
		var types = typeInheritanceFromClass(type);
		return macro $ethis.binder.dispatchNone($v{types});
	}

	macro public function triggerSome<T>(ethis : ExprOf<Dispatcher>, value : Expr)
	{
		var types = typeInheritance(value);
		return macro $ethis.binder.dispatchSome($v{types}, $v{value});
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