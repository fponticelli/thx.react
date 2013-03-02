/**
 * ...
 * @author Franco Ponticelli
 */

package thx.react;

import thx.react.Promise;
import thx.core.Procedure;

class Deferred<TData> extends Promise<TData>
{
	public inline static function value<T>(v : T)
		return new Deferred().resolve(v);

	public function resolve(data : TData)
	{
		changeState(Success([data]));
		return promise();
	}

	public function reject<TError>(error : TError)
	{
		changeState(Failure([error]));
		return promise();
	}

	public function notify<TProgress>(data : TProgress)
	{
		changeState(Progress([data]));
		return this;
	}

	public function promise() : Promise<TData> return this;

	// OVERRIDES TO RETURN PROPER TYPE
	override public function failByName<T>(name : String, failure : Procedure<T>) : Deferred<TData>
	{
		super.failByName(name, failure);
		return this;
	}

	override public function progressByName<T>(name : String, progress : Procedure<T>) : Deferred<TData>
	{
		super.progressByName(name, progress);
		return this;
	}

	override public function then(success : TData -> Void, ?failure : Dynamic -> Void) : Deferred<TData>
	{
		super.then(success, failure);
		return this;
	}
}

class Deferred2<T1, T2> extends Promise2<T1, T2>
{
	public inline static function value<T1, T2>(v1 : T1, v2 : T2)
		return new Deferred2().resolve(v1, v2);

	public function resolve(v1 : T1, v2 : T2)
	{
		changeState(Success([v1, v2]));
		return promise();
	}

	public function reject<TError>(error : TError)
	{
		changeState(Failure([error]));
		return promise();
	}

	public function notify<TProgress>(data : TProgress)
	{
		changeState(Progress([data]));
		return this;
	}

	public function promise() : Promise2<T1, T2> return this;

	// OVERRIDES TO RETURN PROPER TYPE
	override public function failByName<T>(name : String, failure : Procedure<T>) : Deferred2<T1, T2>
	{
		super.failByName(name, failure);
		return this;
	}

	override public function progressByName<T>(name : String, progress : Procedure<T>) : Deferred2<T1, T2>
	{
		super.progressByName(name, progress);
		return this;
	}
	
	override public function then(success : T1 -> T2 -> Void, ?failure : Dynamic -> Void) : Deferred2<T1, T2>
	{
		super.then(success, failure);
		return this;
	}
}