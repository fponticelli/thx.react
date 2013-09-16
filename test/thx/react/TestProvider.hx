/**
 * ...
 * @author Franco Ponticelli
 */

package thx.react;

import utest.Assert;
using thx.react.TestPromise;
using thx.react.Promise;

class TestProvider
{
	public function new() { }

	public function testDemandProvide()
	{
		var provider = new Provider();
		provider.demand(String).then(function(response : String) Assert.equals("Haxe", response)).lose1().completeTest();
		provider.provide("Haxe");
	}

	public function testProvideDemand()
	{
		var provider = new Provider();
		provider.provide("Haxe");
		provider.demand(String).then(function(response : String) Assert.equals("Haxe", response)).lose1().completeTest();
	}

	public function testProvideMultipleInstances()
	{
		var provider = new Provider(),
				counter  = 0;
		provider.provideInstance(String, function() return Promise.value("x" + (++counter)));
		provider.demand(String).then(function(response : String) Assert.equals("x1", response));
		provider.demand(String).then(function(response : String) Assert.equals("x2", response)).lose1().completeTest();
	}
}