package thx.react;

interface ISuspendable 
{
	public var dirty(default, null) : Bool;
	public function suspend() : Void;
	public function resume() : Void;
}