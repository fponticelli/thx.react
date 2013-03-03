/**
 * ...
 * @author Franco Ponticelli
 */

package thx.react;

#if macro
import haxe.macro.Expr;
#end

import thx.core.Procedure;

class Promise<T>
{
	public inline static function value<T>(v : T) : Promise<T -> Void>
		return new Deferred().resolve(v);

	var handlers : Array<ProcedureDef<T>>;
	var state : PromiseState;
	var errorDispatcher : Dispatcher;
	var progressDispatcher : Dispatcher;
	function new()
	{
		this.state = Idle;
		this.handlers = [];
	}
	
	public function then(success : ProcedureDef<T>, ?failure : Dynamic -> Void)
	{
		handlers.push(success);
		if (null != failure)
			getErrorDispatcher().binder.bind("Dynamic", failure);
		update();
		return this;
	}

	function setState(newstate : PromiseState)
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
				throw "promise was already resolved/rejected, can't apply new state $newstate";
		}
		update();
		return this;
	}
	
	function update()
	{
		switch(state)
		{
			case Idle:
			case Success(args):
				var handler;
				try
				{
					while (null != (handler = handlers.shift()))
						handler.apply(args);
				} catch (e : Dynamic) {
					setState(ProgressException([e]));
					update();
				}
			case Failure(args):
				if (null != errorDispatcher)
				{
					errorDispatcher.triggerDynamic(args);
					errorDispatcher = null;
				}
			case Progress(args):
				if (null != progressDispatcher)
				{
					progressDispatcher.triggerDynamic(args);
				}
			case ProgressException(_):
				throw "ProgressException state should never be in the poll";
		}
		return this;
	}
	
	function getErrorDispatcher()
	{
		if (null == errorDispatcher) errorDispatcher = new Dispatcher();
		return errorDispatcher;
	}
	
	function getProgressDispatcher()
	{
		if (null == progressDispatcher) progressDispatcher = new Dispatcher();
		return progressDispatcher;
	}
	
	@:noCompletion @:noDoc
	public function fail_impl(names : String, handler : Dynamic)
	{
		getErrorDispatcher().binder.bind(names, handler);
		return update();
	}
	
	@:noCompletion @:noDoc
	public function progress_impl(names : String, handler : Dynamic)
	{
		getProgressDispatcher().binder.bind(names, handler);
		return update();
	}
	
	macro public function fail<TPromise>(ethis : ExprOf<Promise<TPromise>>, handler : Expr) : ExprOf<Promise<TPromise>>
	{
		var arity = Dispatcher.getArity(handler),
			types = Dispatcher.argumentTypes(handler, arity);
		return macro $ethis.fail_impl($v{types}, new thx.core.Procedure($handler, $v{arity}));
	}
	
	macro public function progress<TPromise>(ethis : ExprOf<Promise<TPromise>>, handler : Expr)
	{
		var arity = Dispatcher.getArity(handler),
			types = Dispatcher.argumentTypes(handler, arity);
		return macro $ethis.progress_impl($v{types}, new thx.core.Procedure($handler, $v{arity}));
	}

	public function toString() return 'Promise (handlers: ${handlers.length}, state : $state)';
}

enum PromiseState {
	Idle;
	Failure (args : Array<Dynamic>);
	Progress(args : Array<Dynamic>);
	Success (args : Array<Dynamic>);
	ProgressException(error : Dynamic);
}

@:access(thx.react.Promise)
class BaseDeferred<TPromise, TDeferred>
{
	public var promise(default, null) : Promise<TPromise>;
	public function reject<TError>(error : TError)
		return promise.setState(Failure([error]));

	public function notify<TProgress>(data : TProgress) : TDeferred
	{
		promise.setState(Progress([data]));
		return cast this;
	}
	
	public function toString() return '${Type.getClassName(Type.getClass(this)).split(".").pop()} with $promise';
}

@:access(thx.react.Promise)
class Deferred0 extends BaseDeferred<Void -> Void, Deferred0>
{
	public static function pipe<TNew>(promise : Promise<Void -> Void>, success : Void -> Promise<TNew>) : Promise<TNew>
	{
		var deferred = new Deferred();
		promise.then(function() {
			success().then(cast deferred.resolve);
		});
		return cast deferred.promise;
	}
	
	public static function await0(promise : Promise<Void -> Void>, other : Promise<Void -> Void>) : Promise<Void -> Void>
	{
		var deferred = new Deferred0();
		promise.then(function() {
			other.then(cast function() {
				deferred.resolve();
			});
		});
		return deferred.promise;
	}
	
	public static function await<T1>(promise : Promise<Void -> Void>, other : Promise<T1 -> Void>) : Promise<T1 -> Void>
	{
		var deferred = new Deferred<T1>();
		promise.then(function() {
			other.then(cast function(v1 : T1) {
				deferred.resolve(v1);
			});
		});
		return deferred.promise;
	}
	
