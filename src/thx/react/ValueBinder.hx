package thx.react;

import haxe.ds.Option;

class ValueBinder
{
	public inline static var KEY_SEPARATOR : String = " ";
	var map : Map<String, Array<Option<Dynamic> -> Void>>;
	var values : Map<String, Dynamic>;
	public function new()
	{
		map    = new Map();
		values = new Map<String, Dynamic>();
	}

	public function dispatchSome(names : String, payload: Dynamic)
	{
		if(null == payload)
			return dispatchNone(names);
		var list = null;
		try
		{
			for (name in names.split(KEY_SEPARATOR))
			{
				values.set(name, payload);
				list = map.get(name);
				if (null == list) continue;
				for (handler in list)
					handler(Some(payload));
			}
		} catch (e : Propagation) { }
	}

	public function dispatchNone(names : String)
	{
		var list = null;
		try
		{
			for (name in names.split(KEY_SEPARATOR))
			{
				values.set(name, null);
				list = map.get(name);
				if (null == list) continue;
				for (handler in list)
					handler(None);
			}
		} catch (e : Propagation) { }
	}

	public function bind<T>(names : String, handler : Option<T> -> Void)
	{
		for (name in names.split(KEY_SEPARATOR))
		{
			var binds = map.get(name),
				value = values.get(name);
			if (null == binds)
				map.set(name, binds = []);
			binds.push(cast handler);
			handler(null == value ? None : Some(value));
		}
	}

	public function bindOne<T>(names : String, handler : Option<T> -> Void)
	{
		var p = null;
		p = function(v : Option<T>) {
			unbind(names, p);
			handler(v);
		};
		bind(names, p);
	}

	public function unbind<T>(names : String, ?handler : Option<T> -> Void)
	{
		for (name in names.split(KEY_SEPARATOR))
		{
			if (null == untyped handler) // horrible fix for problem introduced with RC2
				map.remove(name);
			else {
				var binds = map.get(name);
				if (null == binds)
					continue;
				for(i in 0...binds.length)
				{
					if(Reflect.compareMethods(binds[i], handler))
					{
						binds.splice(i, 1);
						break;
					}
				}
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

	public function reset(?names : String)
	{
		if(null == names)
			values = new Map<String, Dynamic>();
		else for(name in names.split(KEY_SEPARATOR))
			values.remove(name);
	}
}