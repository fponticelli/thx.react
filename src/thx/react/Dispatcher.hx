/**
 * ...
 * @author Franco Ponticelli
 */

package thx.react;

#if macro
import haxe.macro.Expr;
import haxe.macro.TypeTools;
import haxe.macro.Context;
using thx.macro.MacroTypes;
#end

using thx.core.Types;

class Dispatcher
{
	#if macro
	public static function nonOptionalArgumentTypeAsString(fexpr : Expr, index : Int)
	{
		var t = Context.typeof(fexpr);
		if(t.argumentIsOptional(index))
			throw "handler argument cannot be optional";
		return TypeTools.toString(t.typeOfArgument(index));
	}
	#end

	var map : Hash<Array<Dynamic -> Void>>;
	public function new()
	{
		map = new Hash();
	}

	macro public function on<T>(ethis : ExprOf<Dispatcher>, handler : ExprOf<T -> Void>)
	{
		var type = nonOptionalArgumentTypeAsString(handler, 0);
		return macro $ethis.bind($v{type}, $handler);
	}

	macro public function one<T>(ethis : ExprOf<Dispatcher>, handler : ExprOf<T -> Void>)
	{
		var type = nonOptionalArgumentTypeAsString(handler, 0);
		return macro $ethis.bineOne($v{type}, $handler);
	}

	macro public function off<T>(ethis : ExprOf<Dispatcher>, handler : ExprOf<T -> Void>)
	{
		var type = nonOptionalArgumentTypeAsString(handler, 0);
		return macro $ethis.unbindOnce($v{type}, $handler);
	}

	@:overload(function(type : Class<Dynamic>):Void{})
	public function clear(?type : String)
	{
		if (null == type) {
			map = new Hash();
		} else if (Std.is(type, String)) {
			map.remove(type);
		} else {
			map.remove(Type.getClassName(cast type));
		}
	}

	macro public function trigger<T>(ethis : ExprOf<Dispatcher>, value : ExprOf<T>)
	{
		var type  = Context.typeof(value),
			types = type.typeInheritance();
		if(types[types.length-1] != "Dynamic")
			types.push("Dynamic");
		return macro $ethis.dispatch($v{types}, $value);
	}

	function dispatchValue<T>(payload : T)
	{
		var names = [Type.typeof(payload).toString()];
		if(names[names.length-1] != "Dynamic")
			names.push("Dynamic");
		dispatch(names, payload);
	}

	function dispatch<T>(names : Array<String>, payload : T)
	{
		var i, binds;
		try
		{
			for (name in names)
			{
				binds = map.get(""+name); // TODO this seems a bug in Neko
				if (null == binds) continue;
				i = binds.length;
				while (i > 0)
					Reflect.callMethod(null, binds[--i], [payload]);
			}
		} catch (e : Propagation) { }
	}

	function bind<T>(name : String, handler : T -> Void)
	{
		var binds = map.get(name);
		if (null == binds)
			map.set(name, binds = []);
		binds.unshift(handler);
	}

	function bindOne<T>(name : String, handler : T -> Void)
	{
		function h(v : T) {
			unbind(name, h);
			handler(v);
		}
		bind(name, h);
	}

	function unbind<T>(name : String, ?handler : T -> Void)
	{
		if (null == handler)
			map.remove(name);
		else {
			var binds = map.get(name);
			if (null == binds) return;
			for (i in 0...binds.length)
			{
				if (Reflect.compareMethods(handler, binds[i])) {
					binds.splice(i, 1);
					break;
				}
			}
		}
	}
/*
add .wait(other : Promise<TData2>) : Promise2<TData, TData2>
*/
}