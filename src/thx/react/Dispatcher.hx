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

class Dispatcher
{
	#if macro
	public static function extractFirstArgumentType<T>(handler : ExprOf<T -> Void>)
	{
		var type = Context.typeof(handler);
		return switch(type)
		{
			case TFun(args, _) if(args.length != 1):
				Context.error("handler function must have arity 1", handler.pos);
			case TFun(_, ret) if (switch(ret) { case TAbstract(t, _) if(t.toString() != "Void"): true; case _: false; } ):
				Context.error("handler function must return Void", handler.pos);
			case TFun(args, _) if(args[0].opt):
				Context.error("handler function argument cannot be optional", handler.pos);
			case TFun(args, _):
				exprStringOfType(args[0].t, handler.pos);
			case _:
				Context.error("handler must be a function", handler.pos);
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
		var type = extractFirstArgumentType(handler);
		return macro $ethis.bind($type, $handler);
	}

	macro public function one<T>(ethis : ExprOf<Dispatcher>, handler : ExprOf<T -> Void>)
	{
		var type = extractFirstArgumentType(handler);
		return macro $ethis.bindOnce($type, $handler);
	}

	macro public function off<T>(ethis : ExprOf<Dispatcher>, handler : ExprOf<T -> Void>)
	{
		var type = extractFirstArgumentType(handler);
		return macro $ethis.unbindOnce($type, $handler);
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
		var names = [resolveValueType(Type.typeof(payload))];
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
		} catch (e : EventCancel) { }
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

	static function resolveValueType(t : Type.ValueType)
	{
		return switch(t)
		{
			case TInt:      "Int";
			case TFloat:    "Float";
			case TBool:     "Bool";
			case TObject:   "Dynamic"; // TODO ?
			case TFunction: "Function";
			case TClass(c): Type.getClassName(c);
			case TEnum(e):  Type.getEnumName(e);
			case _:         null;
		}
	}

	@:access(thx.react.EventCancel)
	public inline static function cancel()
	{
		throw new EventCancel();
	}
/*
add .wait(other : Promise<TData2>) : Promise2<TData, TData2>
*/
}

class EventCancel
{
	private function new() { }
}