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
	
	public function notify<TProgress>(notification : TProgress)
	{
		throw "not implemented yet";
		return this;
	}
	
	public function promise() : Promise<TData> return this
}