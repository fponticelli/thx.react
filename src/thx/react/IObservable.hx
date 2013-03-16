package thx.react;

import thx.react.ObserverFunction;
import thx.react.IObserver;

interface IObservable<T>
{
	public function attach(observer : IObserver<T>) : Void;
	public function detach(observer : IObserver<T>) : Void;
}

interface IObservable0
{
	public function attach(observer : IObserver0) : Void;
	public function detach(observer : IObserver0) : Void;
}

class IObservables
{
	public static function addListener<T>(observable : IObservable<T>, listener : T -> Void) : IObserver<T>
	{
		var observer = new ObserverFunction(listener);
		observable.attach(observer);
		return observer;
	}
}

class IObservables0
{
	public static function addListener(observable : IObservable0, listener : Void -> Void) : IObserver0
	{
		var observer = new ObserverFunction0(listener);
		observable.attach(observer);
		return observer;
	}
}