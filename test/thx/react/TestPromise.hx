package thx.react;

/**
 * ...
 * @author Franco Ponticelli
 */

import utest.Assert;
using thx.react.Promise;

class TestPromise
{
	public function new() { }
	public function testResolve()
	{
		var deferred = new Deferred();
		var counter = 0;
		deferred.promise.then(function(v) counter += v);
		Assert.equals(0, counter);
		deferred.resolve(3);
		Assert.equals(3, counter);
		deferred.promise.then(function(v) counter *= v);
		Assert.equals(9, counter);
	}

	public function testValue()
	{
		var test = 0;
		Promise.value(7).then(function(v) test = v);
		Assert.equals(7, test);
	}

	public function testFailure()
	{
		var d = new Deferred();
		d.promise
			.then(function(_) Assert.fail("success should never occur"))
			.fail(function(e : Int) Assert.fail("this Int error should never occur"))
			.fail(function(e : String) Assert.equals("error", e));
		d.reject("error");
	}
	
	public function testResolveRejectFirst()
	{
		new Deferred()
			.reject("error")
			.then(function(_) Assert.fail("success should never occur"))
			.fail(function(e : Int) Assert.fail("this Int error should never occur"))
			.fail(function(e : String) Assert.equals("error", e));
	}

	public function testProgress()
	{
		var counter = 0;
		var d = new Deferred();
		d.promise
			.then(function(_) Assert.fail("success should never occur"))
			.progress(function(e : Int) counter += e)
			.progress(function(e : String) Assert.fail("this Int error should never occur"));
		d.notify(2).notify(3);
		Assert.equals(5, counter);
	}

	public function testPipe()
	{
		Promise.value(1).pipe(function(i : Int) return Promise.value("#" + i))
			.then(function(s : String) Assert.equals("#1", s));
	}

	public function testException()
	{
		Promise.value(1)
			.then(function(i : Int) throw "argh!")
			.fail(function(e : Dynamic) Assert.equals("argh!", e));
	}
	
	public function testThenFailure()
	{
		var d = new Deferred();
		d.promise.then(
			function(i : Int) Assert.fail(),
			function(e : Dynamic) Assert.isTrue(true)
		);
		d.reject(1);
	}
	
	public function testDeferred2()
	{
		var d = new Deferred2();
		d.promise.then(function(s : String, i : Int) Assert.equals("Haxe3", s + i));
		d.resolve("Haxe", 3);
	}
	
	public function testAwait()
	{
		Promise.value(1)
			.await(Promise.value("x"))
			.then(function(v1 : Int, v2 : String) {
				Assert.equals(1, v1);
				Assert.equals("x", v2);
			});
	}
}