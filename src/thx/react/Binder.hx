package thx.react;

import thx.core.Procedure;
import thx.react.ds.ProcedureList;

class Binder
{
	public inline static var KEY_SEPARATOR : String = " ";
	var map : Map<String, ProcedureList<Dynamic>>;
	public function new()
	{
		map = new Map();
	}
	
	public function dispatch(names : String, payload: Array<Dynamic>)
	{
		var list = null,
			len  = payload.length;
		try
		{
			for (name in names.split(KEY_SEPARATOR))
			{
				list = map.get(name);
				if (null == list) continue;
				for (handler in list)
					if (len == handler.getArity())
						handler.apply(payload);
			}
		} catch (e : Propagation) { }
	}
	
	public function bind<T>(names : String, handler : Procedure<T>)
	{
		for (name in names.split(KEY_SEPARATOR)) 
		{
			var binds = map.get(name);
			if (null == binds)
				map.set(name, binds = new ProcedureList());
			binds.add(handler);
		}
	}
	
	public function bindOne<T>(names : String, handler : Procedure<T>)
	{
		var p : Procedure<T> = null;
		p = new Procedure(Reflect.makeVarArgs(function(args : Array<Dynamic>) {
			unbind(names, p);
			handler.apply(args);
		}), handler.getArity());
		bind(names, p);
	}
	
	public function unbind<T>(names : String, ?handler : Procedure<T>)
	{
		for (name in names.split(KEY_SEPARATOR)) 
		{
			if (null == untyped handler) // horrible fix for problem introduced with RC2
				map.remove(name);
			else {
				var binds = map.get(name);
				if (null == binds)
					continue;
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