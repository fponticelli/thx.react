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
	
	public var counter1 : Int = 0;
	public var counter2 : Int = 0;
	
	public function setup()
	{
		counter1 = 0;
		counter2 = 0;
	}
	
	public function increment1(i : Int)
	{
		counter1 += i;
	}
	
	public function increment2(i : Int)
	{
		counter2 += i;
	}

	public function testBasics()
	{
		var dispatcher = new Dispatcher();
		dispatcher.bindByName("inc1", increment1);
		dispatcher.bindByName("inc2", increment2);
		dispatcher.bindByName("inc2", increment2);
		dispatcher.triggerByName("inc1", 1);
		Assert.equals(1, counter1);
		Assert.equals(0, counter2);
		dispatcher.triggerByName("inc2", 2);
		Assert.equals(1, counter1);
		Assert.equals(4, counter2);
		dispatcher.unbindByName("inc2", increment2);
		dispatcher.triggerByName("inc2", 2);
		Assert.equals(1, counter1);
		Assert.equals(6, counter2);
		dispatcher.unbindByName("inc1");
		dispatcher.triggerByName("inc1", 1);
		Assert.equals(1, counter1);
	}
	
	public function testBindOnce()
	{
		var dispatcher = new Dispatcher();
		dispatcher.bindOnceByName("inc1", increment1);
		dispatcher.triggerByName("inc1", 1);
		dispatcher.triggerByName("inc1", 1);
		Assert.equals(1, counter1);
	}
	
	public function testDynamic()
	{
		var dispatcher = new Dispatcher();
		var tdynamic = 0,
			ttyped   = 0;
		dispatcher.bindByName("Dynamic", function(_) tdynamic++);
		dispatcher.bindByName("Int", function(_) ttyped++);
		dispatcher.triggerByName("Int", 0);
		Assert.equals(1, tdynamic);
		Assert.equals(1, ttyped);
		dispatcher.triggerByName("Dynamic", 0);
		Assert.equals(2, tdynamic);
		Assert.equals(1, ttyped);
	}
	
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
	
	public function testTriggerByValue()
	{
		var dispatcher = new Dispatcher();
		dispatcher.on(function(test : MyEnum) Assert.same(MyValue, test));
		dispatcher.triggerByValue(MyValue);
	}
}

private enum MyEnum
{
	MyValue;
}