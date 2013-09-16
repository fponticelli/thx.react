/**
 * ...
 * @author Franco Ponticelli
 */

package thx.react;

using thx.core.Types;
import thx.react.Promise;

class Provider
{
	var providers : Map<String, { fullfiller : Void -> Promise<Dynamic->Void>, demands : Array<Deferred<Dynamic>> }>;
	public function new()
	{
		providers = new Map();
	}

	public function demand<T>(type : Class<T>) : Promise<T -> Void>
	{
		var provider = getProvider(type.toString());

		if(null == provider.fullfiller)
		{
			var deferred = new Deferred<T>();
			provider.demands.push(deferred);
			return deferred.promise;
		} else {
			return cast provider.fullfiller();
		}

	}

	public function provide<T>(data : T)
	{
		var promise = Promise.value(data);
		provideImpl(Type.typeof(data).toString(), function() return promise);
		return this;
	}

	public function provideInstance<T>(type : Class<T>, builder :  Void -> Promise<T -> Void>)
	{
		provideImpl(type.toString(), builder);
		return this;
	}

	function provideImpl<T>(name : String, impl : Void -> Promise<T -> Void>)
	{
		var provider = getProvider(name);
		if(null != provider.fullfiller)
			throw "provider implementation already provided";
		provider.fullfiller = impl;
		var demand;
		while(null != (demand = provider.demands.shift()))
		{
			provider.fullfiller().then(demand.resolve);
		}
	}

	function getProvider(type : String)
	{
		var provider = providers.get(type);
		if (null == provider)
			providers.set(type, provider = { demands : [], fullfiller : null });
		return provider;
	}
}