	public static function await2<T1, T2>(promise : Promise<Void -> Void>, other : Promise<T1 -> T2 -> Void>) : Promise<T1 -> T2 -> Void>
	{
		var deferred = new Deferred2<T1, T2>();
		promise.then(function() {
			other.then(cast function(v1 : T1, v2 : T2) {
				deferred.resolve(v1, v2);
			});
		});
		return deferred.promise;
	}
	
	public static function await3<T1, T2, T3>(promise : Promise<Void -> Void>, other : Promise<T1 -> T2 -> T3 -> Void>) : Promise<T1 -> T2 -> T3 -> Void>
	{
		var deferred = new Deferred3<T1, T2, T3>();
		promise.then(function() {
			other.then(cast function(v1 : T1, v2 : T2, v3 : T3) {
				deferred.resolve(v1, v2, v3);
			});
		});
		return deferred.promise;
	}
	
	public static function await4<T1, T2, T3, T4>(promise : Promise<Void -> Void>, other : Promise<T1 -> T2 -> T3 -> T4 -> Void>) : Promise<T1 -> T2 -> T3 -> T4 -> Void>
	{
		var deferred = new Deferred4<T1, T2, T3, T4>();
		promise.then(function() {
			other.then(cast function(v1 : T1, v2 : T2, v3 : T3, v4 : T4) {
				deferred.resolve(v1, v2, v3, v4);
			});
		});
		return deferred.promise;
	}
	
	public static function await5<T1, T2, T3, T4, T5>(promise : Promise<Void -> Void>, other : Promise<T1 -> T2 -> T3 -> T4 -> T5 -> Void>) : Promise<T1 -> T2 -> T3 -> T4 -> T5 -> Void>
	{
		var deferred = new Deferred5<T1, T2, T3, T4, T5>();
		promise.then(function() {
			other.then(cast function(v1 : T1, v2 : T2, v3 : T3, v4 : T4, v5 : T5) {
				deferred.resolve(v1, v2, v3, v4, v5);
			});
		});
		return deferred.promise;
	}
	
	public function new()
		promise = new Promise<Void -> Void>();
		
	public function resolve()
		return promise.setState(Success([]));
}

@:access(thx.react.Promise)
class Deferred<T1> extends BaseDeferred<T1 -> Void, Deferred<T1>>
{
	public static function pipe<T1, TNew>(promise : Promise<T1 -> Void>, success : T1 -> Promise<TNew>) : Promise<TNew>
	{
		var deferred = new Deferred();
		promise.then(function(v : T1) {
			success(v).then(cast deferred.resolve);
		});
		return cast deferred.promise;
	}
	
	public static function await0<T1>(promise : Promise<T1 -> Void>, other : Promise<Void -> Void>) : Promise<T1 -> Void>
	{
		var deferred = new Deferred<T1>();
		promise.then(function(v1 : T1) {
			other.then(cast function() {
				deferred.resolve(v1);
			});
		});
		return deferred.promise;
	}
	
	public static function await<T1, T2>(promise : Promise<T1 -> Void>, other : Promise<T2 -> Void>) : Promise<T1 -> T2 -> Void>
	{
		var deferred = new Deferred2<T1, T2>();
		promise.then(function(v1 : T1) {
			other.then(cast function(v2 : T2) {
				deferred.resolve(v1, v2);
			});
		});
		return deferred.promise;
	}
	
	public static function await2<T1, T2, T3>(promise : Promise<T1 -> Void>, other : Promise<T2 -> T3 -> Void>) : Promise<T1 -> T2 -> T3 -> Void>
	{
		var deferred = new Deferred3<T1, T2, T3>();
		promise.then(function(v1 : T1) {
			other.then(cast function(v2 : T2, v3 : T3) {
				deferred.resolve(v1, v2, v3);
			});
		});
		return deferred.promise;
	}
	
	public static function await3<T1, T2, T3, T4>(promise : Promise<T1 -> Void>, other : Promise<T2 -> T3 -> T4 -> Void>) : Promise<T1 -> T2 -> T3 -> T4 -> Void>
	{
		var deferred = new Deferred4<T1, T2, T3, T4>();
		promise.then(function(v1 : T1) {
			other.then(cast function(v2 : T2, v3 : T3, v4 : T4) {
				deferred.resolve(v1, v2, v3, v4);
			});
		});
		return deferred.promise;
	}
	
