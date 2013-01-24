package thx.react;

/**
 * ...
 * @author Franco Ponticelli
 */

#if macro
import haxe.macro.Expr;
import haxe.macro.TypeTools;
import haxe.macro.Type.ClassType;
import haxe.macro.Context;
#end

using thx.core.Types;

class Dispatcher
{
	#if macro
	public static function nonOptionalArgumentTypeAsString(fexpr : Expr, index : Int)
	{
		var t  = Context.typeof(fexpr),
			an = TypeTools.toString(argumentType(t, index));
		if(argumentIsOptional(t, index))
			throw "handler argument cannot be optional";
		return an;
	}

	public static function argumentIsOptional(type : haxe.macro.Type, pos : Int)
	{
		return switch(type)
		{
			case TFun(args, _) if(pos < args.length):
				args[pos].opt;
			case _:
				throw 'type $type is not a function or $pos is not a valid argument position';
		}
	}

	public static function argumentType(type : haxe.macro.Type, pos : Int)
	{
		return switch(type)
		{
			case TFun(args, _) if(pos < args.length):
				args[pos].t;
			case _:
				null;
		}
	}

	public static function exprStringOfType(type, pos)
	{
		return Context.parse('"' + TypeTools.toString(type) + '"', pos);
	}

	public static function classHierarchy(cls : ClassType)
	{
		var types = [cls.pack.concat([cls.name]).join(".")],
			parent = null == cls.superClass ? null : classHierarchy(cls.superClass.t.get());
		if(null != parent)
			types = types.concat(parent);
		return types;
	}

	public static function typeHierarchy(type)
	{
		try {
			return classHierarchy(TypeTools.getClass(type));
		} catch(e : Dynamic) {
			return [TypeTools.toString(type)];
		}
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
		return macro $ethis.bindOnce($v{type}, $handler);
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
			types = typeHierarchy(type);
		if(types[types.length-1] != "Dynamic")
			types.push("Dynamic");
		return macro $ethis.dispatch($v{types}, $value);
	}

	function triggerByValue<T>(payload : T)
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
					binds[--i](payload);
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

	function bindOnce<T>(name : String, handler : T -> Void)
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