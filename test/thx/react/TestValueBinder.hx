/**
 * ...
 * @author Franco Ponticelli
 */

package thx.react;

import utest.Assert;
import haxe.ds.Option;

class TestValueBinder
{
	public function new() {}

	public function testBindFirst()
	{
		var async   = Assert.createAsync(),
			binder  = new ValueBinder(),
			counter = 0;
		binder.bind("A", function(v : Option<String>) {
			switch([counter, v]) {
				case [0, None]:
					Assert.isTrue(true);
				case [1, Some(v)] if(v == "a"):
					Assert.isTrue(true);
					async();
				case [i, c]:
					Assert.fail('invalid $i, $c');
			}
			counter++;
		});
		binder.dispatchSome("A", "a");
	}

	public function testBindAfter()
	{
		var async   = Assert.createAsync(),
			binder  = new ValueBinder(),
			counter = 0;
		binder.dispatchSome("A", "a");
		binder.bind("A", function(v : Option<String>) {
			switch([counter, v]) {
				case [0, Some(v)] if(v == "a"):
					Assert.isTrue(true);
					async();
				case [i, c]:
					Assert.fail('invalid $i, $c');
			}
			counter++;
		});
	}
}