/**
 * ...
 * @author Franco Ponticelli
 */

package thx.react;

using thx.core.Types;
using thx.react.Promise;

#if macro
import haxe.macro.Expr;
import haxe.macro.Context;
using haxe.macro.TypeTools;
using thx.macro.MacroTypes;
#end

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


	public function request<TRequest, TResponse>(payload : TRequest, responseType : Class<TResponse>) : Promise<TResponse -> Void>
	{
		var request  = Type.typeof(payload).toString(),
			response = responseType.toString();
		return request_impl(request, response, payload);
	}

/*
	macro public function request<TResponse>(ethis : ExprOf<Responder>, payload : Expr) : ExprOf<Promise<TResponse -> Void>>
	{
		var request  = TypeTools.toString(Context.typeof(payload)),
			response = ""; //responseType.toString();
		trace(Context.getLocalMethod().get());
//		trace(haxe.macro.Type.Ref.get());
//		return request_impl(request, response, payload);
		return macro $ethis.request_impl($v{request}, $v{response}, $payload);
	}
*/
	
	@:noCompletion @:noDoc
	public function request_impl<TResponse>(requestType : String, responseType : String, payload : Dynamic) : Promise<TResponse -> Void>
	{
		var key = getKey(requestType, responseType),
			arr = requestsMap.get(key),
			deferred = new Deferred<TResponse>();
		if (null == arr)
			requestsMap.set(key, arr = []);
		arr.unshift({ payload : payload, deferred : deferred });
		update(requestType, responseType);
		return deferred.promise;
	}
	
	public function respond<TRequest, TResponse>(handler : TRequest -> Null<Promise<TResponse -> Void>>, requestType : Class<TRequest>, responseType : Class<TResponse>)
	{
		var request  = requestType.toString(),
			response = responseType.toString();
		return respond_impl(request, response, handler);
	}
	
	@:noCompletion @:noDoc
	public function respond_impl<TResponse>(requestType : String, responseType : String, handler : Dynamic -> Null<Promise<TResponse -> Void>>)
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