package thx.react;

/**
 * ...
 * @author Franco Ponticelli
 */

import utest.Assert;
 import thx.react.Deferred;
 
class TestDeferred2
{
	public function new() { }
	
	public function testDeferred()
	{
		new Deferred2()
			.then(function(s : String, i : Int) Assert.equals("Haxe3", s + i))
			.resolve("Haxe", 3);
	}
}