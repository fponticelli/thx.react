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
		buffer.enqueue(new Message(0));
		buffer.enqueueMany([new Message(1), new Message(2)]);

		var invoke = 0;
		var stop = Assert.createAsync();
		buffer.process(function(msg : Message) {
			if(invoke == 1)
			{
				Assert.equals(3, msg.counter);
			}
		});
		buffer.processMany(function(arr : Array<Message>) {
			if(invoke == 0)
			{
				Assert.equals(0, arr[0].counter);
				Assert.equals(1, arr[1].counter);
				Assert.equals(2, arr[2].counter);
			} else if(invoke == 1) {
				Assert.equals(3, arr[0].counter);
				stop();
			} else {
				Assert.fail("process should be invoked only twice");
			}
			invoke++;
		});
		buffer.enqueue(new Message(3));
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