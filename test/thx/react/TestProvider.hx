/**
 * ...
 * @author Franco Ponticelli
 */

package thx.react;

import utest.Assert;

class TestProvider
{
	public function new() { }
	
	public function testDemandProvide()
	{
		var provider = new Provider();
		provider.demand(String).then(function(response : String) Assert.equals("Haxe", response));
		provider.provide("Haxe");
	}
	
	public function testProvideDemand()
	{
		var provider = new Provider();
		provider.provide("Haxe");
		provider.demand(String).then(function(response : String) Assert.equals("Haxe", response));
	}
}