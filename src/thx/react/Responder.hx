/**
 * ...
 * @author Franco Ponticelli
 */

package thx.react;

using thx.react.Promise;

class Responder
{
	static inline var SEPARATOR : String = ":";
	var respondersMap : Map<String, Array<Dynamic -> Null<Promise<Dynamic>>>>;
	var requestsMap : Map<String, Array<{ deferred : Deferred<Dynamic>, payload : Dynamic }>>;
	public function new() 
	{
		respondersMap = new Map();
		requestsMap   = new Map();
	}
	
	public function request<TRequest, TResponse>(payload : TRequest) : Promise<TResponse>
	{
		return null;
	}
	
	@:noCompletion @:noDoc
	public function request_impl(requestType : String, responseType : String, payload : Dynamic)
	{
		var key = getKey(requestType, responseType),
			arr = requestsMap.get(key),
			deferred = new Deferred<Dynamic>();
		if (null == arr)
			requestsMap.set(key, arr = []);
		arr.unshift({ payload : payload, deferred : deferred });
		update(requestType, responseType);
		return deferred.promise;
	}
	
	public function respond<TRequest, TResponse>(handler : TRequest -> Null<Promise<TResponse>>)
	{
		
		return this;
	}
	
	@:noCompletion @:noDoc
	public function respond_impl(requestType : String, responseType : String, handler : Dynamic -> Null<Promise<Dynamic>>)
	{
		var key = getKey(requestType, responseType),
			arr = respondersMap.get(key);
		if (null == arr)
			respondersMap.set(key, arr = []);
		arr.push(handler);
		update(requestType, responseType);
	}
	
	function update(requestType : String, responseType : String)
	{
		var key        = getKey(requestType, responseType),
			requests   = requestsMap.get(key),
			responders = respondersMap.get(key);
		if (null == requests || null == responders)
			return;
		
		var i = requests.length;
		while(--i >= 0)
		{
			var request = requests[i],
				promise = null;
			for (responder in responders)
			{
				promise = responder(request.payload);
				if (null != promise)
					break;
			}
			if (null != promise)
			{
				requests.splice(i, 1);
				promise
					.then(request.deferred.resolve)
					.fail(request.deferred.reject)
					.progress(request.deferred.notify)
				;
			}
		}
	}
	
	function getKey(requestType : String, responseType : String) return '$requestType$SEPARATOR$responseType';
/*
  .request<TRequest, TResponse>(payload : TRequest) : Promise<TResponse>
  .respond<TRequest, TResponse>(handler : TRequest -> Null<Promise<TResponse>>) : Void

  .filterRequest<TIn, TOut>(payload : TIn) : Promise<TOut>
  .filterResponse<TIn, TOut>(data : TIn) : Promise<TOut> 
*/
	
}