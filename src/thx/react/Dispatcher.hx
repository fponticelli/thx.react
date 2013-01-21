package thx.react;

/**
 * ...
 * @author Franco Ponticelli
 */

#if macro
import haxe.macro.Expr;
import haxe.macro.TypeTools;
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
	#end
	
	var map : Hash<Array<Dynamic -> Void>>;
	public function new()
	{
		map = new Hash();
	}
	
	macro public function on<T>(ethis : ExprOf<Dispatcher>, handler : ExprOf<T -> Void>)
	{
		var type = extractFirstArgumentType(handler);
		return macro $ethis.bindByName($type, $handler);
	}
	
	macro public function one<T>(ethis : ExprOf<Dispatcher>, handler : ExprOf<T -> Void>)
	{
		var type = extractFirstArgumentType(handler);
		return macro $ethis.bindOnceByName($type, $handler);
	}
	
	macro public function off<T>(ethis : ExprOf<Dispatcher>, handler : ExprOf<T -> Void>)
	{
		var type = extractFirstArgumentType(handler);
		return macro $ethis.unbindOnceByName($type, $handler);
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
		var type = exprStringOfType(Context.typeof(value), value.pos);
		return macro $ethis.triggerByName($type, $value);
	}
	
	function triggerByValue<T>(payload : T)
	{
		var name = resolveValueType(Type.typeof(payload));
		triggerByName(name, payload);
	}
	
	function triggerByName<T>(name : String, payload : T)
	{
		var binds = map.get(name);
		if (null == binds) return;
		try
		{
			for (handler in binds.copy())
				handler(payload);
			if (name != "Dynamic")
			{
				binds = map.get("Dynamic");
				if (null == binds) return;
				for (handler in binds.copy())
					handler(payload);
			}
		} catch (e : EventCancel) { }
	}
	
	function bindByName<T>(name : String, handler : T -> Void)
	{
		var binds = map.get(name);
		if (null == binds)
			map.set(name, binds = []);
		binds.push(handler);
	}
	
	function bindOnceByName<T>(name : String, handler : T -> Void)
	{
		function h(v : T) {
			unbindByName(name, h);
			handler(v);
		}
		bindByName(name, h);
	}
	
	function unbindByName<T>(name : String, ?handler : T -> Void)
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
	 .on<T>(handler : T -> Void)
     .off<T>(?handler : T -> Void)
     .once<T>(handler : T -> Void)
     .trigger<T>(data : T)
     .when<T1...>(handler : T1... -> Void)
	*/

}

class EventCancel
{
	private function new() { }
}