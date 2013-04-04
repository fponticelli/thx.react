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
		provideImpl(Type.typeof(data).toString(), function(d) d.resolve(data));
		return this;
	}

	public function provideLazy<T>(type : Class<T>, handler : Deferred<T> -> Void)
	{
		provideImpl(type.toString(), cast handler);
		return this;
	}

	function provideImpl(type : String, handler : Deferred<Dynamic> -> Void)
	{
		var name = type.toString(),
			provider = getProvider(name);
		handler(provider);
	}
	
	function getProvider(type : String)
	{
		var provider = providers.get(type);
		if (null == provider)
			providers.set(type, provider = new Deferred<Dynamic>());
		return provider;
	}
}