package thx.react;

interface IObserver<T> 
{
	public function update(payload : T) : Void;
}

interface IObserver0
{
	public function update() : Void;
}