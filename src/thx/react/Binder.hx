package thx.react;

import thx.react.ds.FunctionList;

class BaseBinder
{
	inline static var KEY_SEPARATOR : String = " ";
	var map : Map<String, FunctionList>;
	public function new()
	{
		map = new Map();
	}
	
	function dispatch(names : String, payload: Array<Dynamic>)
	{
		var binds = null;
		try
		{
			for (name in names.split(KEY_SEPARATOR))
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
	
	function bind(names : String, handler : Dynamic)
	{
		for (name in names.split(KEY_SEPARATOR)) 
		{
			var binds = map.get(name);
			if (null == binds)
				map.set(name, binds = new FunctionList());
			binds.add(handler);
		}
	}
	
	function unbind(names : String, ?handler : Dynamic)
	{
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
			map = new Map();
		else for(name in names.split(KEY_SEPARATOR))
			map.remove(name);
	}
}

class Binder extends BaseBinder
{
	public function trigger<T1>(names : String, payload1 : T1)
		dispatch(names, [payload1]);

	public function on<T1>(names : String, handler : T1 -> Void)
		bind(names, handler);

	public function one<T1>(names : String, handler : T1 -> Void)
	{
		function h(v1 : T1) {
			unbind(names, h);
			handler(v1);
		}
		bind(names, h);
	}

	public function off<T1>(names : String, ?handler : T1 -> Void)
		unbind(names, handler);
}

class Binder0 extends BaseBinder
{
	public function trigger(names : String)
		dispatch(names, []);

	public function on(names : String, handler : Void -> Void)
		bind(names, handler);

	public function one(names : String, handler : Void -> Void)
	{
		function h() {
			unbind(names, h);
			handler();
		}
		bind(names, h);
	}

	public function off(names : String, ?handler : Void -> Void)
		unbind(names, handler);
}

class Binder2 extends BaseBinder
{
	public function trigger<T1, T2>(names : String, payload1 : T1, payload2 : T2)
		dispatch(names, [payload1, payload2]);

	public function on<T1, T2>(names : String, handler : T1 -> T2 -> Void)
		bind(names, handler);

	public function one<T1, T2>(names : String, handler : T1 -> T2 -> Void)
	{
		function h(v1 : T1, v2 : T2) {
			unbind(names, h);
			handler(v1, v2);
		}
		bind(names, h);
	}

	public function off<T1, T2>(names : String, ?handler : T1 -> T2 -> Void)
		unbind(names, handler);
}

class Binder3 extends BaseBinder
{
	public function trigger<T1, T2, T3>(names : String, payload1 : T1, payload2 : T2, payload3 : T3)
		dispatch(names, [payload1, payload2, payload3]);

	public function on<T1, T2, T3>(names : String, handler : T1 -> T2 -> T3 -> Void)
		bind(names, handler);

	public function one<T1, T2, T3>(names : String, handler : T1 -> T2 -> T3 -> Void)
	{
		function h(v1 : T1, v2 : T2, v3 : T3) {
			unbind(names, h);
			handler(v1, v2, v3);
		}
		bind(names, h);
	}

	public function off<T1, T2, T3>(names : String, ?handler : T1 -> T2 -> T3 -> Void)
		unbind(names, handler);
}

class Binder4 extends BaseBinder
{
	public function trigger<T1, T2, T3, T4>(names : String, payload1 : T1, payload2 : T2, payload3 : T3, payload4 : T4)
		dispatch(names, [payload1, payload2, payload3, payload4]);

	public function on<T1, T2, T3, T4>(names : String, handler : T1 -> T2 -> T3 -> T4 -> Void)
		bind(names, handler);

	public function one<T1, T2, T3, T4>(names : String, handler : T1 -> T2 -> T3 -> T4 -> Void)
	{
		function h(v1 : T1, v2 : T2, v3 : T3, v4 : T4) {
			unbind(names, h);
			handler(v1, v2, v3, v4);
		}
		bind(names, h);
	}

	public function off<T1, T2, T3, T4>(names : String, ?handler : T1 -> T2 -> T3 -> T4 -> Void)
		unbind(names, handler);
}

class Binder5 extends BaseBinder
{
	public function trigger<T1, T2, T3, T4, T5>(names : String, payload1 : T1, payload2 : T2, payload3 : T3, payload4 : T4, payload5 : T5)
		dispatch(names, [payload1, payload2, payload3, payload4, payload5]);

	public function on<T1, T2, T3, T4, T5>(names : String, handler : T1 -> T2 -> T3 -> T4 -> T5 -> Void)
		bind(names, handler);

	public function one<T1, T2, T3, T4, T5>(names : String, handler : T1 -> T2 -> T3 -> T4 -> T5 -> Void)
	{
		function h(v1 : T1, v2 : T2, v3 : T3, v4 : T4, v5 : T5) {
			unbind(names, h);
			handler(v1, v2, v3, v4, v5);
		}
		bind(names, h);
	}

	public function off<T1, T2, T3, T4, T5>(names : String, ?handler : T1 -> T2 -> T3 -> T4 -> T5 -> Void)
		unbind(names, handler);
}