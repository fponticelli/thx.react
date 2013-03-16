package thx.react;

import thx.react.IObservable;

class Suspendable<T> implements IObservable<T>
{
	public var dirty(default, null) : Bool = false;
	public var suspended(default, null) : Bool = false;
	var observable : Observable<T>;
	
	public function attach(observer : IObserver<T>)
	{
		(null == observable ? (observable = new Observable()) : observable).attach(observer);
	}
	public function detach(observer : IObserver<T>)
	{
		if(null != observable)
			observable.detach(observer);
	}

	public function suspend()
	{
		suspended = true;
	}

	public function resume()
	{
		if(!suspended)
			return;
		suspended = false;
		notify();
	}

	public function wrapSuspended(f : Void -> Void)
	{
		if(suspended) {
			f();
		} else {
			suspend();
			f();
			resume();
		}
	}

	function notify(setdirty = false)
	{
		if(setdirty) dirty = true;
		if(suspended || !dirty)
			return;
		dirty = false;
		if(null != observable)
			observable.notify(cast this);
	}
}