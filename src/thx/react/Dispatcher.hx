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
import thx.react.ds.FunctionList;
import thx.react.Binder;

class Dispatcher
{
	inline static var KEY_SEPARATOR : String = ";";
	inline static var EVENT_SEPARATOR : String = " ";

	#if macro
	public static function nonOptionalArgumentTypeAsString(fexpr : Expr, index : Int)
	{
		var t = Context.typeof(fexpr);
		if(t.argumentIsOptional(index))
			throw "handler argument cannot be optional";
		return TypeTools.toString(t.typeOfArgument(index));
	}
	
	public static function argumentTypes(handler : Expr, length : Int)
	{
		return [for(i in 0...length) i].map(nonOptionalArgumentTypeAsString.bind(handler, _)).join(KEY_SEPARATOR);
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
		return thx.core.Arrays.crossMulti(alltypes).map(function(a) return a.join(KEY_SEPARATOR)).join(EVENT_SEPARATOR);
	}
	#end
	
	public var binder(default, null) : Binder;
	
	public function new()
		binder = new Binder();
	
	macro public function on(ethis : ExprOf<Dispatcher>, handler : Expr)
	{
		var arity = getArity(handler),
			types = argumentTypes(handler, arity);
		return macro $ethis.binder.bind($v{types}, $v{arity}, $handler);
	}

	macro public function one<T>(ethis : ExprOf<Dispatcher>, handler : Expr)
	{
		var arity = getArity(handler),
			types = argumentTypes(handler, arity);
		return macro $ethis.binder.bindOne($v{types}, $v{arity}, $handler);
	}

