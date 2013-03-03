/**
 * ...
 * @author Franco Ponticelli
 */

package thx.react;

using thx.core.Types;
import thx.react.Promise;

class Provider
{
	var providers : Map<String, Deferred<Dynamic>>;
	public function new() 
	{
		providers = new Map();
	}

	public function demand<T>(type : Class<T>) : Promise<T -> Void>
	{
		return cast getProvider(type.toString()).promise;
	}
	
	public function provide<T>(data : T)
	{
		var type = Type.typeof(data).toString(),
			provider = getProvider(type);
		if (provider.promise.isComplete())
			providers.set(type, provider = new Deferred<Dynamic>());
		provider.resolve(data);
		return this;
	}
	
	function getProvider(type : String)
	{
		var provider = providers.get(type);
		if (null == provider)
			providers.set(type, provider = new Deferred<Dynamic>());
		return provider;
	}
}