	public static function await4<T1, T2, T3, T4, T5>(promise : Promise<T1 -> Void>, other : Promise<T2 -> T3 -> T4 -> T5 -> Void>) : Promise<T1 -> T2 -> T3 -> T4 -> T5 -> Void>
	{
		var deferred = new Deferred5<T1, T2, T3, T4, T5>();
		promise.then(function(v1 : T1) {
			other.then(cast function(v2 : T2, v3 : T3, v4 : T4, v5 : T5) {
				deferred.resolve(v1, v2, v3, v4, v5);
			});
		});
		return deferred.promise;
	}
	
	public function new()
		promise = new Promise<T1 -> Void>();
		
	public function resolve(v1 : T1)
		return promise.setState(Success([v1]));
}

@:access(thx.react.Promise)
class Deferred2<T1, T2> extends BaseDeferred<T1 -> T2 -> Void, Deferred2<T1, T2>>
{
	public static function pipe<T1, T2, TNew>(promise : Promise<T1 -> T2 -> Void>, success : T1 -> T2 -> Promise<TNew>) : Promise<TNew>
	{
		var deferred = new Deferred2();
		promise.then(function(v1 : T1, v2 : T2) {
			success(v1, v2).then(cast deferred.resolve);
		});
		return cast deferred.promise;
	}
	
	public static function await0<T1, T2>(promise : Promise<T1 -> T2 -> Void>, other : Promise<Void -> Void>) : Promise<T1 -> T2 -> Void>
	{
		var deferred = new Deferred2<T1, T2>();
		promise.then(function(v1 : T1, v2 : T2) {
			other.then(cast function() {
				deferred.resolve(v1, v2);
			});
		});
		return deferred.promise;
	}
	
	public static function await<T1, T2, T3>(promise : Promise<T1 -> T2 -> Void>, other : Promise<T3 -> Void>) : Promise<T1 -> T2 -> T3 -> Void>
	{
		var deferred = new Deferred3<T1, T2, T3>();
		promise.then(function(v1 : T1, v2 : T2) {
			other.then(cast function(v3 : T3) {
				deferred.resolve(v1, v2, v3);
			});
		});
		return deferred.promise;
	}
	
	public static function await2<T1, T2, T3, T4>(promise : Promise<T1 -> T2 -> Void>, other : Promise<T3 -> T4 -> Void>) : Promise<T1 -> T2 -> T3 -> T4 -> Void>
	{
		var deferred = new Deferred4<T1, T2, T3, T4>();
		promise.then(function(v1 : T1, v2 : T2) {
			other.then(cast function(v3 : T3, v4 : T4) {
				deferred.resolve(v1, v2, v3, v4);
			});
		});
		return deferred.promise;
	}
	
	public static function await3<T1, T2, T3, T4, T5>(promise : Promise<T1 -> T2 -> Void>, other : Promise<T3 -> T4 -> T5 -> Void>) : Promise<T1 -> T2 -> T3 -> T4 -> T5 -> Void>
	{
		var deferred = new Deferred5<T1, T2, T3, T4, T5>();
		promise.then(function(v1 : T1, v2 : T2) {
			other.then(cast function(v3 : T3, v4 : T4, v5 : T5) {
				deferred.resolve(v1, v2, v3, v4, v5);
			});
		});
		return deferred.promise;
	}
	
	public function new()
		promise = new Promise<T1 -> T2 -> Void>();
		
	public function resolve(v1 : T1, v2 : T2)
		return promise.setState(Success([v1, v2]));
}

@:access(thx.react.Promise)
class Deferred3<T1, T2, T3> extends BaseDeferred<T1 -> T2 -> T3 -> Void, Deferred3<T1, T2, T3>>
{
	public static function pipe<T1, T2, T3, TNew>(promise : Promise<T1 -> T2 -> T3 -> Void>, success : T1 -> T2 -> T3 -> Promise<TNew>) : Promise<TNew>
	{
		var deferred = new Deferred3();
		promise.then(function(v1 : T1, v2 : T2, v3 : T3) {
			success(v1, v2, v3).then(cast deferred.resolve);
		});
		return cast deferred.promise;
	}
	
	public static function await0<T1, T2, T3>(promise : Promise<T1 -> T2 -> T3 -> Void>, other : Promise<Void -> Void>) : Promise<T1 -> T2 -> T3 -> Void>
	{
		var deferred = new Deferred3<T1, T2, T3>();
		promise.then(function(v1 : T1, v2 : T2, v3 : T3) {
			other.then(cast function() {
				deferred.resolve(v1, v2, v3);
			});
		});
		return deferred.promise;
	}
	
	public static function await<T1, T2, T3, T4>(promise : Promise<T1 -> T2 -> T3 -> Void>, other : Promise<T4 -> Void>) : Promise<T1 -> T2 -> T3 -> T4 -> Void>
	{
		var deferred = new Deferred4<T1, T2, T3, T4>();
		promise.then(function(v1 : T1, v2 : T2, v3 : T3) {
			other.then(cast function(v4 : T4) {
				deferred.resolve(v1, v2, v3, v4);
			});
		});
		return deferred.promise;
	}
	
