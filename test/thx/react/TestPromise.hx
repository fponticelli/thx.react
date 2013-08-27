package thx.react;

/**
 * ...
 * @author Franco Ponticelli
 */

import thx.core.Floats;
import utest.Assert;
using thx.react.Promise;
using thx.react.TestPromise;

class TestPromise
{
	public function new() { }
	public static function completeTest(promise : Promise<Void -> Void>)
		promise.always(Assert.createAsync());
/*
	static function createAsync()
	{
		var deferred = new Deferred0(),
			async = Assert.createAsync();
		deferred.promise.always(async);
		return deferred;
	}
*/
	public function testResolve()
	{
		var deferred = new Deferred();
		var counter = 0;
		Assert.equals(0, counter);
		deferred.promise.then(function(v) {
			counter += v;
			Assert.equals(3, counter);
		});
		deferred.resolve(3);
		deferred.promise.then(function(v) {
			counter *= v;
			Assert.equals(9, counter);	
		});

		deferred.promise.lose1().completeTest();
	}

	public function testValue()
	{
		Promise.value(7).then(function(v) {
			Assert.equals(7, v);
		}).lose1().completeTest();
	}

	public function testFailure()
	{
		var d = new Deferred();
		d.promise
			.then(function(_) Assert.fail("success should never occur"))
			.fail(function(e : Int) Assert.fail("this Int error should never occur"))
			.fail(function(e : String) Assert.equals("error", e));
		d.reject("error");
		d.promise.lose1().completeTest();
	}

	public function testPipeFailure()
	{
		var complete = Assert.createAsync(),
			deferred = new Deferred(),
			p1 = deferred.promise,
			p2 = p1.pipe0(function(_) {
				return Promise.value0();
			});
		p1.fail(function(_ : Int) {
trace("!!!! FAIL 2");
			Assert.isTrue(true);
			complete();
		});
		p2.fail(function(_ : Dynamic) {
trace("!!!! FAIL");
			Assert.isTrue(true);
			complete();
		});
#if (js || flash)
		haxe.Timer.delay(deferred.reject.bind("error"), 100);
#else
		deferred.reject("error");
#end
	}

	public function testResolveRejectFirst()
	{
		new Deferred()
			.reject("error")
			.then(function(_) Assert.fail("success should never occur"))
			.fail(function(e : Int) Assert.fail("this Int error should never occur"))
			.fail(function(e : String) Assert.equals("error", e))
			.lose1().completeTest();
	}

	public function testProgress()
	{
		var counter = 0;
		var d = new Deferred();
		d.promise
			.then(function(v) Assert.equals("A", v))
			.progress(function(e : Int) {
				if(counter == 0)
				{
					Assert.equals(2, e);
				} else if(counter == 1) {
					Assert.equals(3, e);
				} else {
					Assert.fail("should only be invoked twice but is " + (1+counter) + " time");
				}
				counter++;
			})
			.progress(function(e : String) Assert.fail("this Int error should never occur"));
		d.notify(2).notify(3);
		d.resolve("A");
		d.promise.lose1().completeTest();
	}

	public function testPipe()
	{
		Promise.value(1).pipe(function(i : Int) return Promise.value("#" + i))
			.then(function(s : String) Assert.equals("#1", s))
			.lose1().completeTest();
	}

	public function testException()
	{
		Promise.value(1)
			.then(function(i : Int) throw "argh!")
			.fail(function(e : Dynamic) Assert.equals("argh!", e))
			.lose1().completeTest();
	}
	
	public function testThenFailure()
	{
		var d = new Deferred();
		d.promise.then(
			function(i : Int) Assert.fail(),
			function(e : Dynamic) Assert.isTrue(true)
		);
		d.reject(1);
		d.promise.lose1().completeTest();
	}
	
	public function testDeferred2()
	{
		var d = new Deferred2();
		d.promise.then(function(s : String, i : Int) Assert.equals("Haxe3", s + i));
		d.resolve("Haxe", 3);
		d.promise.lose2().completeTest();
	}
	
	public function testAwait()
	{
		Promise.value(1)
			.await(Promise.value("x"))
			.then(function(v1 : Int, v2 : String) {
				Assert.equals(1, v1);
				Assert.equals("x", v2);
			})
			.lose2().completeTest();
	}
	
	public function testAwaitMany()
	{
		Promise.value2("a", 1)
			.await0(Promise.value0())
			.await3(Promise.value3(0.1, true, null))
			.then(function(s : String, i : Int, f : Float, b : Bool, d : Dynamic) {
				Assert.equals("a", s);
				Assert.equals(1, i);
				Assert.equals(0.1, f);
				Assert.isTrue(b);
				Assert.isNull(d);
			})
			.lose5().completeTest();
	}
	
	public function testAlwaysSuccess()
	{
		Promise.value(1).always(function() Assert.isTrue(true)).lose1().completeTest();
	}
	
	public function testAlwaysError()
	{
		new Deferred().reject(1).always(function() Assert.isTrue(true)).lose1().completeTest();
	}
}