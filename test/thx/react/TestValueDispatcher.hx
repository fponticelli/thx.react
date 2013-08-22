/**
 * ...
 * @author Franco Ponticelli
 */

package thx.react;

import utest.Assert;
import haxe.ds.Option;

class TestValueDispatcher
{
	public function new() {}

	public function testOnBefore()
	{
		var dispatcher = new ValueDispatcher(),
			counter    = 0,
			async      = Assert.createAsync();
		dispatcher.on(function(msg : Option<String>) {
			switch([counter, msg]) {
				case [0, None]:
					Assert.isTrue(true);
				case [1, Some(v)] if(v == "b"):
					Assert.isTrue(true);
					async();
				case _:
					Assert.fail();
			}
			counter++;
		});
		dispatcher.triggerSome("b");
	}

	public function testOnAfter()
	{
		var dispatcher = new ValueDispatcher(),
			counter    = 0,
			async      = Assert.createAsync();
		dispatcher.triggerSome("b");
		dispatcher.on(function(msg : Option<String>) {
			switch([counter, msg]) {
				case [0, Some(v)] if(v == "b"):
					Assert.isTrue(true);
					async();
				case _:
					Assert.fail();
			}
			counter++;
		});
	}

	public function testTriggerNone()
	{
		var dispatcher = new ValueDispatcher(),
			counter    = 0,
			async      = Assert.createAsync();
		dispatcher.triggerSome("b");
		dispatcher.on(function(msg : Option<String>) {
			switch([counter, msg]) {
				case [0, Some(v)] if(v == "b"):
					Assert.isTrue(true);
				case [1, None]:
					Assert.isTrue(true);
					async();
				case _:
					Assert.fail();
			}
			counter++;
		});
		dispatcher.triggerNone(Int); // this should not trigger responses
		dispatcher.triggerNone(String);
	}
}