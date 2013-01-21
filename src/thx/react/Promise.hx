package thx.react;

/**
 * ...
 * @author Franco Ponticelli
 */

class Promise<TData>
{
	public inline static function value<T>(v : T)
	{
		return new Deferred().resolve(v);
	}
	
	var queue : Array<TData -> Void>;
	var state : PromiseState<TData>;
//	var errorDispatcher : Dispatcher;
//	var progressDispatcher : Dispatcher;
	public function new()
	{
		queue = [];
		state = Idle;
	}
	
	function poll()
	{
		switch(state)
		{
			case Success(data):
				var handler;
				while (null != (handler = queue.shift()))
					handler(data);
			case Failure(error):
				trace(error);
			case Idle:
		}
	}
	
	function changeState(newstate : PromiseState<TData>)
	{
		switch(state)
		{
			case Idle:
				state = newstate;
			case _:
				throw "promise was already resolved/failed, can't apply new state $newstate";
		}
		poll();
	}
	/*
	function fail()
	{
		
	}
	*/
	public function then<TError>(success : TData -> Void)
	{
		queue.push(success);
		poll();
		return this;
	}
/*
     .then<TError>(success : TData -> Void, ?failure : TError -> Void)
     .fail<TError>(failure : TError -> Void)
     .progress<TProgress>(handler : TProgress -> Void)
     .pipe<TNew>(handler : TData -> Promise<TNew>) : Promise<TNew>
*/
	
}

enum PromiseState<T> {
	Idle;
	Failure(error : Dynamic);
	Success(data : T);
}