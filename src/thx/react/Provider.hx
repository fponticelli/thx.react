/**
 * ...
 * @author Franco Ponticelli
 */

package thx.react;

using thx.core.Types;
import thx.react.Promise;

class Provider
{
	var providers : Map<String, { deferred : Deferred<Dynamic>, fullfiller : Void -> Void, demanded : Bool }>;
	public function new()
	{
		providers = new Map();
	}

	public function demand<T>(type : Class<T>) : Promise<T -> Void>
	{
		var provider = getProvider(type.toString());
		if(!provider.demanded && null != provider.fullfiller)
			provider.fullfiller();

		provider.demanded = true;
		return cast provider.deferred.promise;
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
		if(null != provider.fullfiller)
			throw "provider implementation already provided";
		provider.fullfiller = function() handler(provider.deferred);
		if(provider.demanded)
			provider.fullfiller();
	}

	function getProvider(type : String)
	{
		var provider = providers.get(type);
		if (null == provider)
			providers.set(type, provider = { deferred : new Deferred<Dynamic>(), fullfiller : null, demanded : false });
		return provider;
	}
}