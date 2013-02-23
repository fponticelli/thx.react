package thx.react;

import thx.react.ds.FunctionList;

class Binder
{
	public inline static var KEY_SEPARATOR : String = " ";
	var binds : Array<Map<String, FunctionList>>;
	public function new()
	{
		binds = [];
	}
	
	function getMap(arity : Int)
	{
		if (null == binds[arity])
			binds[arity] = new Map();
		return binds[arity];
	}
	
	public function dispatch(names : String, payload: Array<Dynamic>)
	{
		var list = null,
			map = binds[payload.length];
		if (null == map)
			return;
		try
		{
			for (name in names.split(KEY_SEPARATOR))
			{
				list = map.get(name);
				if (null == list) continue;
				for(handler in list)
					Reflect.callMethod(null, handler, payload);
			}
		} catch (e : Propagation) { }
	}
	
	public function bind(names : String, arity : Int, handler : Dynamic)
	{
		var map = getMap(arity);
		for (name in names.split(KEY_SEPARATOR)) 
		{
			var binds = map.get(name);
			if (null == binds)
				map.set(name, binds = new FunctionList());
			binds.add(handler);
		}
	}
	
	public function bindOne(names : String, arity : Int, handler : Dynamic)
	{
		var f = null;
		f = Reflect.makeVarArgs(function(args : Array<Dynamic>) {
			unbind(names, arity, f);
			Reflect.callMethod(null, handler, args);
		});
		bind(names, arity, f);
	}
	
	public function unbind(names : String, arity : Int, ?handler : Dynamic)
	{
		var map = getMap(arity);
		for (name in names.split(KEY_SEPARATOR)) 
		{
			if (null == handler)
				map.remove(name);
			else {
				var binds = map.get(name);
				if (null == binds) return;
				binds.remove(handler);
			}
		}
	}

	public function clear(?names : String)
	{
		if(null == names)
			binds = [];
		else {
			for (i in 0...binds.length)
			{
				var map = binds[i];
				if (null == map)
					continue;
				for(name in names.split(KEY_SEPARATOR))
					map.remove(name);
			}
		}
	}
/*
	public function trigger0(names : String)
		dispatch(names, []);
	public function trigger1<T1>(names : String, payload1 : T1)
		dispatch(names, [payload1]);
	public function trigger2<T1, T2>(names : String, payload1 : T1, payload2 : T2)
		dispatch(names, [payload1, payload2]);
	public function trigger3<T1, T2, T3>(names : String, payload1 : T1, payload2 : T2, payload3 : T3)
		dispatch(names, [payload1, payload2, payload3]);
	public function trigger4<T1, T2, T3, T4>(names : String, payload1 : T1, payload2 : T2, payload3 : T3, payload4 : T4)
		dispatch(names, [payload1, payload2, payload3, payload4]);
	public function trigger5<T1, T2, T3, T4, T5>(names : String, payload1 : T1, payload2 : T2, payload3 : T3, payload4 : T4, payload5 : T5)
		dispatch(names, [payload1, payload2, payload3, payload4, payload5]);
		
	public function on0(names : String, handler : Void -> Void)
		bind(names, 0, handler);
	public function on1<T1>(names : String, handler : T1 -> Void)
		bind(names, 1, handler);
	public function on2<T1, T2>(names : String, handler : T1 -> T2 -> Void)
		bind(names, 2, handler);
	public function on3<T1, T2, T3>(names : String, handler : T1 -> T2 -> T3 -> Void)
		bind(names, 3, handler);
	public function on4<T1, T2, T3, T4>(names : String, handler : T1 -> T2 -> T3 -> T4 -> Void)
		bind(names, 4, handler);
	public function on5<T1, T2, T3, T4, T5>(names : String, handler : T1 -> T2 -> T3 -> T4 -> T5 -> Void)
		bind(names, 5, handler);

	public function one0(names : String, handler : Void -> Void)
	{
		function h() {
			unbind(names, 0, h);
			handler();
		}
		bind(names, 0, h);
	}
	public function one1<T1>(names : String, handler : T1 -> Void)
	{
		function h(v1 : T1) {
			unbind(names, 1, h);
			handler(v1);
		}
		bind(names, 1, h);
	}
	public function one2<T1, T2>(names : String, handler : T1 -> T2 -> Void)
	{
		function h(v1 : T1, v2 : T2) {
			unbind(names, 2, h);
			handler(v1, v2);
		}
		bind(names, 2, h);
	}
	public function one3<T1, T2, T3>(names : String, handler : T1 -> T2 -> T3 -> Void)
	{
		function h(v1 : T1, v2 : T2, v3 : T3) {
			unbind(names, 3, h);
			handler(v1, v2, v3);
		}
		bind(names, 3, h);
	}
	public function one4<T1, T2, T3, T4>(names : String, handler : T1 -> T2 -> T3 -> T4 -> Void)
	{
		function h(v1 : T1, v2 : T2, v3 : T3, v4 : T4) {
			unbind(names, 4, h);
			handler(v1, v2, v3, v4);
		}
		bind(names, 4, h);
	}
	public function one5<T1, T2, T3, T4, T5>(names : String, handler : T1 -> T2 -> T3 -> T4 -> T5 -> Void)
	{
		function h(v1 : T1, v2 : T2, v3 : T3, v4 : T4, v5 : T5) {
			unbind(names, 5, h);
			handler(v1, v2, v3, v4, v5);
		}
		bind(names, 5, h);
	}

	public function off0(names : String, ?handler : Void -> Void)
		unbind(names, 0, handler);
	public function off1<T1>(names : String, ?handler : T1 -> Void)
		unbind(names, 1, handler);
	public function off2<T1, T2>(names : String, ?handler : T1 -> T2 -> Void)
		unbind(names, 2, handler);
	public function off3<T1, T2, T3>(names : String, ?handler : T1 -> T2 -> T3 -> Void)
		unbind(names, 3, handler);
	public function off4<T1, T2, T3, T4>(names : String, ?handler : T1 -> T2 -> T3 -> T4 -> Void)
		unbind(names, 4, handler);
	public function off5<T1, T2, T3, T4, T5>(names : String, ?handler : T1 -> T2 -> T3 -> T4 -> T5 -> Void)
		unbind(names, 5, handler);
*/
}