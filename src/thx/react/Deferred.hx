package thx.react;

/**
 * ...
 * @author Franco Ponticelli
 */

class Deferred<TData> extends Promise<TData>
{
	public function resolve(data : TData)
	{
		changeState(Success(data));
	}
	
	public function reject<TError>(error : TError)
	{
		changeState(Failure(error));
	}
	
	public function notify<TProgress>(notification : TProgress)
	{
		throw "not implemented yet";
	}
	
	public function promise() : Promise<TData> return this
/*
     .resolve(data : TData)
     .reject<TError>(error : TError)
     .notify<TProgress>(progress : TProgress)
     .promise() : Promise<TData>
*/
}