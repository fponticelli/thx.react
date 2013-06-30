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
}