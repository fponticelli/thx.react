package thx.react;

import thx.core.Procedure;

class Signal<T> 
{
	private var handlers : Array<Procedure<T>>;

	function new()
	{
		handlers = new Array();
	}

	public dynamic function on(h : Procedure<T>) : Procedure<T>
	{
		handlers.push(h);
		return h;
	}

	public function one(h : Procedure<T>) : Procedure<T>
	{
		var p : Procedure<T> = null;
		p = new Procedure(Reflect.makeVarArgs(function(args : Array<Dynamic>) {
			off(p);
			h.apply(args);
		}), h.getArity());
		on(p);
		return p;
	}

	public function off(h : Procedure<T>) : Bool
	{
		for(i in 0...handlers.length)
			if(Reflect.compareMethods(handlers[i], h)) {
				handlers.splice(i, 1);
				return true;
			}
		return false;
	}

	public function clear()
		handlers = [];

	function triggerImpl(values : Array<Dynamic>)
	{
		// prevents problems with self removing events
		var list = handlers.copy();
		for(l in list)
			l.apply(values);
	}

	public function exists(?h : Procedure<T>)
	{
		if(null == h)
			return handlers.length > 0;
		else {
			for (handler in handlers)
				if (h == handler)
					return true;
			return false;
		}
	}
}

class Signal0 extends Signal<Void -> Void>
{
	public function new()
		super();
	public function trigger()
		triggerImpl([]);
}

class Signal1<T> extends Signal<T -> Void>
{
	public function new()
		super();
	public function trigger(v : T)
		triggerImpl([v]);
}

class Signal2<T1, T2> extends Signal<T1 -> T2 -> Void>
{
	public function new()
		super();
	public function trigger(v1 : T1, v2 : T2)
		triggerImpl([v1, v2]);
}

class Signal3<T1, T2, T3> extends Signal<T1 -> T2 -> T3 -> Void>
{
	public function new()
		super();
	public function trigger(v1 : T1, v2 : T2, v3 : T3)
		triggerImpl([v1, v2, v3]);
}

class Signal4<T1, T2, T3, T4> extends Signal<T1 -> T2 -> T3 -> T4 -> Void>
{
	public function new()
		super();
	public function trigger(v1 : T1, v2 : T2, v3 : T3, v4 : T4)
		triggerImpl([v1, v2, v3, v4]);
}

class Signal5<T1, T2, T3, T4, T5> extends Signal<T1 -> T2 -> T3 -> T4 -> T5 -> Void>
{
	public function new()
		super();
	public function trigger(v1 : T1, v2 : T2, v3 : T3, v4 : T4, v5 : T5)
		triggerImpl([v1, v2, v3, v4, v5]);
}