/**
 * ...
 * @author Franco Ponticelli
 */

package thx.react;

import thx.core.Procedure;
import thx.react.Deferred;

class BasePromise
{
	var queue : Array<Dynamic>;
	var state : PromiseState2;
	var errorDispatcher : Dispatcher;
	var progressDispatcher : Dispatcher;
	public function new()
	{
		queue = [];
		state = Idle;
	}

	macro public function fail<TError>(ethis : haxe.macro.Expr.ExprOf<BasePromise>, handler : haxe.macro.Expr.ExprOf<TError -> Void>)
	{
		var type = Dispatcher.nonOptionalArgumentTypeAsString(handler, 0);
		return macro $ethis.failByName($v{type}, $handler);
	}

	macro public function progress<TProgress>(ethis : haxe.macro.Expr.ExprOf<BasePromise>, handler : haxe.macro.Expr.ExprOf<TProgress -> Void>)
	{
		var type = Dispatcher.nonOptionalArgumentTypeAsString(handler, 0);
		return macro $ethis.progressByName($v{type}, $handler);
	}
	
	function poll()
	{
		switch(state)
		{
			case Success(args):
				var handler;
				try
				{
					while (null != (handler = queue.shift()))
						Reflect.callMethod(null, handler, args);
				} catch (e : Dynamic) {
					changeState(ProgressException([e]));
					poll();
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
			case Idle:
			case ProgressException(_):
				throw "ProgressException state should never be in the poll";
		}
	}

	function changeState(newstate : PromiseState2)
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

	public function failByName<T>(name : String, failure : Procedure<T>)
	{
		getErrorDispatcher().binder.bind(name, failure);
		poll();
		return this;
	}

	public function progressByName<T>(name : String, progress : Procedure<T>)
	{
		getProgressDispatcher().binder.bind(name, progress);
		poll();
		return this;
	}
	
	function thenImpl(success : Dynamic, ?failure : Dynamic -> Void)
	{
		queue.push(success);
		if (null != failure)
			failByName("Dynamic", failure);
		else
			poll();
	}
}

class Promise<T1> extends BasePromise
{
	public inline static function value<T>(v : T)
	{
		return new Deferred<T>().resolve(v);
	}
	
	public function then(success : T1 -> Void, ?failure : Dynamic -> Void)
	{
		thenImpl(success, failure);
		return this;
	}
	
	override function failByName<T>(name : String, failure : Procedure<T>) : Promise<T1>
	{
		super.failByName(name, failure);
		return this;
	}

	override function progressByName<T>(name : String, progress : Procedure<T>) : Promise<T1>
	{
		super.progressByName(name, progress);
		return this;
	}

	public function pipe<TNew>(success : T1 -> Promise<TNew>) : Promise<TNew>
	{
		var deferred = new Deferred<TNew>();
		this.then(function(data : T1) {
				success(data)
					.then(deferred.resolve);
			})
			.failByName("Dynamic", deferred.reject)
			.progressByName("Dynamic", deferred.notify);
		return deferred.promise();
	}
}

class Promise2<T1, T2> extends BasePromise
{
	public function then(success : T1 -> T2 -> Void, ?failure : Dynamic -> Void)
	{
		thenImpl(success, failure);
		return this;
	}
	
	override function failByName<T>(name : String, failure : Procedure<T>) : Promise2<T1, T2>
	{
		super.failByName(name, failure);
		return this;
	}

	override function progressByName<T>(name : String, progress : Procedure<T>) : Promise2<T1, T2>
	{
		super.progressByName(name, progress);
		return this;
	}
/*
	public function pipe<TNew>(success : T1 -> T2 -> Promise<TNew>) : Promise<TNew>
	{
		var deferred = new Deferred<TData>();
		this.then(function(data : TData) {
				success(data)
					.then(deferred.resolve);
			})
			.failByName("Dynamic", 1, deferred.reject)
			.progressByName("Dynamic", 1, deferred.notify);
		return deferred.promise();
	}
*/
}

enum PromiseState2 {
	Idle;
	Failure (args : Array<Dynamic>);
	Progress(args : Array<Dynamic>);
	Success (args : Array<Dynamic>);
	ProgressException(error : Dynamic);
}

enum PromiseState<T> {
	Idle;
	Failure(args : Array<Dynamic>);
	Progress(args : Array<Dynamic>);
	Success(data : T);
	ProgressException(error : Dynamic);
}