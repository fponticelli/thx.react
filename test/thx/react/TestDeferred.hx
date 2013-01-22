package thx.react;

/**
 * ...
 * @author Franco Ponticelli
 */

import utest.Assert;

class TestDeferred
{
	public function new() { }

	public function testResolve()
	{
		var deferred = new Deferred();
		var counter = 0;
		deferred.then(function(v) counter += v);
		Assert.equals(0, counter);
		deferred.resolve(3);
		Assert.equals(3, counter);
		deferred.then(function(v) counter *= v);
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
		new Deferred()
			.then(function(_) Assert.fail("success should never occur"))
			.fail(function(e : Int) Assert.fail("this Int error should never occur"))
			.fail(function(e : String) Assert.equals("error", e))
			.reject("error");
	}

	public function testResolveFirstFailure()
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
		new Deferred()
			.then(function(_) Assert.fail("success should never occur"))
			.progress(function(e : Int) counter += e)
			.progress(function(e : String) Assert.fail("this Int error should never occur"))
			.notify(2)
			.notify(3);
		Assert.equals(5, counter);
	}

	public function testPipe()
	{
		var test = null;
		Deferred.value(1).pipe(function(i : Int) return Deferred.value("#" + i)).then(function(s : String) test = s);
		Assert.equals("#1", test);
	}
}