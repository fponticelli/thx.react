package thx.react.promise;

using thx.reac.Promise;

class Http 
{
	public var cnxTimeout(get_cnxTimeout, set_cnxTimeout) : Float;
	public var noShutdown(get_noShutdown, set_noShutdown) : Bool;
	public var responseHeaders(default,null) : StringMap<String>

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

	public function customRequest(post : Bool, api : Output, ?sock : AbstractSocket, ?method : String)
	{
		var p = promise();
		connection.customRequest(post, api, sock, method);
		return p;
	}

	public function fileTransfert(argname : String, filename : String, file : Input, size : Int)
	{
		var p = promise();
		connection.fileTransfert(argname, filename, file, size);
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
		connection.onData   = deferred.resolve;
		connection.onError  = deferred.reject;
//		connection.onStatus = deferred.resolve;
		return deferred.promise;
	}

	function get_cnxTimeout()
		return connection.cnxTimeout;

	function set_cnxTimeout(value)
		return connection.cnxTimeout = value;

	function get_noShutdown()
		return connection.noShutdown;

	function set_noShutdown(value)
		return connection.noShutdown = value;
}