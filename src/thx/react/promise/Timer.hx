package thx.react.promise;

import thx.react.Promise;

class Timer 
{
	public static function delay(millis : Int) : Promise<Void -> Void>
	{
		var deferred = new Deferred0();
		haxe.Timer.delay(deferred.resolve, millis);
		return deferred.promise;
	}
}