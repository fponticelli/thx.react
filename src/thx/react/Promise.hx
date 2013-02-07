/**
 * ...
 * @author Franco Ponticelli
 */

package thx.react;

@:access(thx.react.Dispatcher)
class Promise<TData>
{
	public inline static function value<T>(v : T)
	{
		return new Deferred().resolve(v);
	}

	var queue : Array<TData -> Void>;
	var state : PromiseState<TData>;
	var errorDispatcher : Dispatcher;
	var progressDispatcher : Dispatcher;
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
				try
				{
					while (null != (handler = queue.shift()))
						handler(data);
				} catch (e : Dynamic) {
					changeState(ProgressException(e));
					poll();
				}
			case Failure(error):
				if (null != errorDispatcher)
				{
					errorDispatcher.dispatchValue(error);
					errorDispatcher = null;
				}
			case Progress(data):
				if (null != progressDispatcher)
				{
					progressDispatcher.dispatchValue(data);
				}
			case Idle:
			case ProgressException(_):
				throw "ProgressException state should never be in the poll";
		}
	}

	function ensureErrorDispatcher() if (null == errorDispatcher) errorDispatcher = new Dispatcher()
	function ensureProgressDispatcher() if (null == progressDispatcher) progressDispatcher = new Dispatcher()

	function changeState(newstate : PromiseState<TData>)
	{
		switch[state, newstate]
		{
			case [Idle, _]:
				state = newstate;
			case [Progress(_), Progress(_)]:
				state = newstate;
			case [Success(_), ProgressException(e)]:
				state = Failure(e);
			case [_, _]:
				throw "promise was already resolved/failed, can't apply new state $newstate";
		}
		poll();
	}

	macro public function fail<TError>(ethis : haxe.macro.Expr.ExprOf<Promise<Dynamic>>, handler : haxe.macro.Expr.ExprOf<TError -> Void>)
	{
		var type = Dispatcher.nonOptionalArgumentTypeAsString(handler, 0);
		return macro $ethis.failByName($v{type}, $handler);
	}

	public function failByName<TError>(name : String, failure : TError -> Void)
	{
		ensureErrorDispatcher();
		errorDispatcher.bind(name, failure);
		poll();
		return this;
	}

	macro public function progress<TProgress>(ethis : haxe.macro.Expr.ExprOf<Promise<Dynamic>>, handler : haxe.macro.Expr.ExprOf<TProgress -> Void>)
	{
		var type = Dispatcher.nonOptionalArgumentTypeAsString(handler, 0);
		return macro $ethis.progressByName($v{type}, $handler);
	}

	public function progressByName<TProgress>(name : String, progress : TProgress -> Void)
	{
		ensureProgressDispatcher();
		progressDispatcher.bind(name, progress);
		poll();
		return this;
	}

	public function then(success : TData -> Void, ?failure : Dynamic -> Void)
	{
		queue.push(success);
		if (null != failure)
		{
			failByName("Dynamic", failure);
		} else {
			poll();
		}
		return this;
	}

	public function pipe<TNew>(success : TData -> Promise<TNew>) : Promise<TNew>
	{
		var deferred = new Deferred();
		this.then(function(data : TData) {
				var promise = success(data);
				promise.then(deferred.resolve);
			})
			.failByName("Dynamic", deferred.reject)
			.progressByName("Dynamic", deferred.notify);
		return deferred.promise();
	}
}

enum PromiseState<T> {
	Idle;
	Failure(error : Dynamic);
	Progress(data : Dynamic);
	Success(data : T);
	ProgressException(error : Dynamic);
}