	public static function await1<T1, T2, T3, T4, T5>(promise : Promise<T1 -> T2 -> T3 -> Void>, other : Promise<T4 -> T5 -> Void>) : Promise<T1 -> T2 -> T3 -> T4 -> T5 -> Void>
	{
		var deferred = new Deferred5<T1, T2, T3, T4, T5>();
		promise.then(function(v1 : T1, v2 : T2, v3 : T3) {
			other.then(cast function(v4 : T4, v5 : T5) {
				deferred.resolve(v1, v2, v3, v4, v5);
			});
		});
		return deferred.promise;
	}
	
	public function new()
		promise = new Promise<T1 -> T2 -> T3 -> Void>();
		
	public function resolve(v1 : T1, v2 : T2, v3 : T3)
		return promise.setState(Success([v1, v2, v3]));
}

@:access(thx.react.Promise)
class Deferred4<T1, T2, T3, T4> extends BaseDeferred<T1 -> T2 -> T3 -> T4 -> Void, Deferred4<T1, T2, T3, T4>>
{
	public static function pipe<T1, T2, T3, T4, TNew>(promise : Promise<T1 -> T2 -> T3 -> T4 -> Void>, success : T1 -> T2 -> T3 -> T4 -> Promise<TNew>) : Promise<TNew>
	{
		var deferred = new Deferred3();
		promise.then(function(v1 : T1, v2 : T2, v3 : T3, v4 : T4) {
			success(v1, v2, v3, v4).then(cast deferred.resolve);
		});
		return cast deferred.promise;
	}
	
	public static function await0<T1, T2, T3, T4>(promise : Promise<T1 -> T2 -> T3 -> T4 -> Void>, other : Promise<Void -> Void>) : Promise<T1 -> T2 -> T3 -> T4 -> Void>
	{
		var deferred = new Deferred4<T1, T2, T3, T4>();
		promise.then(function(v1 : T1, v2 : T2, v3 : T3, v4 : T4) {
			other.then(cast function() {
				deferred.resolve(v1, v2, v3, v4);
			});
		});
		return deferred.promise;
	}
	
	public static function await<T1, T2, T3, T4, T5>(promise : Promise<T1 -> T2 -> T3 -> T4 -> Void>, other : Promise<T5 -> Void>) : Promise<T1 -> T2 -> T3 -> T4 -> T5 -> Void>
	{
		var deferred = new Deferred5<T1, T2, T3, T4, T5>();
		promise.then(function(v1 : T1, v2 : T2, v3 : T3, v4 : T4) {
			other.then(cast function(v5 : T5) {
				deferred.resolve(v1, v2, v3, v4, v5);
			});
		});
		return deferred.promise;
	}
	
	public function new()
		promise = new Promise<T1 -> T2 -> T3 -> T4 -> Void>();
		
	public function resolve(v1 : T1, v2 : T2, v3 : T3, v4 : T4)
		return promise.setState(Success([v1, v2, v3, v4]));
}

@:access(thx.react.Promise)
class Deferred5<T1, T2, T3, T4, T5> extends BaseDeferred<T1 -> T2 -> T3 -> T4 -> T5 -> Void, Deferred5<T1, T2, T3, T4, T5>>
{
	public static function pipe<T1, T2, T3, T4, T5, TNew>(promise : Promise<T1 -> T2 -> T3 -> T4 -> T5 -> Void>, success : T1 -> T2 -> T3 -> T4 -> T5 -> Promise<TNew>) : Promise<TNew>
	{
		var deferred = new Deferred3();
		promise.then(function(v1 : T1, v2 : T2, v3 : T3, v4 : T4, v5 : T5) {
			success(v1, v2, v3, v4, v5).then(cast deferred.resolve);
		});
		return cast deferred.promise;
	}
	
	public static function await<T1, T2, T3, T4, T5>(promise : Promise<T1 -> T2 -> T3 -> T4 -> T5 -> Void>, other : Promise<Void -> Void>) : Promise<T1 -> T2 -> T3 -> T4 -> T5 -> Void>
	{
		var deferred = new Deferred5<T1, T2, T3, T4, T5>();
		promise.then(function(v1 : T1, v2 : T2, v3 : T3, v4 : T4, v5 : T5) {
			other.then(cast function() {
				deferred.resolve(v1, v2, v3, v4, v5);
			});
		});
		return deferred.promise;
	}
	
	public function new()
		promise = new Promise<T1 -> T2 -> T3 -> T4 -> T5 -> Void>();
		
	public function resolve(v1 : T1, v2 : T2, v3 : T3, v4 : T4, v5 : T5)
	return promise.setState(Success([v1, v2, v3, v4, v5]));
}