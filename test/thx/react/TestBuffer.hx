/**
 * ...
 * @author Franco Ponticelli
 */

package thx.react;

import utest.Assert;

class TestBuffer
{
	public function new() {}

	public function setup()
	{
	}

	public function testBasics()
	{
		var buffer = new Buffer();
		buffer.queue(new Message(0));
		buffer.queueMany([new Message(1), new Message(2)]);

		var invoke = 0;
		buffer.consume(function(arr : Array<Message>) {
			if(invoke == 0)
			{
				Assert.equals(0, arr[0].counter);
				Assert.equals(1, arr[1].counter);
				Assert.equals(2, arr[2].counter);
			} else if(invoke == 1) {
				Assert.equals(3, arr[0].counter);
			} else {
				Assert.fail("consume should be invoked only twice");
			}
			invoke++;
		});
		buffer.queue(new Message(3));
		if(invoke == 0)
			Assert.fail("consume never triggered");
	}
}

class Message
{
	public var counter : Int;
	public function new(counter : Int)
	{
		this.counter = counter;
	}
}