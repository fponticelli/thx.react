/**
 * ...
 * @author Franco Ponticelli
 */

package thx.react;

import utest.Assert;

class TestBinder
{
	public function new() {}

	public var counter1 : Int = 0;
	public var counter2 : Int = 0;

	public function setup()
	{
		counter1 = 0;
		counter2 = 0;
	}

	public function increment1(i : Int) counter1 += i;
	public function increment2(i : Int) counter2 += i;

	public function testBasics()
	{
		var binder = new Binder();
		binder.on("inc1", increment1);
		binder.on("inc2", increment2);
		binder.on("inc2", increment2);
		binder.trigger("inc1", 1);
		Assert.equals(1, counter1);
		Assert.equals(0, counter2);
		binder.trigger("inc2", 2);
		Assert.equals(1, counter1);
		Assert.equals(4, counter2);
		binder.off("inc2", increment2);
		binder.trigger("inc2", 2);
		Assert.equals(1, counter1);
		Assert.equals(6, counter2);
		binder.off("inc1");
		binder.trigger("inc1", 1);
		Assert.equals(1, counter1);
	}

	public function testOne()
	{
		var binder = new Binder();
		binder.one("inc1", increment1);
		binder.trigger("inc1", 1);
		binder.trigger("inc1", 1);
		Assert.equals(1, counter1);
	}

	public function testClear()
	{
		var binder = new Binder();
		var test_s = null;
		var test_i = 0;
		var test_b = false;
		binder.on("s", function(name : String) { test_s = name; } );
		binder.on("i", function(i : Int) { test_i = i; } );
		binder.on("b", function(b : Bool) { test_b = b; } );

		binder.clear("s");
		binder.trigger("s", "Haxe");
		binder.trigger("i", 1);
		binder.trigger("b", true);
		Assert.isNull(test_s);
		Assert.equals(1, test_i);
		Assert.isTrue(test_b);

		binder.clear("i");
		binder.trigger("i", 2);
		Assert.equals(1, test_i);
		Assert.isTrue(test_b);

		binder.clear();
		binder.trigger("b", false);
		Assert.isTrue(test_b);
	}

	public function testTrigger()
	{
		var binder = new Binder();
		binder.on("e", function(test : MyEnum) Assert.same(MyEnum.MyValue, test));
		binder.trigger("e", MyEnum.MyValue);
	}

	public function testMulti()
	{
		var binder = new Binder(),
			counter = 0;
		binder.on("i", function(v : Dynamic) {
			counter += 100;
		});
		binder.on("a", function(v : A) {
			counter += 10;
		});
		binder.on("x b", function(v : B) {
			counter += 1;
		});
		binder.trigger("b a i", new B());
		Assert.equals(111, counter);
		binder.trigger("a i", new A());
		Assert.equals(221, counter);
		binder.trigger("x i", 1);
		Assert.equals(322, counter);
	}
	
	public function testRemoveHandlerFromHandler()
	{
		var counter = 0,
			binder = new Binder(),
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
				binder.off("i", f3);
				binder.off("i", f1);
			};
		binder.on("i", f1);
		binder.on("i", f2);
		binder.on("i", f3);
		binder.on("i", f4);
		
		binder.trigger("i", 1);
		Assert.equals(7, counter);
	}
	
	public function testDoubleTrigger()
	{
		var counter = 0,
			binder = new Binder(),
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
			binder.off("i", f2);
			binder.trigger("i", 10);
			binder.off("i", f1);
		};
		binder.on("i", f1);
		binder.on("i", f2);
		binder.on("i", f3);
		binder.on("i", f4);
		
		binder.trigger("i", 1);
		Assert.equals(90, counter);
	}
}