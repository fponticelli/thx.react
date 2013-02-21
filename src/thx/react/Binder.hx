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