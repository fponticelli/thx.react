/**
 * ...
 * @author Franco Ponticelli
 */

package thx.react;

import utest.Assert;
using thx.react.Promise;
using thx.react.TestPromise;

class TestResponder
{
	public function new() 
	{
		
	}
	
	public function testRequestRespond()
	{
		var responder = new Responder();
		responder.request("a", String).then(function(v) Assert.equals("A", v)).lose1().completeTest();
		responder.respond(function(v : String) return null, String, TestResponder);
		responder.respond(function(v : String) return Promise.value(v.toUpperCase()), String, String);
	}
	
	public function testRespondRequest()
	{
		var responder = new Responder();
		responder.respond(function(v : String) return null, String, TestResponder);
		responder.respond(function(v : String) return Promise.value(v.toUpperCase()), String, String);
		responder.request("a", String).then(function(v) Assert.equals("A", v)).lose1().completeTest();
	}
}