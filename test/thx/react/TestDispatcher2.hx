/**
 * ...
 * @author Franco Ponticelli
 */

package thx.react;

import utest.Assert;
import thx.react.Dispatcher;
import thx.react.TestDispatcher;

@:access(Dispatcher2)
class TestDispatcher2
{
	/*
	public function new() {}

	public var counter1 : Int = 0;
	public var counter2 : Int = 0;

	public function setup()
	{
		counter1 = 0;
		counter2 = 0;
	}

	public function increment1(i1 : Int, i2 : Int)
	{
		counter1 += i1 + i2;
	}

	public function increment2(i1 : Int, i2 : Int)
	{
		counter2 += i1 + i2;
	}

	public function testBasics()
	{
		var dispatcher = new Dispatcher2();
		dispatcher.bind("inc1", increment1);
		dispatcher.bind("inc2", increment2);
		dispatcher.bind("inc2", increment2);
		dispatcher.dispatch(["inc1"], 1, 2);
		Assert.equals(3, counter1);
		Assert.equals(0, counter2);
		dispatcher.dispatch(["inc2"], 3, 6);
		Assert.equals(3, counter1);
		Assert.equals(18, counter2);
		dispatcher.unbind("inc2", increment2);
		dispatcher.dispatch(["inc2"], 3, 6);
		Assert.equals(3, counter1);
		Assert.equals(27, counter2);
		dispatcher.unbind("inc1");
		dispatcher.dispatch(["inc1"], 1, 2);
		Assert.equals(3, counter1);
	}

	public function testBindOne()
	{
		var dispatcher = new Dispatcher2();
		dispatcher.bindOne("inc1", increment1);
		dispatcher.dispatch(["inc1"], 1, 2);
		dispatcher.dispatch(["inc1"], 1, 2);
		Assert.equals(3, counter1);
	}

	public function testDynamic()
	{
		var dispatcher = new Dispatcher2();
		var tdynamic = 0,
			ttyped   = 0;
		dispatcher.bind("Dynamic-Dynamic", function(_, _) tdynamic++);
		dispatcher.bind("Int-Int", function(_, _) ttyped++);
		dispatcher.dispatch(["Int-Int", "Dynamic-Dynamic"], 0, "a");
		Assert.equals(1, tdynamic);
		Assert.equals(1, ttyped);
		dispatcher.dispatch(["Dynamic-Dynamic"], 0, "a");
		Assert.equals(2, tdynamic);
		Assert.equals(1, ttyped);
	}

	public function testOn()
	{
		var dispatcher = new Dispatcher2();
		var test_s = null;
		var test_i = 0;
		dispatcher.on(function(name : String, value : Int) { test_s = name+value; } );
		dispatcher.on(function(i1 : Int, i2 : Int) { test_i = i1 + i2; } );
		dispatcher.trigger("Haxe", 1);
		Assert.equals("Haxe1", test_s);
		Assert.equals(0, test_i);
		dispatcher.trigger(1, 2);
		Assert.equals("Haxe1", test_s);
		Assert.equals(3, test_i);
	}

	public function testClear()
	{
		var dispatcher = new Dispatcher2();
		var test_s = null;
		var test_i = 0;
		var test_b = false;
		dispatcher.on(function(name : String, i : Int) { test_s = name; } );
		dispatcher.on(function(i1 : Int, i2 : Int) { test_i = i1; } );
		dispatcher.on(function(b : Bool, i : Int) { test_b = b; } );

		dispatcher.clearNames("String", "Int");
		dispatcher.trigger("Haxe", 1);
		dispatcher.trigger(1, 1);
		dispatcher.trigger(true, 1);
		Assert.isNull(test_s);
		Assert.equals(1, test_i);
		Assert.isTrue(test_b);

		dispatcher.clearNames("Int", "Int");
		dispatcher.trigger(2, 1);
		Assert.equals(1, test_i);
		Assert.isTrue(test_b);

		dispatcher.clear();
		dispatcher.trigger(false, 1);
		Assert.isTrue(test_b);
	}

	public function testTriggerByValue()
	{
		var dispatcher = new Dispatcher2();
		dispatcher.on(function(test : MyEnum, s_test : String) {
			Assert.same(MyEnum.MyValue, test);
			Assert.same("Haxe", s_test);
		});
		dispatcher.dispatchValue(MyEnum.MyValue, "Haxe");
	}

	public function testHierarchy()
	{
		var dispatcher = new Dispatcher2(),
			counter = 0;
		dispatcher.on(function(v1 : Dynamic, v2 : Dynamic)
			counter += 100
		);
		dispatcher.on(function(v1 : A, v2 : Dynamic)
			counter += 10
		);
		dispatcher.on(function(v1 : B, v2 : Dynamic)
			counter += 1
		);
		dispatcher.trigger(new B(), "Haxe");
		Assert.equals(111, counter);
		dispatcher.trigger(new A(), "Haxe");
		Assert.equals(221, counter);
		dispatcher.trigger(1, "Haxe");
		Assert.equals(321, counter);
	}
	*/
}