package thx.react.signal;

import thx.core.Procedure;
import thx.react.Signal;

class Timer extends Signal0
{
	public var delay : Int;
	public var autostart : Bool;
	var timer : haxe.Timer;
	public function new(delay : Int, autostart : Bool = false)
	{
		this.delay = delay;
		this.autostart = autostart;
		super();
	}

	override function on(h : Procedure<Void -> Void>) : Procedure<Void -> Void>
	{
		var p = super.on(h);
		if(autostart && handlers.length == 1)
			start();
		return p;
	}

	override function off(h : Procedure<Void -> Void>) : Bool
	{
		var r = super.off(h);
		if(autostart && r && handlers.length == 0)
			stop();
		return r;
	}

	public function start()
	{
		if(null != timer)
			return;
		timer = new haxe.Timer(delay);
		trigger();
		timer.run = trigger;
	}

	public function stop()
	{
		if(null == timer)
			return;
		timer.stop();
		timer = null;
	}
}