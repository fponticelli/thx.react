/**
 * ...
 * @author Franco Ponticelli
 */

package thx.react;

#if macro
import haxe.macro.Expr;
#end

import thx.core.Procedure;

using thx.react.Promise;

class Promise<T>
{
	public static function list<T>(arr : Array<Promise<T -> Void>>) : Promise<Array<T> -> Void>
	{
		var results = [],
			deferred = new Deferred(),
			pos = 0;
		arr = arr.copy();
		function queue() {
			var first = arr.shift();
			if(null == first)
			{
				deferred.resolve(results);
			} else {
				first
//					.fail(deferred.reject)
					.then(function(v : T) {
						results[pos++] = v;
						queue();
					});
			};
		}
		queue();
		return deferred.promise;
	}

	public inline static function defer0(handler : Void -> Void) : Deferred0
	{
		var deferred = new Deferred0();
		deferred.promise.then(handler);
		return deferred;
	}
	public inline static function value0() : Promise<Void -> Void>
		return new Deferred0().resolve();
	public inline static function defer<T>(handler : T -> Void) : Deferred<T>
	{
		var deferred = new Deferred<T>();
		deferred.promise.then(handler);
		return deferred;
	}
	public inline static function value<T>(v : T) : Promise<T -> Void>
		return new Deferred().resolve(v);
	public inline static function defer2<T1, T2>(handler : T1 -> T2 -> Void) : Deferred2<T1, T2>
	{
		var deferred = new Deferred2<T1, T2>();
		deferred.promise.then(handler);
		return deferred;
	}
	public inline static function value2<T1, T2>(v1 : T1, v2 : T2) : Promise<T1 -> T2 -> Void>
		return new Deferred2().resolve(v1, v2);
	public inline static function defer3<T1, T2, T3>(handler : T1 -> T2 -> T3 -> Void) : Deferred3<T1, T2, T3>
	{
		var deferred = new Deferred3<T1, T2, T3>();
		deferred.promise.then(handler);
		return deferred;
	}
	public inline static function value3<T1, T2, T3>(v1 : T1, v2 : T2, v3 : T3) : Promise<T1 -> T2 -> T3 -> Void>
		return new Deferred3().resolve(v1, v2, v3);
	public inline static function defer4<T1, T2, T3, T4>(handler : T1 -> T2 -> T3 -> T4 -> Void) : Deferred4<T1, T2, T3, T4>
	{
		var deferred = new Deferred4<T1, T2, T3, T4>();
		deferred.promise.then(handler);
		return deferred;
	}
	public inline static function value4<T1, T2, T3, T4>(v1 : T1, v2 : T2, v3 : T3, v4 : T4) : Promise<T1 -> T2 -> T3 -> T4 -> Void>
		return new Deferred4().resolve(v1, v2, v3, v4);
	public inline static function defer5<T1, T2, T3, T4, T5>(handler : T1 -> T2 -> T3 -> T4 -> T5 -> Void) : Deferred5<T1, T2, T3, T4, T5>
	{
		var deferred = new Deferred5<T1, T2, T3, T4, T5>();
		deferred.promise.then(handler);
		return deferred;
	}
	public inline static function value5<T1, T2, T3, T4, T5>(v1 : T1, v2 : T2, v3 : T3, v4 : T4, v5 : T5) : Promise<T1 -> T2 -> T3 -> T4 -> T5 -> Void>
		return new Deferred5().resolve(v1, v2, v3, v4, v5);

	var handlers_succcess : Array<ProcedureDef<T>>;
	var handlers_always : Array<Void -> Void>;
	var state : PromiseState;
	var errorDispatcher : Dispatcher;
	var progressDispatcher : Dispatcher;
	function new()
	{
		this.state = Idle;
		this.handlers_succcess = [];
		this.handlers_always = [];
	}

	public function isResolved()
		return switch(state)
		{
			case Success(_): true;
			case _: false;
		}

	public function isFailure()
		return switch(state)
		{
			case Failure(_), ProgressException(_): true;
			case _: false;
		}

	public function isComplete()
		return isResolved() || isFailure();

	public function then(success : ProcedureDef<T>, ?failure : Dynamic -> Void)
	{
		handlers_succcess.push(success);
		if (null != failure)
			getErrorDispatcher().binder.bind("Dynamic", failure);
		update();
		return this;
	}

	public function always(handler : Void -> Void)
	{
		handlers_always.push(handler);
		update();
		return this;
	}

	function setState(newstate : PromiseState)
	{
		switch[state, newstate]
		{
			case [Idle, _]:
				state = newstate;
			case [Progress(_), Idle]:
				state = newstate;
			case [Success(_), ProgressException(e)]:
				state = Failure(e);
			case [_, _]:
				throw 'promise was already $state, can\'t apply new state $newstate';
		}
		update();
		return this;
	}

	function setStateDelayed(newstate : PromiseState)
	{
#if (neko || php || cpp)
		return setState(newstate);
#elseif nodejs
		js.Node.setImmediate(function() {
			setState(newstate);
		});
		return this;
#else
		haxe.Timer.delay(function() {
			setState(newstate);
		}, 0);
		return this;
#end
	}

