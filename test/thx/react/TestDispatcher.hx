/**
 * ...
 * @author Franco Ponticelli
 */

package thx.react;

import utest.Assert;

@:access(thx.react.Dispatcher)
class TestDispatcher
{
	public function new() {}

	public function testOn()
	{
		var dispatcher = new Dispatcher();
		var test_s = null;
		var test_i = 0;
		dispatcher.on(function(name : String) { test_s = name; } );
		dispatcher.on(function(i : Int) { test_i = i; } );
		dispatcher.trigger("Haxe");
		Assert.equals("Haxe", test_s);
		Assert.equals(0, test_i);
		dispatcher.trigger(1);
		Assert.equals("Haxe", test_s);
		Assert.equals(1, test_i);
	}

	public function testClear()
	{
		var dispatcher = new Dispatcher();
		var test_s = null;
		var test_i = 0;
		var test_b = false;
		dispatcher.on(function(name : String) { test_s = name; } );
		dispatcher.on(function(i : Int) { test_i = i; } );
		dispatcher.on(function(b : Bool) { test_b = b; } );

		dispatcher.clear(String);
		dispatcher.trigger("Haxe");
		dispatcher.trigger(1);
		dispatcher.trigger(true);
		Assert.isNull(test_s);
		Assert.equals(1, test_i);
		Assert.isTrue(test_b);

		dispatcher.clear("Int");
		dispatcher.trigger(2);
		Assert.equals(1, test_i);
		Assert.isTrue(test_b);

		dispatcher.clear();
		dispatcher.trigger(false);
		Assert.isTrue(test_b);
	}

	public function testOn2()
	{
		var dispatcher = new Dispatcher();
		var test_s = null;
		var test_i = 0;
		dispatcher.on(function(name : String, i : Int) { test_s = name + i; } );
		dispatcher.on(function(i1 : Int, i2 : Int) { test_i = i1 + i2; } );
		dispatcher.trigger("Haxe", 2);
		Assert.equals("Haxe2", test_s);
		Assert.equals(0, test_i);
		dispatcher.trigger(3, 6);
		Assert.equals("Haxe2", test_s);
		Assert.equals(9, test_i);
	}

	public function testTriggerByValue()
	{
		var dispatcher = new Dispatcher();
		dispatcher.on(function(test : MyEnum) Assert.same(MyEnum.MyValue, test));
		dispatcher.triggerDynamic([MyEnum.MyValue]);
	}

	public function testHierarchy()
	{
		var dispatcher = new Dispatcher(),
			counter = 0;
		dispatcher.on(function(v : Dynamic) {
			counter += 100;
		});
		dispatcher.on(function(v : A) {
			counter += 10;
		});
		dispatcher.on(function(v : B) {
			counter += 1;
		});
		dispatcher.trigger(new B());
		Assert.equals(111, counter);
		dispatcher.trigger(new A());
		Assert.equals(221, counter);
		dispatcher.trigger(1);
		Assert.equals(321, counter);
	}
	
	public function testRemoveHandlerFromHandler()
	{
		var counter = 0,
			dispatcher = new Dispatcher(),
			f4 = function(i : Int)
			{
				counter += i * 4;
			},
			f3 = function(i : Int)
			{
				Assert.fail("should never get here");
				counter += i * 3;
			},
			f1 = function(i : Int)
			{
				counter += i;
				Assert.equals(1, counter);
			},
			f2 = function(i : Int)
			{
				counter += i * 2;
				dispatcher.off(f3);
				dispatcher.off(f1);
			};
		dispatcher.on(f1);
		dispatcher.on(f2);
		dispatcher.on(f3);
		dispatcher.on(f4);
		
		dispatcher.trigger(1);
		Assert.equals(7, counter);
	}
	
	public function testDoubleTrigger()
	{
		var counter = 0,
			dispatcher = new Dispatcher(),
			f2 : Int -> Void = null,
			f4 = function(i : Int)
			{
				counter += i * 4;
			},
			f3 = function(i : Int)
			{
				counter += i * 3;
			},
			f1 = function(i : Int)
			{
				counter += i;
			};
		f2 = function(i : Int)
		{
			counter += i * 2;
			dispatcher.off(f2);
			dispatcher.trigger(10);
			dispatcher.off(f1);
		};
		dispatcher.on(f1);
		dispatcher.on(f2);
		dispatcher.on(f3);
		dispatcher.on(f4);
		
		dispatcher.trigger(1);
		Assert.equals(90, counter);
	}
}