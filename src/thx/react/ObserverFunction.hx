package thx.react;

import thx.react.IObserver;

class ObserverFunction<T> implements IObserver<T>
{
	var handler : T -> Void;
	public function new(handler : T -> Void) {
		this.handler = handler;
	}
	public function update(payload : T)
	{
		this.handler(payload);
	}
}

class ObserverFunction0 implements IObserver0
{
	var handler : Void -> Void;
	public function new(handler : Void -> Void) {
		this.handler = handler;
	}
	public function update()
	{
		this.handler();
	}
}