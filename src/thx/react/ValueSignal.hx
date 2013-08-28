package thx.react;

import thx.core.Procedure;

class ValueSignal<T>
{
	private var handlers : Array<Procedure<T>>;
	private var values : Array<Dynamic>;

	function new()
	{
		handlers = new Array();
	}

	public function add(h : Procedure<T>) : Procedure<T>
	{
		handlers.push(h);
		if(values != null)
			h.apply(values);
		return h;
	}

	public function listenOnce(h : Procedure<T>) : Procedure<T>
	{
		var p : Procedure<T> = null;
		p = new Procedure(Reflect.makeVarArgs(function(args : Array<Dynamic>) {
			remove(p);
			h.apply(args);
		}), h.getArity());
		add(p);
		return p;
	}

	public function remove(h : Procedure<T>) : Bool
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
		this.values = values;
		// prevents problems with self removing events
		var list = handlers.copy();
		for(l in list)
			l.apply(values);
	}

	public function exists(?h : Procedure<T>)
	{
		if(null == untyped h)
			return handlers.length > 0;
		else {
			for (handler in handlers)
				if (h == handler)
					return true;
			return false;
		}
	}
}

class ValueSignal1<T> extends ValueSignal<T -> Void>
{
	public function new()
		super();
	public function trigger(v : T)
		triggerImpl([v]);
}

class ValueSignal2<T1, T2> extends ValueSignal<T1 -> T2 -> Void>
{
	public function new()
		super();
	public function trigger(v1 : T1, v2 : T2)
		triggerImpl([v1, v2]);
}

class ValueSignal3<T1, T2, T3> extends ValueSignal<T1 -> T2 -> T3 -> Void>
{
	public function new()
		super();
	public function trigger(v1 : T1, v2 : T2, v3 : T3)
		triggerImpl([v1, v2, v3]);
}

class ValueSignal4<T1, T2, T3, T4> extends ValueSignal<T1 -> T2 -> T3 -> T4 -> Void>
{
	public function new()
		super();
	public function trigger(v1 : T1, v2 : T2, v3 : T3, v4 : T4)
		triggerImpl([v1, v2, v3, v4]);
}

class ValueSignal5<T1, T2, T3, T4, T5> extends ValueSignal<T1 -> T2 -> T3 -> T4 -> T5 -> Void>
{
	public function new()
		super();
	public function trigger(v1 : T1, v2 : T2, v3 : T3, v4 : T4, v5 : T5)
		triggerImpl([v1, v2, v3, v4, v5]);
}