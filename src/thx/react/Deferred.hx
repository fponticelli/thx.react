package thx.react;

/**
 * ...
 * @author Franco Ponticelli
 */

class Deferred<TData> extends Promise<TData>
{
	public inline static function value<T>(v : T)
	{
		return new Deferred().resolve(v);
	}

	public function resolve(data : TData)
	{
		changeState(Success(data));
		return this;
	}

	public function reject<TError>(error : TError)
	{
		changeState(Failure(error));
		return this;
	}

	public function notify<TProgress>(data : TProgress)
	{
		changeState(Progress(data));
		return this;
	}

	public function promise() : Promise<TData> return this;

	// OVERRIDES TO RETURN PROPER TYPE
	override public function failByName<TError>(name : String, failure : TError -> Void) : Deferred<TData>
	{
		super.failByName(name, failure);
		return this;
	}

	override public function progressByName<TProgress>(name : String, progress : TProgress -> Void) : Deferred<TData>
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