	macro public function off<T>(ethis : ExprOf<Dispatcher>, handler : Expr)
	{
		var arity = getArity(handler),
			types = argumentTypes(handler, arity);
		return macro $ethis.binder.unbind($v{types}, $v{arity}, $handler);
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
		var names = [Type.typeof(payload).toString()];
		if(names[names.length-1] != "Dynamic")
			names.push("Dynamic");
		binder.dispatch(names.join(Binder.KEY_SEPARATOR), [payload]);
	}
}
/*
// needs to implement DispatcherMulti
class Dispatcher2
{
	public var binder(default, null) : Binder;
	
	public function new()
		binder = new Binder();
	
	macro public function on<T1, T2>(ethis : ExprOf<Dispatcher>, handler : ExprOf<T1 -> T2 -> Void>)
	{
		var names = [for(i in 0...2) Dispatcher.nonOptionalArgumentTypeAsString(handler, i)].join(Binder.KEY_SEPARATOR);
		return macro $ethis.binder.on($v{names}, $handler);
	}

	macro public function one<T1, T2>(ethis : ExprOf<Dispatcher>, handler : ExprOf<T1 -> T2 -> Void>)
	{
		var names = [for(i in 0...2) Dispatcher.nonOptionalArgumentTypeAsString(handler, i)].join(Binder.KEY_SEPARATOR);
		return macro $ethis.binder.one($v{names}, $handler);
	}

	macro public function off<T1, T2>(ethis : ExprOf<Dispatcher>, handler : ExprOf<T1 -> T2 -> Void>)
	{
		var names = [for(i in 0...2) Dispatcher.nonOptionalArgumentTypeAsString(handler, i)].join(Binder.KEY_SEPARATOR);
		return macro $ethis.binder.off($v{names}, $handler);
	}

	public function clear(?types : Class<Dynamic>, ?name : String)
	{
		if (null != types)
			binder.clear([for(i in 0...2) Type.getClassName(types[i])].join(Binder.KEY_SEPARATOR));
		else if (null != name)
			binder.clear(name);
		else
			binder.clear();
	}

	macro public function trigger<T1, T2>(ethis : ExprOf<Dispatcher>, value1 : ExprOf<T1>, value2 : ExprOf<T2>)
	{
		var types = Context.typeof(value).typeInheritance();
		if(types[types.length-1] != "Dynamic")
			types.push("Dynamic");
		var names = types.join(Binder.KEY_SEPARATOR);
		return macro $ethis.binder.trigger($v{names}, $value);
	}

	public function triggerDynamic(payload1 : Dynamic, payload2 : Dynamic)
	{
		var names = [Type.typeof(payload).toString()];
		if(names[names.length-1] != "Dynamic")
			names.push("Dynamic");
		binder.trigger(names.join(Binder.KEY_SEPARATOR), payload);
	}
}

private class DispatcherMulti
{
	inline static var KEY_SEPARATOR : String = "|";
	var map : Map<String, FunctionList>;
	public function new()
	{
		map = new Map();
	}

	#if macro
	public static function argumentsType(handler : Expr, length : Int)
	{
		return [for(i in 0...length) i].map(Dispatcher.nonOptionalArgumentTypeAsString.bind(handler, _)).join(KEY_SEPARATOR);
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
		return thx.core.Arrays.crossMulti(alltypes).map(function(a) return a.join(KEY_SEPARATOR));
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
		return thx.core.Arrays.crossMulti(alltypes).map(function(a) return a.join(KEY_SEPARATOR));
	}
	
	function dispatchBinds(names : Array<String>, payload: Array<Dynamic>)
	{
		var binds = null;
		try
		{
			for (name in names)
			{
				if (null == name)
					continue;
				binds = map.get(name);
				if (null == binds) continue;
				for(handler in binds)
					Reflect.callMethod(null, handler, payload);
			}
		} catch (e : Propagation) { }
	}
	
	function bindMap(name : String, handler : Dynamic)
	{
		var binds = map.get(name);
		if (null == binds)
			map.set(name, binds = new FunctionList());
		binds.add(handler);
	}
	
	function unbindMap(name : String, ?handler : Dynamic)
	{
		if (null == handler)
			map.remove(name);
		else {
			var binds = map.get(name);
			if (null == binds) return;
			binds.remove(handler);
		}
	}

	public function clear()
	{
		map = new Map();
	}
	
	function clearNameArray(names : Array<String>)
	{
		map.remove(names.join(KEY_SEPARATOR));
	}
	
	function clearTypeArray(types : Array<Class<Dynamic>>)
	{
		clearNameArray(types.map(Type.getClassName));
	}
}

class Dispatcher2b extends DispatcherMulti
{
	
	macro public function on<T1, T2>(ethis : ExprOf<Dispatcher2>, handler : ExprOf<T1 -> T2 -> Void>)
	{
		var type = DispatcherMulti.argumentsType(handler, 2);
		return macro $ethis.bind($v{type}, $handler);
	}

	macro public function one<T1, T2>(ethis : ExprOf<Dispatcher2>, handler : ExprOf<T1 -> T2 -> Void>)
	{
		var type = DispatcherMulti.argumentsType(handler, 2);
		return macro $ethis.bindOne($v{type}, $handler);
	}

	macro public function off<T1, T2>(ethis : ExprOf<Dispatcher2>, handler : ExprOf<T1 -> T2 -> Void>)
	{
		var type = DispatcherMulti.argumentsType(handler, 2);
		return macro $ethis.unbind($v{type}, $handler);
	}
	
	macro public function trigger<T1, T2>(ethis : ExprOf<Dispatcher2>, value1 : ExprOf<T1>, value2 : ExprOf<T2>)
	{
		var types = DispatcherMulti.combinedTypeInheritance([value1, value2]);
		return macro $ethis.dispatch($v{types}, $value1, $value2);
	}

	public function dispatchValue<T1, T2>(payload1 : T1, payload2 : T2)
	{
		var names = DispatcherMulti.combinedValueTypes([payload1, payload2]);
		dispatch(names, payload1, payload2);
	}

	public function dispatch<T1, T2>(names : Array<String>, payload1 : T1, payload2 : T2)
	{
		dispatchBinds(names, [payload1, payload2]);
	}

	public function bind<T1, T2>(name : String, handler : T1 -> T2 -> Void)
	{
		bindMap(name, handler);
	}

	public function bindOne<T1, T2>(name : String, handler : T1 -> T2 -> Void)
	{
		function h(v1 : T1, v2 : T2) {
			unbindMap(name, h);
			handler(v1, v2);
		}
		bindMap(name, h);
	}

	public function unbind<T1, T2>(name : String, ?handler : T1 -> T2 -> Void)
	{
		unbindMap(name, handler);
	}

	public function clearNames(name1 : String, name2 : String)
	{
		clearNameArray([name1, name2]);
	}

	public function clearTypes(type1 : Class<Dynamic>, type2 : Class<Dynamic>)
	{
		clearTypeArray([type1, type2]);
	}
}

class Dispatcher3 extends DispatcherMulti
{
	
	macro public function on<T1, T2, T3>(ethis : ExprOf<Dispatcher2>, handler : ExprOf<T1 -> T2 -> T3 -> Void>)
	{
		var type = DispatcherMulti.argumentsType(handler, 3);
		return macro $ethis.bind($v{type}, $handler);
	}

	macro public function one<T1, T2, T3>(ethis : ExprOf<Dispatcher2>, handler : ExprOf<T1 -> T2 -> T3 -> Void>)
	{
		var type = DispatcherMulti.argumentsType(handler, 3);
		return macro $ethis.bindOne($v{type}, $handler);
	}

	macro public function off<T1, T2, T3>(ethis : ExprOf<Dispatcher2>, handler : ExprOf<T1 -> T2 -> T3 -> Void>)
	{
		var type = DispatcherMulti.argumentsType(handler, 3);
		return macro $ethis.unbind($v{type}, $handler);
	}
	
	macro public function trigger<T1, T2, T3>(ethis : ExprOf<Dispatcher2>, value1 : ExprOf<T1>, value2 : ExprOf<T2>, value3 : ExprOf<T3>)
	{
		var types = DispatcherMulti.combinedTypeInheritance([value1, value2, value3]);
		return macro $ethis.dispatch($v{types}, $value1, $value2, $value3);
	}

	public function dispatchValue<T1, T2, T3>(payload1 : T1, payload2 : T2, payload3 : T3)
	{
		var names = DispatcherMulti.combinedValueTypes([payload1, payload2, payload3]);
		dispatch(names, payload1, payload2, payload3);
	}

	public function dispatch<T1, T2, T3>(names : Array<String>, payload1 : T1, payload2 : T2, payload3 : T3)
	{
		dispatchBinds(names, [payload1, payload2, payload3]);
	}

	public function bind<T1, T2, T3>(name : String, handler : T1 -> T2 -> T3 -> Void)
	{
		bindMap(name, handler);
	}

	public function bindOne<T1, T2, T3>(name : String, handler : T1 -> T2 -> T3 -> Void)
	{
		function h(v1 : T1, v2 : T2, v3 : T3) {
			unbindMap(name, h);
			handler(v1, v2, v3);
		}
		bindMap(name, h);
	}

	public function unbind<T1, T2, T3>(name : String, ?handler : T1 -> T2 -> T3 -> Void)
	{
		unbindMap(name, handler);
	}

	public function clearNames(name1 : String, name2 : String, name3 : String)
	{
		clearNameArray([name1, name2, name3]);
	}

	public function clearTypes(type1 : Class<Dynamic>, type2 : Class<Dynamic>, type3 : Class<Dynamic>)
	{
		clearTypeArray([type1, type2, type3]);
	}
}

class Dispatcher4 extends DispatcherMulti
{
	
	macro public function on<T1, T2, T3, T4>(ethis : ExprOf<Dispatcher2>, handler : ExprOf<T1 -> T2 -> T3 -> T4 -> Void>)
	{
		var type = DispatcherMulti.argumentsType(handler, 4);
		return macro $ethis.bind($v{type}, $handler);
	}

	macro public function one<T1, T2, T3, T4>(ethis : ExprOf<Dispatcher2>, handler : ExprOf<T1 -> T2 -> T3 -> T4 -> Void>)
	{
		var type = DispatcherMulti.argumentsType(handler, 4);
		return macro $ethis.bindOne($v{type}, $handler);
	}

	macro public function off<T1, T2, T3, T4>(ethis : ExprOf<Dispatcher2>, handler : ExprOf<T1 -> T2 -> T3 -> T4 -> Void>)
	{
		var type = DispatcherMulti.argumentsType(handler, 4);
		return macro $ethis.unbind($v{type}, $handler);
	}
	
	macro public function trigger<T1, T2, T3, T4>(ethis : ExprOf<Dispatcher2>, value1 : ExprOf<T1>, value2 : ExprOf<T2>, value3 : ExprOf<T3>, value4 : ExprOf<T4>)
	{
		var types = DispatcherMulti.combinedTypeInheritance([value1, value2, value3, value4]);
		return macro $ethis.dispatch($v{types}, $value1, $value2, $value3, $value4);
	}

	public function dispatchValue<T1, T2, T3, T4>(payload1 : T1, payload2 : T2, payload3 : T3, payload4 : T4)
	{
		var names = DispatcherMulti.combinedValueTypes([payload1, payload2, payload3, payload4]);
		dispatch(names, payload1, payload2, payload3, payload4);
	}

	public function dispatch<T1, T2, T3, T4>(names : Array<String>, payload1 : T1, payload2 : T2, payload3 : T3, payload4 : T4)
	{
		dispatchBinds(names, [payload1, payload2, payload3, payload4]);
	}

	public function bind<T1, T2, T3, T4>(name : String, handler : T1 -> T2 -> T3 -> T4 -> Void)
	{
		bindMap(name, handler);
	}

	public function bindOne<T1, T2, T3, T4>(name : String, handler : T1 -> T2 -> T3 -> T4 -> Void)
	{
		function h(v1 : T1, v2 : T2, v3 : T3, v4 : T4) {
			unbindMap(name, h);
			handler(v1, v2, v3, v4);
		}
		bindMap(name, h);
	}

	public function unbind<T1, T2, T3, T4>(name : String, ?handler : T1 -> T2 -> T3 -> T4 -> Void)
	{
		unbindMap(name, handler);
	}

	public function clearNames(name1 : String, name2 : String, name3 : String, name4 : String)
	{
		clearNameArray([name1, name2, name3, name4]);
	}

	public function clearTypes(type1 : Class<Dynamic>, type2 : Class<Dynamic>, type3 : Class<Dynamic>, type4 : Class<Dynamic>)
	{
		clearTypeArray([type1, type2, type3, type4]);
	}
}

class Dispatcher5 extends DispatcherMulti
{
	
	macro public function on<T1, T2, T3, T4, T5>(ethis : ExprOf<Dispatcher2>, handler : ExprOf<T1 -> T2 -> T3 -> T4 -> T5 -> Void>)
	{
		var type = DispatcherMulti.argumentsType(handler, 5);
		return macro $ethis.bind($v{type}, $handler);
	}

	macro public function one<T1, T2, T3, T4, T5>(ethis : ExprOf<Dispatcher2>, handler : ExprOf<T1 -> T2 -> T3 -> T4 -> T5 -> Void>)
	{
		var type = DispatcherMulti.argumentsType(handler, 5);
		return macro $ethis.bindOne($v{type}, $handler);
	}

	macro public function off<T1, T2, T3, T4, T5>(ethis : ExprOf<Dispatcher2>, handler : ExprOf<T1 -> T2 -> T3 -> T4 -> T5 -> Void>)
	{
		var type = DispatcherMulti.argumentsType(handler, 5);
		return macro $ethis.unbind($v{type}, $handler);
	}
	
	macro public function trigger<T1, T2, T3, T4, T5>(ethis : ExprOf<Dispatcher2>, value1 : ExprOf<T1>, value2 : ExprOf<T2>, value3 : ExprOf<T3>, value4 : ExprOf<T4>, value5 : ExprOf<T5>)
	{
		var types = DispatcherMulti.combinedTypeInheritance([value1, value2, value3, value4, value5]);
		return macro $ethis.dispatch($v{types}, $value1, $value2, $value3, $value4, $value5);
	}

	public function dispatchValue<T1, T2, T3, T4, T5>(payload1 : T1, payload2 : T2, payload3 : T3, payload4 : T4, payload5 : T5)
	{
		var names = DispatcherMulti.combinedValueTypes([payload1, payload2, payload3, payload4, payload5]);
		dispatch(names, payload1, payload2, payload3, payload4, payload5);
	}

	public function dispatch<T1, T2, T3, T4, T5>(names : Array<String>, payload1 : T1, payload2 : T2, payload3 : T3, payload4 : T4, payload5 : T5)
	{
		dispatchBinds(names, [payload1, payload2, payload3, payload4, payload5]);
	}

	public function bind<T1, T2, T3, T4, T5>(name : String, handler : T1 -> T2 -> T3 -> T4 -> T5 -> Void)
	{
		bindMap(name, handler);
	}

	public function bindOne<T1, T2, T3, T4, T5>(name : String, handler : T1 -> T2 -> T3 -> T4 -> T5 -> Void)
	{
		function h(v1 : T1, v2 : T2, v3 : T3, v4 : T4, v5 : T5) {
			unbindMap(name, h);
			handler(v1, v2, v3, v4, v5);
		}
		bindMap(name, h);
	}

	public function unbind<T1, T2, T3, T4, T5>(name : String, ?handler : T1 -> T2 -> T3 -> T4 -> T5 -> Void)
	{
		unbindMap(name, handler);
	}

	public function clearNames(name1 : String, name2 : String, name3 : String, name4 : String, name5 : String)
	{
		clearNameArray([name1, name2, name3, name4, name5]);
	}

	public function clearTypes(type1 : Class<Dynamic>, type2 : Class<Dynamic>, type3 : Class<Dynamic>, type4 : Class<Dynamic>, type5 : Class<Dynamic>)
	{
		clearTypeArray([type1, type2, type3, type4, type5]);
	}
}
*/