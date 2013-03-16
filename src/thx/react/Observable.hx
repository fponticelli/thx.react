package thx.react;

import thx.react.IObservable;
import thx.react.IObserver;

class Observable<T> implements IObservable<T>
{
	var observers : Array<IObserver<T>>;

	public function new()
	{
		observers = [];
	}
	public function attach(observer : IObserver<T>) 
	{
		observers.push(observer);
	}
	public function detach(observer : IObserver<T>)
	{
		observers.remove(observer);
	}
	public function clear()
	{
		observers = [];
	}
	public function notify(payload : T) 
	{
		for(observer in observers)
			observer.update(payload);
	}
}

class Observable0 implements IObservable0
{
	var observers : Array<IObserver0>;
	public function new()
	{
		observers = [];
	}
	public function attach(observer : IObserver0) 
	{
		observers.push(observer);
	}
	public function detach(observer : IObserver0)
	{
		observers.remove(observer);
	}
	public function clear()
	{
		observers = [];
	}
	public function notify() 
	{
		for(observer in observers)
			observer.update();
	}
}