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

	var map : Map<String, Array<Dynamic -> Void>>;
	public function new()
	{
		map = new Map();
	}

	macro public function on<T>(ethis : ExprOf<Dispatcher>, handler : ExprOf<T -> Void>)
	{
		var type = Dispatcher.nonOptionalArgumentTypeAsString(handler, 0);
		return macro $ethis.bind($v{type}, $handler);
	}

	macro public function one<T>(ethis : ExprOf<Dispatcher>, handler : ExprOf<T -> Void>)
	{
		var type = Dispatcher.nonOptionalArgumentTypeAsString(handler, 0);
		return macro $ethis.bindOne($v{type}, $handler);
	}

	macro public function off<T>(ethis : ExprOf<Dispatcher>, handler : ExprOf<T -> Void>)
	{
		var type = Dispatcher.nonOptionalArgumentTypeAsString(handler, 0);
		return macro $ethis.unbind($v{type}, $handler);
	}

	public function clearName(name : String)
	{
		map.remove(name);
	}

	public function clearType(type : Class<Dynamic>)
	{
		clearName(Type.getClassName(type));
	}

	public function clear()
	{
		map = new Map();
	}

	macro public function trigger<T>(ethis : ExprOf<Dispatcher>, value : ExprOf<T>)
	{
		var type  = Context.typeof(value),
			types = type.typeInheritance();
		if(types[types.length-1] != "Dynamic")
			types.push("Dynamic");
		return macro $ethis.dispatch($v{types}, $value);
	}

	public function dispatchValue<T>(payload : T)
	{
		var names = [Type.typeof(payload).toString()];
		if(names[names.length-1] != "Dynamic")
			names.push("Dynamic");
		dispatch(names, payload);
	}

	public function dispatch<T>(names : Array<String>, payload : T)
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

	public function bind<T>(name : String, handler : T -> Void)
	{
		var binds = map.get(name);
		if (null == binds)
			map.set(name, binds = []);
		binds.unshift(handler);
	}

	public function bindOne<T>(name : String, handler : T -> Void)
	{
		function h(v : T) {
			unbind(name, h);
			handler(v);
		}
		bind(name, h);
	}

	public function unbind<T>(name : String, ?handler : T -> Void)
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
}

private class DispatcherMulti
{
	inline static var KEY_SEPARATOR : String = "|";
	var map : StringMap<Array<Dynamic>>;
	public function new()
	{
		map = new StringMap();
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
	
	public static function dispatchBinds(map : StringMap<Array<Dynamic>>, names : Array<String>, payload: Array<Dynamic>)
	{
		var i = 0, binds = null;
		try
		{
			for (name in names)
			{
				if (null == name)
					continue;
				binds = map.get(name);
				if (null == binds) continue;
				i = binds.length;
				while (i > 0)
				{
					Reflect.callMethod(null, binds[--i], payload);
				}
			}
		} catch (e : Propagation) { }
	}
	
	public static function bindMap(map : StringMap<Array<Dynamic>>, name : String, handler : Dynamic)
	{
		var binds = map.get(name);
		if (null == binds)
			map.set(name, binds = []);
		binds.unshift(handler);
	}
	
	public static function unbindMap(map : StringMap<Array<Dynamic>>, name : String, ?handler : Dynamic)
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

	public function clear()
	{
		map = new StringMap();
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

class Dispatcher2 extends DispatcherMulti
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
		DispatcherMulti.dispatchBinds(map, names, [payload1, payload2]);
	}

	public function bind<T1, T2>(name : String, handler : T1 -> T2 -> Void)
	{
		DispatcherMulti.bindMap(map, name, handler);
	}

	public function bindOne<T1, T2>(name : String, handler : T1 -> T2 -> Void)
	{
		function h(v1 : T1, v2 : T2) {
			DispatcherMulti.unbindMap(map, name, h);
			handler(v1, v2);
		}
		DispatcherMulti.bindMap(map, name, h);
	}

	public function unbind<T1, T2>(name : String, ?handler : T1 -> T2 -> Void)
	{
		DispatcherMulti.unbindMap(map, name, handler);
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
		DispatcherMulti.dispatchBinds(map, names, [payload1, payload2, payload3]);
	}

	public function bind<T1, T2, T3>(name : String, handler : T1 -> T2 -> T3 -> Void)
	{
		DispatcherMulti.bindMap(map, name, handler);
	}

	public function bindOne<T1, T2, T3>(name : String, handler : T1 -> T2 -> T3 -> Void)
	{
		function h(v1 : T1, v2 : T2, v3 : T3) {
			DispatcherMulti.unbindMap(map, name, h);
			handler(v1, v2, v3);
		}
		DispatcherMulti.bindMap(map, name, h);
	}

	public function unbind<T1, T2, T3>(name : String, ?handler : T1 -> T2 -> T3 -> Void)
	{
		DispatcherMulti.unbindMap(map, name, handler);
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
		DispatcherMulti.dispatchBinds(map, names, [payload1, payload2, payload3, payload4]);
	}

	public function bind<T1, T2, T3, T4>(name : String, handler : T1 -> T2 -> T3 -> T4 -> Void)
	{
		DispatcherMulti.bindMap(map, name, handler);
	}

	public function bindOne<T1, T2, T3, T4>(name : String, handler : T1 -> T2 -> T3 -> T4 -> Void)
	{
		function h(v1 : T1, v2 : T2, v3 : T3, v4 : T4) {
			DispatcherMulti.unbindMap(map, name, h);
			handler(v1, v2, v3, v4);
		}
		DispatcherMulti.bindMap(map, name, h);
	}

	public function unbind<T1, T2, T3, T4>(name : String, ?handler : T1 -> T2 -> T3 -> T4 -> Void)
	{
		DispatcherMulti.unbindMap(map, name, handler);
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
		DispatcherMulti.dispatchBinds(map, names, [payload1, payload2, payload3, payload4, payload5]);
	}

	public function bind<T1, T2, T3, T4, T5>(name : String, handler : T1 -> T2 -> T3 -> T4 -> T5 -> Void)
	{
		DispatcherMulti.bindMap(map, name, handler);
	}

	public function bindOne<T1, T2, T3, T4, T5>(name : String, handler : T1 -> T2 -> T3 -> T4 -> T5 -> Void)
	{
		function h(v1 : T1, v2 : T2, v3 : T3, v4 : T4, v5 : T5) {
			DispatcherMulti.unbindMap(map, name, h);
			handler(v1, v2, v3, v4, v5);
		}
		DispatcherMulti.bindMap(map, name, h);
	}

	public function unbind<T1, T2, T3, T4, T5>(name : String, ?handler : T1 -> T2 -> T3 -> T4 -> T5 -> Void)
	{
		DispatcherMulti.unbindMap(map, name, handler);
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