	function update()
	{
		switch(state)
		{
			case Idle:
			case Success(args):
				var handler_success,
					handler_always,
					empty_args = [];
				try
				{
					while (null != (handler_success = handlers_succcess.shift()))
						handler_success.apply(args);
					while (null != (handler_always = handlers_always.shift()))
						Reflect.callMethod(null, handler_always, empty_args);
				} catch (e : Dynamic) {
					setState(ProgressException([e]));
				}
			case Failure(args):
				if (null != errorDispatcher)
				{
					errorDispatcher.triggerDynamic(args);
					errorDispatcher = null;
				}
// TODO: needs better implementation when Promise doesn't have error catchers
/*
				else {
					throw new PromiseException(args);
				}
*/
				var handler_always,
					empty_args = [];
				while (null != (handler_always = handlers_always.shift()))
					Reflect.callMethod(null, handler_always, empty_args);
			case Progress(args):
				if (null != progressDispatcher)
				{
					progressDispatcher.triggerDynamic(args);
				}
				setState(Idle);
			case ProgressException(_):
				throw "ProgressException state should never be in the poll";
		}
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
	public function fail_impl(names : String, handler : Dynamic) : Promise<T>
	{
		getErrorDispatcher().binder.bind(names, handler);
		update();
		return this;
	}

	@:noCompletion @:noDoc
	public function progress_impl(names : String, handler : Dynamic) : Promise<T>
	{
		getProgressDispatcher().binder.bind(names, handler);
		update();
		return this;
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

	public function toString() return 'Promise (handlers: ${handlers_succcess.length}, state : $state)';
}

class PromiseException
{
	public var args(default, null) : Array<Dynamic>;
	public function new(args : Array<Dynamic>)
	{
		this.args = args;
	}

	public function toString()
	{
		if(Std.is(args[0], PromiseException))
			return cast(args[0], PromiseException).toString();
		else
			return 'PromiseException: ${args.join(", ")}';
	}
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
	{
		return promise.setStateDelayed(Failure([error]));
	}

	public function notify<TProgress>(data : TProgress) : TDeferred
	{
		promise.setStateDelayed(Progress([data]));
		return cast this;
	}

	public function toString() return '${Type.getClassName(Type.getClass(this)).split(".").pop()} with $promise';
}

@:access(thx.react.Promise)
class Deferred0 extends BaseDeferred<Void -> Void, Deferred0>
{
	public function new()
		promise = new Promise<Void -> Void>();

	public function resolve()
	{
		return promise.setStateDelayed(Success([]));
	}
}

@:access(thx.react.Promise)
class Deferred<T1> extends BaseDeferred<T1 -> Void, Deferred<T1>>
{
	public function new()
		promise = new Promise<T1 -> Void>();

	public function resolve(v1 : T1)
	{
		return promise.setStateDelayed(Success([v1]));
	}
}

@:access(thx.react.Promise)
class Deferred2<T1, T2> extends BaseDeferred<T1 -> T2 -> Void, Deferred2<T1, T2>>
{
	public function new()
		promise = new Promise<T1 -> T2 -> Void>();

	public function resolve(v1 : T1, v2 : T2)
		return promise.setStateDelayed(Success([v1, v2]));
}

@:access(thx.react.Promise)
class Deferred3<T1, T2, T3> extends BaseDeferred<T1 -> T2 -> T3 -> Void, Deferred3<T1, T2, T3>>
{
	public function new()
		promise = new Promise<T1 -> T2 -> T3 -> Void>();

	public function resolve(v1 : T1, v2 : T2, v3 : T3)
		return promise.setStateDelayed(Success([v1, v2, v3]));
}

@:access(thx.react.Promise)
class Deferred4<T1, T2, T3, T4> extends BaseDeferred<T1 -> T2 -> T3 -> T4 -> Void, Deferred4<T1, T2, T3, T4>>
{
	public function new()
		promise = new Promise<T1 -> T2 -> T3 -> T4 -> Void>();

	public function resolve(v1 : T1, v2 : T2, v3 : T3, v4 : T4)
		return promise.setStateDelayed(Success([v1, v2, v3, v4]));
}

@:access(thx.react.Promise)
class Deferred5<T1, T2, T3, T4, T5> extends BaseDeferred<T1 -> T2 -> T3 -> T4 -> T5 -> Void, Deferred5<T1, T2, T3, T4, T5>>
{
	public function new()
		promise = new Promise<T1 -> T2 -> T3 -> T4 -> T5 -> Void>();

	public function resolve(v1 : T1, v2 : T2, v3 : T3, v4 : T4, v5 : T5)
	return promise.setStateDelayed(Success([v1, v2, v3, v4, v5]));
}


// PROMISE HELPERS
class Promises5
{
	public static function lose1<T1, T2, T3, T4, T5>(promise : Promise<T1 -> T2 -> T3 -> T4 -> T5 -> Void>) : Promise<T1 -> T2 -> T3 -> T4 -> Void>
	{
		var deferred = new Deferred4();
		promise.then(function(v1, v2, v3, v4, _) deferred.resolve(v1, v2, v3, v4), deferred.reject);
		return deferred.promise;
	}

	public static function lose2<T1, T2, T3, T4, T5>(promise : Promise<T1 -> T2 -> T3 -> T4 -> T5 -> Void>) : Promise<T1 -> T2 -> T3 -> Void>
	{
		var deferred = new Deferred3();
		promise.then(function(v1, v2, v3, _, _) deferred.resolve(v1, v2, v3), deferred.reject);
		return deferred.promise;
	}

	public static function lose3<T1, T2, T3, T4, T5>(promise : Promise<T1 -> T2 -> T3 -> T4 -> T5 -> Void>) : Promise<T1 -> T2 -> Void>
	{
		var deferred = new Deferred2();
		promise.then(function(v1, v2, _, _, _) deferred.resolve(v1, v2), deferred.reject);
		return deferred.promise;
	}

	public static function lose4<T1, T2, T3, T4, T5>(promise : Promise<T1 -> T2 -> T3 -> T4 -> T5 -> Void>) : Promise<T1 -> Void>
	{
		var deferred = new Deferred();
		promise.then(function(v1, _, _, _, _) deferred.resolve(v1), deferred.reject);
		return deferred.promise;
	}

	public static function lose5<T1, T2, T3, T4, T5>(promise : Promise<T1 -> T2 -> T3 -> T4 -> T5 -> Void>) : Promise<Void -> Void>
	{
		var deferred = new Deferred0();
		promise.then(function(_, _, _, _, _) deferred.resolve(), deferred.reject);
		return deferred.promise;
	}

	public static function await0<T1, T2, T3, T4, T5>(promise : Promise<T1 -> T2 -> T3 -> T4 -> T5 -> Void>, other : Promise<Void -> Void>) : Promise<T1 -> T2 -> T3 -> T4 -> T5 -> Void>
	{
		var deferred = new Deferred5<T1, T2, T3, T4, T5>();
		promise.then(function(v1 : T1, v2 : T2, v3 : T3, v4 : T4, v5 : T5) {
			other.then(function() {
				deferred.resolve(v1, v2, v3, v4, v5);
			});
		});
		return deferred.promise;
	}

	public static function transform<T1, T2, T3, T4, T5, TNew>(promise : Promise<T1 -> T2 -> T3 -> T4 -> T5 -> Void>, success : T1 -> T2 -> T3 -> T4 -> T5 -> TNew) : Promise<TNew -> Void>
	{
		var deferred = new Deferred<TNew>();
		promise.then(
			function(v1 : T1, v2 : T2, v3 : T3, v4 : T4, v5 : T5) deferred.resolve(success(v1, v2, v3, v4, v5)),
			deferred.reject
		);
		return deferred.promise;
	}

	public static function pipe0<T1, T2, T3, T4, T5>(promise : Promise<T1 -> T2 -> T3 -> T4 -> T5 -> Void>, success : T1 -> T2 -> T3 -> T4 -> T5 -> Promise<Void -> Void>) : Promise<Void -> Void>
	{
		var deferred = new Deferred0();
		promise.then(
			function(v1 : T1, v2 : T2, v3 : T3, v4 : T4, v5 : T5) success(v1, v2, v3, v4, v5).then(deferred.resolve),
			deferred.reject
		);
		return deferred.promise;
	}

	public static function pipe<T1, T2, T3, T4, T5, TNew>(promise : Promise<T1 -> T2 -> T3 -> T4 -> T5 -> Void>, success : T1 -> T2 -> T3 -> T4 -> T5 -> Promise<TNew -> Void>) : Promise<TNew -> Void>
	{
		var deferred = new Deferred<TNew>();
		promise.then(
			function(v1 : T1, v2 : T2, v3 : T3, v4 : T4, v5 : T5) success(v1, v2, v3, v4, v5).then(deferred.resolve),
			deferred.reject
		);
		return deferred.promise;
	}

	public static function pipe2<T1, T2, T3, T4, T5, TN1, TN2>(promise : Promise<T1 -> T2 -> T3 -> T4 -> T5 -> Void>, success : T1 -> T2 -> T3 -> T4 -> T5 -> Promise<TN1 -> TN2 -> Void>) : Promise<TN1 -> TN2 -> Void>
	{
		var deferred = new Deferred2<TN1, TN2>();
		promise.then(
			function(v1 : T1, v2 : T2, v3 : T3, v4 : T4, v5 : T5) success(v1, v2, v3, v4, v5).then(deferred.resolve),
			deferred.reject
		);
		return deferred.promise;
	}

	public static function pipe3<T1, T2, T3, T4, T5, TN1, TN2, TN3>(promise : Promise<T1 -> T2 -> T3 -> T4 -> T5 -> Void>, success : T1 -> T2 -> T3 -> T4 -> T5 -> Promise<TN1 -> TN2 -> TN3 -> Void>) : Promise<TN1 -> TN2 -> TN3 -> Void>
	{
		var deferred = new Deferred3<TN1, TN2, TN3>();
		promise.then(
			function(v1 : T1, v2 : T2, v3 : T3, v4 : T4, v5 : T5) success(v1, v2, v3, v4, v5).then(deferred.resolve),
			deferred.reject
		);
		return deferred.promise;
	}

	public static function pipe4<T1, T2, T3, T4, T5, TN1, TN2, TN3, TN4>(promise : Promise<T1 -> T2 -> T3 -> T4 -> T5 -> Void>, success : T1 -> T2 -> T3 -> T4 -> T5 -> Promise<TN1 -> TN2 -> TN3 -> TN4 -> Void>) : Promise<TN1 -> TN2 -> TN3 -> TN4 -> Void>
	{
		var deferred = new Deferred4<TN1, TN2, TN3, TN4>();
		promise.then(
			function(v1 : T1, v2 : T2, v3 : T3, v4 : T4, v5 : T5) success(v1, v2, v3, v4, v5).then(deferred.resolve),
			deferred.reject
		);
		return deferred.promise;
	}

	public static function pipe5<T1, T2, T3, T4, T5, TN1, TN2, TN3, TN4, TN5>(promise : Promise<T1 -> T2 -> T3 -> T4 -> T5 -> Void>, success : T1 -> T2 -> T3 -> T4 -> T5 -> Promise<TN1 -> TN2 -> TN3 -> TN4 -> TN5 -> Void>) : Promise<TN1 -> TN2 -> TN3 -> TN4 -> TN5 -> Void>
	{
		var deferred = new Deferred5<TN1, TN2, TN3, TN4, TN5>();
		promise.then(
			function(v1 : T1, v2 : T2, v3 : T3, v4 : T4, v5 : T5) success(v1, v2, v3, v4, v5).then(deferred.resolve),
			deferred.reject
		);
		return deferred.promise;
	}
}

class Promises4
{
	public static function lose1<T1, T2, T3, T4>(promise : Promise<T1 -> T2 -> T3 -> T4 -> Void>) : Promise<T1 -> T2 -> T3 -> Void>
	{
		var deferred = new Deferred3();
		promise.then(function(v1, v2, v3, _) deferred.resolve(v1, v2, v3), deferred.reject);
		return deferred.promise;
	}

	public static function lose2<T1, T2, T3, T4>(promise : Promise<T1 -> T2 -> T3 -> T4 -> Void>) : Promise<T1 -> T2 -> Void>
	{
		var deferred = new Deferred2();
		promise.then(function(v1, v2, _, _) deferred.resolve(v1, v2), deferred.reject);
		return deferred.promise;
	}

	public static function lose3<T1, T2, T3, T4>(promise : Promise<T1 -> T2 -> T3 -> T4 -> Void>) : Promise<T1 -> Void>
	{
		var deferred = new Deferred();
		promise.then(function(v1, _, _, _) deferred.resolve(v1), deferred.reject);
		return deferred.promise;
	}

	public static function lose4<T1, T2, T3, T4>(promise : Promise<T1 -> T2 -> T3 -> T4 -> Void>) : Promise<Void -> Void>
	{
		var deferred = new Deferred0();
		promise.then(function(_, _, _, _) deferred.resolve(), deferred.reject);
		return deferred.promise;
	}

	public static function await0<T1, T2, T3, T4>(promise : Promise<T1 -> T2 -> T3 -> T4 -> Void>, other : Promise<Void -> Void>) : Promise<T1 -> T2 -> T3 -> T4 -> Void>
	{
		var deferred = new Deferred4<T1, T2, T3, T4>();
		promise.then(function(v1 : T1, v2 : T2, v3 : T3, v4 : T4) {
			other.then(function() {
				deferred.resolve(v1, v2, v3, v4);
			});
		});
		return deferred.promise;
	}

	public static function with<T1, T2, T3, T4, T5>(promise : Promise<T1 -> T2 -> T3 -> T4 -> Void>, value : T5) : Promise<T1 -> T2 -> T3 -> T4 -> T5 -> Void>
		return await(promise, Promise.value(value));

	public static function await<T1, T2, T3, T4, T5>(promise : Promise<T1 -> T2 -> T3 -> T4 -> Void>, other : Promise<T5 -> Void>) : Promise<T1 -> T2 -> T3 -> T4 -> T5 -> Void>
	{
		var deferred = new Deferred5<T1, T2, T3, T4, T5>();
		promise.then(function(v1 : T1, v2 : T2, v3 : T3, v4 : T4) {
			other.then(function(v5 : T5) {
				deferred.resolve(v1, v2, v3, v4, v5);
			});
		});
		return deferred.promise;
	}

	public static function transform<T1, T2, T3, T4, TNew>(promise : Promise<T1 -> T2 -> T3 -> T4 -> Void>, success : T1 -> T2 -> T3 -> T4 -> TNew) : Promise<TNew -> Void>
	{
		var deferred = new Deferred<TNew>();
		promise.then(
			function(v1 : T1, v2 : T2, v3 : T3, v4 : T4) deferred.resolve(success(v1, v2, v3, v4)),
			deferred.reject
		);
		return deferred.promise;
	}

	public static function pipe0<T1, T2, T3, T4>(promise : Promise<T1 -> T2 -> T3 -> T4 -> Void>, success : T1 -> T2 -> T3 -> T4 -> Promise<Void -> Void>) : Promise<Void -> Void>
	{
		var deferred = new Deferred0();
		promise.then(
			function(v1 : T1, v2 : T2, v3 : T3, v4 : T4) success(v1, v2, v3, v4).then(deferred.resolve),
			deferred.reject
		);
		return deferred.promise;
	}

	public static function pipe<T1, T2, T3, T4, TNew>(promise : Promise<T1 -> T2 -> T3 -> T4 -> Void>, success : T1 -> T2 -> T3 -> T4 -> Promise<TNew -> Void>) : Promise<TNew -> Void>
	{
		var deferred = new Deferred<TNew>();
		promise.then(
			function(v1 : T1, v2 : T2, v3 : T3, v4 : T4) success(v1, v2, v3, v4).then(deferred.resolve),
			deferred.reject
		);
		return deferred.promise;
	}

	public static function pipe2<T1, T2, T3, T4, TN1, TN2>(promise : Promise<T1 -> T2 -> T3 -> T4 -> Void>, success : T1 -> T2 -> T3 -> T4 -> Promise<TN1 -> TN2 -> Void>) : Promise<TN1 -> TN2 -> Void>
	{
		var deferred = new Deferred2<TN1, TN2>();
		promise.then(
			function(v1 : T1, v2 : T2, v3 : T3, v4 : T4) success(v1, v2, v3, v4).then(deferred.resolve),
			deferred.reject
		);
		return deferred.promise;
	}

	public static function pipe3<T1, T2, T3, T4, TN1, TN2, TN3>(promise : Promise<T1 -> T2 -> T3 -> T4 -> Void>, success : T1 -> T2 -> T3 -> T4 -> Promise<TN1 -> TN2 -> TN3 -> Void>) : Promise<TN1 -> TN2 -> TN3 -> Void>
	{
		var deferred = new Deferred3<TN1, TN2, TN3>();
		promise.then(
			function(v1 : T1, v2 : T2, v3 : T3, v4 : T4) success(v1, v2, v3, v4).then(deferred.resolve),
			deferred.reject
		);
		return deferred.promise;
	}

	public static function pipe4<T1, T2, T3, T4, TN1, TN2, TN3, TN4>(promise : Promise<T1 -> T2 -> T3 -> T4 -> Void>, success : T1 -> T2 -> T3 -> T4 -> Promise<TN1 -> TN2 -> TN3 -> TN4 -> Void>) : Promise<TN1 -> TN2 -> TN3 -> TN4 -> Void>
	{
		var deferred = new Deferred4<TN1, TN2, TN3, TN4>();
		promise.then(
			function(v1 : T1, v2 : T2, v3 : T3, v4 : T4) success(v1, v2, v3, v4).then(deferred.resolve),
			deferred.reject
		);
		return deferred.promise;
	}

	public static function pipe5<T1, T2, T3, T4, TN1, TN2, TN3, TN4, TN5>(promise : Promise<T1 -> T2 -> T3 -> T4 -> Void>, success : T1 -> T2 -> T3 -> T4 -> Promise<TN1 -> TN2 -> TN3 -> TN4 -> TN5 -> Void>) : Promise<TN1 -> TN2 -> TN3 -> TN4 -> TN5 -> Void>
	{
		var deferred = new Deferred5<TN1, TN2, TN3, TN4, TN5>();
		promise.then(
			function(v1 : T1, v2 : T2, v3 : T3, v4 : T4) success(v1, v2, v3, v4).then(deferred.resolve),
			deferred.reject
		);
		return deferred.promise;
	}
}

class Promises3
{
	public static function lose1<T1, T2, T3>(promise : Promise<T1 -> T2 -> T3 -> Void>) : Promise<T1 -> T2 -> Void>
	{
		var deferred = new Deferred2();
		promise.then(function(v1, v2, _) deferred.resolve(v1, v2), deferred.reject);
		return deferred.promise;
	}

	public static function lose2<T1, T2, T3>(promise : Promise<T1 -> T2 -> T3 -> Void>) : Promise<T1 -> Void>
	{
		var deferred = new Deferred();
		promise.then(function(v1, _, _) deferred.resolve(v1), deferred.reject);
		return deferred.promise;
	}

	public static function lose3<T1, T2, T3>(promise : Promise<T1 -> T2 -> T3 -> Void>) : Promise<Void -> Void>
	{
		var deferred = new Deferred0();
		promise.then(function(_, _, _) deferred.resolve(), deferred.reject);
		return deferred.promise;
	}

	public static function await0<T1, T2, T3>(promise : Promise<T1 -> T2 -> T3 -> Void>, other : Promise<Void -> Void>) : Promise<T1 -> T2 -> T3 -> Void>
	{
		var deferred = new Deferred3<T1, T2, T3>();
		promise.then(function(v1 : T1, v2 : T2, v3 : T3) {
			other.then(function() {
				deferred.resolve(v1, v2, v3);
			});
		});
		return deferred.promise;
	}

	public static function with<T1, T2, T3, T4>(promise : Promise<T1 -> T2 -> T3 -> Void>, value : T4) : Promise<T1 -> T2 -> T3 -> T4 -> Void>
		return await(promise, Promise.value(value));

	public static function await<T1, T2, T3, T4>(promise : Promise<T1 -> T2 -> T3 -> Void>, other : Promise<T4 -> Void>) : Promise<T1 -> T2 -> T3 -> T4 -> Void>
	{
		var deferred = new Deferred4<T1, T2, T3, T4>();
		promise.then(function(v1 : T1, v2 : T2, v3 : T3) {
			other.then(function(v4 : T4) {
				deferred.resolve(v1, v2, v3, v4);
			});
		});
		return deferred.promise;
	}

	public static function await2<T1, T2, T3, T4, T5>(promise : Promise<T1 -> T2 -> T3 -> Void>, other : Promise<T4 -> T5 -> Void>) : Promise<T1 -> T2 -> T3 -> T4 -> T5 -> Void>
	{
		var deferred = new Deferred5<T1, T2, T3, T4, T5>();
		promise.then(function(v1 : T1, v2 : T2, v3 : T3) {
			other.then(function(v4 : T4, v5 : T5) {
				deferred.resolve(v1, v2, v3, v4, v5);
			});
		});
		return deferred.promise;
	}

	public static function transform<T1, T2, T3, TNew>(promise : Promise<T1 -> T2 -> T3 -> Void>, success : T1 -> T2 -> T3 -> TNew) : Promise<TNew -> Void>
	{
		var deferred = new Deferred<TNew>();
		promise.then(
			function(v1 : T1, v2 : T2, v3 : T3) deferred.resolve(success(v1, v2, v3)),
			deferred.reject
		);
		return deferred.promise;
	}

	public static function pipe0<T1, T2, T3>(promise : Promise<T1 -> T2 -> T3 -> Void>, success : T1 -> T2 -> T3 -> Promise<Void -> Void>) : Promise<Void -> Void>
	{
		var deferred = new Deferred0();
		promise.then(
			function(v1 : T1, v2 : T2, v3 : T3) success(v1, v2, v3).then(deferred.resolve),
			deferred.reject
		);
		return deferred.promise;
	}

	public static function pipe<T1, T2, T3, TNew>(promise : Promise<T1 -> T2 -> T3 -> Void>, success : T1 -> T2 -> T3 -> Promise<TNew -> Void>) : Promise<TNew -> Void>
	{
		var deferred = new Deferred<TNew>();
		promise.then(
			function(v1 : T1, v2 : T2, v3 : T3) success(v1, v2, v3).then(deferred.resolve),
			deferred.reject
		);
		return deferred.promise;
	}

	public static function pipe2<T1, T2, T3, TN1, TN2>(promise : Promise<T1 -> T2 -> T3 -> Void>, success : T1 -> T2 -> T3 -> Promise<TN1 -> TN2 -> Void>) : Promise<TN1 -> TN2 -> Void>
	{
		var deferred = new Deferred2<TN1, TN2>();
		promise.then(
			function(v1 : T1, v2 : T2, v3 : T3) success(v1, v2, v3).then(deferred.resolve),
			deferred.reject
		);
		return deferred.promise;
	}

	public static function pipe3<T1, T2, T3, TN1, TN2, TN3>(promise : Promise<T1 -> T2 -> T3 -> Void>, success : T1 -> T2 -> T3 -> Promise<TN1 -> TN2 -> TN3 -> Void>) : Promise<TN1 -> TN2 -> TN3 -> Void>
	{
		var deferred = new Deferred3<TN1, TN2, TN3>();
		promise.then(
			function(v1 : T1, v2 : T2, v3 : T3) success(v1, v2, v3).then(deferred.resolve),
			deferred.reject
		);
		return deferred.promise;
	}

	public static function pipe4<T1, T2, T3, TN1, TN2, TN3, TN4>(promise : Promise<T1 -> T2 -> T3 -> Void>, success : T1 -> T2 -> T3 -> Promise<TN1 -> TN2 -> TN3 -> TN4 -> Void>) : Promise<TN1 -> TN2 -> TN3 -> TN4 -> Void>
	{
		var deferred = new Deferred4<TN1, TN2, TN3, TN4>();
		promise.then(
			function(v1 : T1, v2 : T2, v3 : T3) success(v1, v2, v3).then(deferred.resolve),
			deferred.reject
		);
		return deferred.promise;
	}

	public static function pipe5<T1, T2, T3, TN1, TN2, TN3, TN4, TN5>(promise : Promise<T1 -> T2 -> T3 -> Void>, success : T1 -> T2 -> T3 -> Promise<TN1 -> TN2 -> TN3 -> TN4 -> TN5 -> Void>) : Promise<TN1 -> TN2 -> TN3 -> TN4 -> TN5 -> Void>
	{
		var deferred = new Deferred5<TN1, TN2, TN3, TN4, TN5>();
		promise.then(
			function(v1 : T1, v2 : T2, v3 : T3) success(v1, v2, v3).then(deferred.resolve),
			deferred.reject
		);
		return deferred.promise;
	}
}

class Promises2
{
	public static function lose1<T1, T2>(promise : Promise<T1 -> T2 -> Void>) : Promise<T1 -> Void>
	{
		var deferred = new Deferred();
		promise.then(function(v1, _) deferred.resolve(v1), deferred.reject);
		return deferred.promise;
	}

	public static function lose2<T1, T2>(promise : Promise<T1 -> T2 -> Void>) : Promise<Void -> Void>
	{
		var deferred = new Deferred0();
		promise.then(function(_, _) deferred.resolve(), deferred.reject);
		return deferred.promise;
	}

	public static function await0<T1, T2>(promise : Promise<T1 -> T2 -> Void>, other : Promise<Void -> Void>) : Promise<T1 -> T2 -> Void>
	{
		var deferred = new Deferred2<T1, T2>();
		promise.then(function(v1 : T1, v2 : T2) {
			other.then(function() {
				deferred.resolve(v1, v2);
			});
		});
		return deferred.promise;
	}

	public static function with<T1, T2, T3>(promise : Promise<T1 -> T2 -> Void>, value : T3) : Promise<T1 -> T2 -> T3 -> Void>
		return await(promise, Promise.value(value));

	public static function await<T1, T2, T3>(promise : Promise<T1 -> T2 -> Void>, other : Promise<T3 -> Void>) : Promise<T1 -> T2 -> T3 -> Void>
	{
		var deferred = new Deferred3<T1, T2, T3>();
		promise.then(function(v1 : T1, v2 : T2) {
			other.then(function(v3 : T3) {
				deferred.resolve(v1, v2, v3);
			});
		});
		return deferred.promise;
	}

	public static function await2<T1, T2, T3, T4>(promise : Promise<T1 -> T2 -> Void>, other : Promise<T3 -> T4 -> Void>) : Promise<T1 -> T2 -> T3 -> T4 -> Void>
	{
		var deferred = new Deferred4<T1, T2, T3, T4>();
		promise.then(function(v1 : T1, v2 : T2) {
			other.then(function(v3 : T3, v4 : T4) {
				deferred.resolve(v1, v2, v3, v4);
			});
		});
		return deferred.promise;
	}

	public static function await3<T1, T2, T3, T4, T5>(promise : Promise<T1 -> T2 -> Void>, other : Promise<T3 -> T4 -> T5 -> Void>) : Promise<T1 -> T2 -> T3 -> T4 -> T5 -> Void>
	{
		var deferred = new Deferred5<T1, T2, T3, T4, T5>();
		promise.then(function(v1 : T1, v2 : T2) {
			other.then(function(v3 : T3, v4 : T4, v5 : T5) {
				deferred.resolve(v1, v2, v3, v4, v5);
			});
		});
		return deferred.promise;
	}

	public static function transform<T1, T2, TNew>(promise : Promise<T1 -> T2 -> Void>, success : T1 -> T2 -> TNew) : Promise<TNew -> Void>
	{
		var deferred = new Deferred<TNew>();
		promise.then(
			function(v1 : T1, v2 : T2) deferred.resolve(success(v1, v2)),
			deferred.reject
		);
		return deferred.promise;
	}

	public static function pipe0<T1, T2>(promise : Promise<T1 -> T2 -> Void>, success : T1 -> T2 -> Promise<Void -> Void>) : Promise<Void -> Void>
	{
		var deferred = new Deferred0();
		promise.then(
			function(v1 : T1, v2 : T2) success(v1, v2).then(deferred.resolve),
			deferred.reject
		);
		return deferred.promise;
	}

	public static function pipe<T1, T2, TNew>(promise : Promise<T1 -> T2 -> Void>, success : T1 -> T2 -> Promise<TNew -> Void>) : Promise<TNew -> Void>
	{
		var deferred = new Deferred<TNew>();
		promise.then(
			function(v1 : T1, v2 : T2) success(v1, v2).then(deferred.resolve),
			deferred.reject
		);
		return deferred.promise;
	}

	public static function pipe2<T1, T2, TN1, TN2>(promise : Promise<T1 -> T2 -> Void>, success : T1 -> T2 -> Promise<TN1 -> TN2 -> Void>) : Promise<TN1 -> TN2 -> Void>
	{
		var deferred = new Deferred2<TN1, TN2>();
		promise.then(
			function(v1 : T1, v2 : T2) success(v1, v2).then(deferred.resolve),
			deferred.reject
		);
		return deferred.promise;
	}

	public static function pipe3<T1, T2, TN1, TN2, TN3>(promise : Promise<T1 -> T2 -> Void>, success : T1 -> T2 -> Promise<TN1 -> TN2 -> TN3 -> Void>) : Promise<TN1 -> TN2 -> TN3 -> Void>
	{
		var deferred = new Deferred3<TN1, TN2, TN3>();
		promise.then(
			function(v1 : T1, v2 : T2) success(v1, v2).then(deferred.resolve),
			deferred.reject
		);
		return deferred.promise;
	}

	public static function pipe4<T1, T2, TN1, TN2, TN3, TN4>(promise : Promise<T1 -> T2 -> Void>, success : T1 -> T2 -> Promise<TN1 -> TN2 -> TN3 -> TN4 -> Void>) : Promise<TN1 -> TN2 -> TN3 -> TN4 -> Void>
	{
		var deferred = new Deferred4<TN1, TN2, TN3, TN4>();
		promise.then(
			function(v1 : T1, v2 : T2) success(v1, v2).then(deferred.resolve),
			deferred.reject
		);
		return deferred.promise;
	}

	public static function pipe5<T1, T2, TN1, TN2, TN3, TN4, TN5>(promise : Promise<T1 -> T2 -> Void>, success : T1 -> T2 -> Promise<TN1 -> TN2 -> TN3 -> TN4 -> TN5 -> Void>) : Promise<TN1 -> TN2 -> TN3 -> TN4 -> TN5 -> Void>
	{
		var deferred = new Deferred5<TN1, TN2, TN3, TN4, TN5>();
		promise.then(
			function(v1 : T1, v2 : T2) success(v1, v2).then(deferred.resolve),
			deferred.reject
		);
		return deferred.promise;
	}
}

// TODO: add pipes for Promise2+

class Promises1
{
	public static function lose1<T1>(promise : Promise<T1 -> Void>) : Promise<Void -> Void>
	{
		var deferred = new Deferred0();
		promise.then(function(_) deferred.resolve(), deferred.reject);
		return deferred.promise;
	}

	public static function with<T1, T2>(promise : Promise<T1 -> Void>, value : T2) : Promise<T1 -> T2 -> Void>
		return await(promise, Promise.value(value));

	public static function await0<T1>(promise : Promise<T1 -> Void>, other : Promise<Void -> Void>) : Promise<T1 -> Void>
	{
		var deferred = new Deferred<T1>();
		promise.then(function(v1 : T1) {
			other.then(function() {
				deferred.resolve(v1);
			});
		});
		return deferred.promise;
	}

	public static function await<T1, T2>(promise : Promise<T1 -> Void>, other : Promise<T2 -> Void>) : Promise<T1 -> T2 -> Void>
	{
		var deferred = new Deferred2<T1, T2>();
		promise.then(function(v1 : T1) {
			other.then(function(v2 : T2) {
				deferred.resolve(v1, v2);
			});
		});
		return deferred.promise;
	}

	public static function await2<T1, T2, T3>(promise : Promise<T1 -> Void>, other : Promise<T2 -> T3 -> Void>) : Promise<T1 -> T2 -> T3 -> Void>
	{
		var deferred = new Deferred3<T1, T2, T3>();
		promise.then(function(v1 : T1) {
			other.then(function(v2 : T2, v3 : T3) {
				deferred.resolve(v1, v2, v3);
			});
		});
		return deferred.promise;
	}

	public static function await3<T1, T2, T3, T4>(promise : Promise<T1 -> Void>, other : Promise<T2 -> T3 -> T4 -> Void>) : Promise<T1 -> T2 -> T3 -> T4 -> Void>
	{
		var deferred = new Deferred4<T1, T2, T3, T4>();
		promise.then(function(v1 : T1) {
			other.then(function(v2 : T2, v3 : T3, v4 : T4) {
				deferred.resolve(v1, v2, v3, v4);
			});
		});
		return deferred.promise;
	}

	public static function await4<T1, T2, T3, T4, T5>(promise : Promise<T1 -> Void>, other : Promise<T2 -> T3 -> T4 -> T5 -> Void>) : Promise<T1 -> T2 -> T3 -> T4 -> T5 -> Void>
	{
		var deferred = new Deferred5<T1, T2, T3, T4, T5>();
		promise.then(function(v1 : T1) {
			other.then(function(v2 : T2, v3 : T3, v4 : T4, v5 : T5) {
				deferred.resolve(v1, v2, v3, v4, v5);
			});
		});
		return deferred.promise;
	}

	public static function transform<T1, TNew>(promise : Promise<T1 -> Void>, success : T1 -> TNew) : Promise<TNew -> Void>
	{
		var deferred = new Deferred<TNew>();
		promise.then(
			function(v1 : T1) deferred.resolve(success(v1)),
			deferred.reject
		);
		return deferred.promise;
	}

	public static function pipe0<T1>(promise : Promise<T1 -> Void>, success : T1 -> Promise<Void -> Void>) : Promise<Void -> Void>
	{
		var deferred = new Deferred0();
		promise.then(
			function(v1 : T1) success(v1).then(deferred.resolve),
			deferred.reject
		);
		return deferred.promise;
	}

	public static function pipe<T1, TNew>(promise : Promise<T1 -> Void>, success : T1 -> Promise<TNew -> Void>) : Promise<TNew -> Void>
	{
		var deferred = new Deferred<TNew>();
		promise.then(
			function(v1 : T1) success(v1).then(deferred.resolve),
			deferred.reject
		);
		return deferred.promise;
	}

	public static function pipe2<T1, TN1, TN2>(promise : Promise<T1 -> Void>, success : T1 -> Promise<TN1 -> TN2 -> Void>) : Promise<TN1 -> TN2 -> Void>
	{
		var deferred = new Deferred2<TN1, TN2>();
		promise.then(
			function(v1 : T1) success(v1).then(deferred.resolve),
			deferred.reject
		);
		return deferred.promise;
	}

	public static function pipe3<T1, TN1, TN2, TN3>(promise : Promise<T1 -> Void>, success : T1 -> Promise<TN1 -> TN2 -> TN3 -> Void>) : Promise<TN1 -> TN2 -> TN3 -> Void>
	{
		var deferred = new Deferred3<TN1, TN2, TN3>();
		promise.then(
			function(v1 : T1) success(v1).then(deferred.resolve),
			deferred.reject
		);
		return deferred.promise;
	}

	public static function pipe4<T1, TN1, TN2, TN3, TN4>(promise : Promise<T1 -> Void>, success : T1 -> Promise<TN1 -> TN2 -> TN3 -> TN4 -> Void>) : Promise<TN1 -> TN2 -> TN3 -> TN4 -> Void>
	{
		var deferred = new Deferred4<TN1, TN2, TN3, TN4>();
		promise.then(
			function(v1 : T1) success(v1).then(deferred.resolve),
			deferred.reject
		);
		return deferred.promise;
	}

	public static function pipe5<T1, TN1, TN2, TN3, TN4, TN5>(promise : Promise<T1 -> Void>, success : T1 -> Promise<TN1 -> TN2 -> TN3 -> TN4 -> TN5 -> Void>) : Promise<TN1 -> TN2 -> TN3 -> TN4 -> TN5 -> Void>
	{
		var deferred = new Deferred5<TN1, TN2, TN3, TN4, TN5>();
		promise.then(
			function(v1 : T1) success(v1).then(deferred.resolve),
			deferred.reject
		);
		return deferred.promise;
	}
}

class Promises0
{
	public static function await0(promise : Promise<Void -> Void>, other : Promise<Void -> Void>) : Promise<Void -> Void>
	{
		var deferred = new Deferred0();
		promise.then(function() {
			other.then(function() {
				deferred.resolve();
			});
		});
		return deferred.promise;
	}

	public static function with<T>(promise : Promise<Void -> Void>, value : T) : Promise<T -> Void>
		return await(promise, Promise.value(value));

	public static function await<T1>(promise : Promise<Void -> Void>, other : Promise<T1 -> Void>) : Promise<T1 -> Void>
	{
		var deferred = new Deferred<T1>();
		promise.then(function() {
			other.then(function(v1 : T1) {
				deferred.resolve(v1);
			});
		});
		return deferred.promise;
	}

	public static function await2<T1, T2>(promise : Promise<Void -> Void>, other : Promise<T1 -> T2 -> Void>) : Promise<T1 -> T2 -> Void>
	{
		var deferred = new Deferred2<T1, T2>();
		promise.then(function() {
			other.then(function(v1 : T1, v2 : T2) {
				deferred.resolve(v1, v2);
			});
		});
		return deferred.promise;
	}

	public static function await3<T1, T2, T3>(promise : Promise<Void -> Void>, other : Promise<T1 -> T2 -> T3 -> Void>) : Promise<T1 -> T2 -> T3 -> Void>
	{
		var deferred = new Deferred3<T1, T2, T3>();
		promise.then(function() {
			other.then(function(v1 : T1, v2 : T2, v3 : T3) {
				deferred.resolve(v1, v2, v3);
			});
		});
		return deferred.promise;
	}

	public static function await4<T1, T2, T3, T4>(promise : Promise<Void -> Void>, other : Promise<T1 -> T2 -> T3 -> T4 -> Void>) : Promise<T1 -> T2 -> T3 -> T4 -> Void>
	{
		var deferred = new Deferred4<T1, T2, T3, T4>();
		promise.then(function() {
			other.then(function(v1 : T1, v2 : T2, v3 : T3, v4 : T4) {
				deferred.resolve(v1, v2, v3, v4);
			});
		});
		return deferred.promise;
	}

	public static function await5<T1, T2, T3, T4, T5>(promise : Promise<Void -> Void>, other : Promise<T1 -> T2 -> T3 -> T4 -> T5 -> Void>) : Promise<T1 -> T2 -> T3 -> T4 -> T5 -> Void>
	{
		var deferred = new Deferred5<T1, T2, T3, T4, T5>();
		promise.then(function() {
			other.then(function(v1 : T1, v2 : T2, v3 : T3, v4 : T4, v5 : T5) {
				deferred.resolve(v1, v2, v3, v4, v5);
			});
		});
		return deferred.promise;
	}

	public static function transform<TNew>(promise : Promise<Void -> Void>, success : Void -> TNew) : Promise<TNew -> Void>
	{
		var deferred = new Deferred<TNew>();
		promise.then(
			function() deferred.resolve(success()),
			deferred.reject
		);
		return deferred.promise;
	}

	public static function pipe0(promise : Promise<Void -> Void>, success : Void -> Promise<Void -> Void>) : Promise<Void -> Void>
	{
		var deferred = new Deferred0();
		promise.then(
			function() success().then(deferred.resolve),
			deferred.reject
		);
		return deferred.promise;
	}

	public static function pipe<TNew>(promise : Promise<Void -> Void>, success : Void -> Promise<TNew -> Void>) : Promise<TNew -> Void>
	{
		var deferred = new Deferred<TNew>();
		promise.then(
			function() success().then(deferred.resolve),
			deferred.reject
		);
		return deferred.promise;
	}

	public static function pipe2<TN1, TN2>(promise : Promise<Void -> Void>, success : Void -> Promise<TN1 -> TN2 -> Void>) : Promise<TN1 -> TN2 -> Void>
	{
		var deferred = new Deferred2<TN1, TN2>();
		promise.then(
			function() success().then(deferred.resolve),
			deferred.reject
		);
		return deferred.promise;
	}

	public static function pipe3<TN1, TN2, TN3>(promise : Promise<Void -> Void>, success : Void -> Promise<TN1 -> TN2 -> TN3 -> Void>) : Promise<TN1 -> TN2 -> TN3 -> Void>
	{
		var deferred = new Deferred3<TN1, TN2, TN3>();
		promise.then(
			function() success().then(deferred.resolve),
			deferred.reject
		);
		return deferred.promise;
	}

	public static function pipe4<TN1, TN2, TN3, TN4>(promise : Promise<Void -> Void>, success : Void -> Promise<TN1 -> TN2 -> TN3 -> TN4 -> Void>) : Promise<TN1 -> TN2 -> TN3 -> TN4 -> Void>
	{
		var deferred = new Deferred4<TN1, TN2, TN3, TN4>();
		promise.then(
			function() success().then(deferred.resolve),
			deferred.reject
		);
		return deferred.promise;
	}

	public static function pipe5<TN1, TN2, TN3, TN4, TN5>(promise : Promise<Void -> Void>, success : Void -> Promise<TN1 -> TN2 -> TN3 -> TN4 -> TN5 -> Void>) : Promise<TN1 -> TN2 -> TN3 -> TN4 -> TN5 -> Void>
	{
		var deferred = new Deferred5<TN1, TN2, TN3, TN4, TN5>();
		promise.then(
			function() success().then(deferred.resolve),
			deferred.reject
		);
		return deferred.promise;
	}
}