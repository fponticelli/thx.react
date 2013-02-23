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
				for (handler in list)
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
}