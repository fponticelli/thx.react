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
				while (null != (handler = queue.shift()))
					handler(data);
			case Failure(error):
				if (null != errorDispatcher)
				{
					errorDispatcher.triggerByValue(error);
					errorDispatcher = null;
				}
			case Progress(data):
				if (null != progressDispatcher)
				{
					progressDispatcher.triggerByValue(data);
				}
			case Idle:
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
			case [_, _]:
				throw "promise was already resolved/failed, can't apply new state $newstate";
		}
		poll();
	}
	
	macro public function fail<TError>(ethis : haxe.macro.Expr.ExprOf<Promise<Dynamic>>, handler : haxe.macro.Expr.ExprOf<TError -> Void>)
	{
		var type = Dispatcher.extractFirstArgumentType(handler);
		return macro $ethis.failByName($type, $handler);
	}
	
	// TODO why public is required?
	public function failByName<TError>(name : String, failure : TError -> Void)
	{
		ensureErrorDispatcher();
		errorDispatcher.bindByName(name, failure);
		poll();
		return this;
	}
	
	macro public function progress<TProgress>(ethis : haxe.macro.Expr.ExprOf<Promise<Dynamic>>, handler : haxe.macro.Expr.ExprOf<TProgress -> Void>)
	{
		var type = Dispatcher.extractFirstArgumentType(handler);
		return macro $ethis.progressByName($type, $handler);
	}
	
	public function progressByName<TProgress>(name : String, failure : TProgress -> Void)
	{
		ensureProgressDispatcher();
		progressDispatcher.bindByName(name, failure);
		poll();
		return this;
	}
	
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
	Progress(data : Dynamic);
	Success(data : T);
}