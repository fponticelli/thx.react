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

class Dispatcher
{
	inline static var TYPE_SEPARATOR : String = ";";

	#if macro
	public static function nonOptionalArgumentTypeAsString(fexpr : Expr, index : Int)
	{
		var t = Context.typeof(fexpr);
		if(t.argumentIsOptional(index))
			throw "handler argument cannot be optional";
		return TypeTools.toString(t.getArgumentType(index));
	}
	
	public static function argumentTypes(handler : Expr, length : Int)
	{
		return [for(i in 0...length) i].map(nonOptionalArgumentTypeAsString.bind(handler, _)).join(TYPE_SEPARATOR);
	}
	
	public static function getArity(handler : Expr)
	{
		var arity = Context.typeof(handler).getArity();
		if (arity < 0)
			throw "handler is not a function";
		return arity;
	}
	
	public static function combinedTypeInheritance(values : Array<Expr>)
	{
		var alltypes = [];
		for (value in values)
		{
			var type = Context.typeof(value),
				types = type.typeInheritance();
			if(types[types.length-1] != "Dynamic")
				types.push("Dynamic");
			alltypes.push(types);
		}
		return thx.core.Arrays.crossMulti(alltypes).map(function(a) return a.join(TYPE_SEPARATOR)).join(Binder.KEY_SEPARATOR);
	}
	#end
	public static function combinedValueTypes(values : Array<Dynamic>)
	{
		var alltypes = [];
		for (value in values)
		{
			var type = Type.typeof(value),
				types = type.typeInheritance();
			if(types[types.length-1] != "Dynamic")
				types.push("Dynamic");
			alltypes.push(types);
		}
		return thx.core.Arrays.crossMulti(alltypes).map(function(a) return a.join(TYPE_SEPARATOR)).join(Binder.KEY_SEPARATOR);
	}
	
	public var binder(default, null) : Binder;
	
	public function new()
		binder = new Binder();
	
	macro public function on(ethis : ExprOf<Dispatcher>, handler : Expr)
	{
		var arity = getArity(handler),
			types = argumentTypes(handler, arity);
		return macro $ethis.binder.bind($v{types}, new thx.core.Procedure($handler, $v{arity}));
	}

	macro public function one<T>(ethis : ExprOf<Dispatcher>, handler : Expr)
	{
		var arity = getArity(handler),
			types = argumentTypes(handler, arity);
		return macro $ethis.binder.bindOne($v{types}, new thx.core.Procedure($handler, $v{arity}));
	}

	macro public function off<T>(ethis : ExprOf<Dispatcher>, handler : Expr)
	{
		var arity = getArity(handler),
			types = argumentTypes(handler, arity);
		return macro $ethis.binder.unbind($v{types}, new thx.core.Procedure($handler, $v{arity}));
	}

	macro public function trigger<T>(ethis : ExprOf<Dispatcher>, values : Array<Expr>)
	{
		var types = combinedTypeInheritance(values);
		return macro $ethis.binder.dispatch($v{types}, $a{values});
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

	public function triggerDynamic(payloads : Array<Dynamic>)
	{
		var names = combinedValueTypes(payloads);
		binder.dispatch(names, payloads);
	}
}