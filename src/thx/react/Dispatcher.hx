/**
 * @author Franco Ponticelli
 */

package thx.react;

import haxe.ds.StringMap;

#if macro
import haxe.macro.Expr;
import haxe.macro.TypeTools;
import haxe.macro.Context;
using thx.macro.MacroTypes;
using StringTools;
#end

using thx.core.Types;
import thx.react.Binder;

class Dispatcher
{
	public static var TYPE_SEPARATOR = ";";
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
		var types = [for(i in 0...length) i]
						.map(nonOptionalArgumentTypeAsString.bind(handler, _))
						.filter(function(t : String) return !t.startsWith("Unknown<"))
						.join(TYPE_SEPARATOR);
		return types;
	}

	public static function getArity(handler : Expr)
	{
		var arity = Context.typeof(handler).getArity();
		if (arity < 0)
			throw "handler is not a function";
		return arity;
	}

	public static function getTypesForExpressions(values : Array<Expr>)
	{
		var alltypes = values.map(function(value) return Context.typeof(value).toString());
		return alltypes.join(TYPE_SEPARATOR);
	}
	#end
	public static function getTypesForValues(values : Array<Dynamic>)
	{
		var alltypes = values.map(function(value) return Type.typeof(value).toString());
		return alltypes.join(TYPE_SEPARATOR);
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

	macro public function trigger(ethis : ExprOf<Dispatcher>, values : Array<Expr>)
	{
		var types = getTypesForExpressions(values),
			additional = [for(i in 0...values.length) "Dynamic"].join(TYPE_SEPARATOR);
		if(types != additional)
			types += ' $additional';
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
		var names = getTypesForValues(payloads),
			additional = [for(i in 0...payloads.length) "Dynamic"].join(TYPE_SEPARATOR);
		if(names != additional)
			names += ' $additional';
		binder.dispatch(names, payloads);
	}
}