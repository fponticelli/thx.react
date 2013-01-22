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
		var deferred = new Deferred();
		deferred
			.then(function(_) Assert.fail("success should never occur"))
			.fail(function(e : Int) Assert.fail("this Int error should never occur"))
			.fail(function(e : String) Assert.equals("error", e));
		deferred.reject("error");
	}
	
	public function testResolveFirstFailure()
	{
		var deferred = new Deferred();
		deferred
			.reject("error")
			.then(function(_) Assert.fail("success should never occur"))
			.fail(function(e : Int) Assert.fail("this Int error should never occur"))
			.fail(function(e : String) Assert.equals("error", e));
	}
	
	public function testProgress()
	{
		var deferred = new Deferred(),
			counter = 0;
		deferred
			.then(function(_) Assert.fail("success should never occur"))
			.progress(function(e : Int) counter += e)
			.progress(function(e : String) Assert.fail("this Int error should never occur"));
		deferred.notify(2);
		deferred.notify(3);
		Assert.equals(5, counter);
	}
}