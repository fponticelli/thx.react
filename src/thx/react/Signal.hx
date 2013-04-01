package thx.react;

class Signal<T> 
{
	private var handlers : Array<T -> Void>;

	public function new()
	{
		handlers = new Array();
	}

	public dynamic function on(h : T -> Void) : T -> Void
	{
		handlers.push(h);
		return h;
	}

	public function one(h : T -> Void) : T -> Void
	{
		var me = this;
		var _h = null;
		_h = function(v : T) {
			me.off(_h);
			h(v);
		};
		on(_h);
		return _h;
	}

	public function off(h : T -> Void) : Bool
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

	public function trigger(e : T)
	{
		// prevents problems with self removing events
		var list = handlers.copy();
		for(l in list)
			l(e);
	}

	public function exists(?h : T -> Void)
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