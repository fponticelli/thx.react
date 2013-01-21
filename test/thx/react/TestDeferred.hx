package thx.react;

/**
 * ...
 * @author Franco Ponticelli
 */

import utest.Assert;

class TestDeferred
{
	public function new() { }
	
	public function testBasics()
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
}