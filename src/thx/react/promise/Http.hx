package thx.react.promise;

using thx.react.Promise;
import haxe.io.Input;
import haxe.io.Output;

class Http 
{
	public var responseHeaders(default,null) : Map<String, String>;

	var connection : haxe.Http;
	public function new(url : String)
	{
		connection = new haxe.Http(url);
	}

	public function request(?post : Bool)
	{
		var p = promise();
		connection.request(post);
		return p;
	}

	public function setHeader(header : String, value : String)
	{
		connection.setHeader(header, value);	
		return this;
	}
	public function setParameter( param : String, value : String)
	{
		connection.setParameter(param, value);	
		return this;
	}

	public function setPostData(data : String)
	{
		connection.setPostData(data);	
		return this;
	}

	function promise()
	{
		var deferred = new Deferred();
		connection.onData   = function(v) deferred.resolve(v);
		connection.onError  = function(v) deferred.reject(v);
//		connection.onStatus = deferred.resolve;
		return deferred.promise;
	}
}