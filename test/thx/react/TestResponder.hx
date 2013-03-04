/**
 * ...
 * @author Franco Ponticelli
 */

package thx.react;

import utest.Assert;

class TestResponder
{
	public function new() 
	{
		
	}
	
	public function testRequestRespondImplementation()
	{
		var responder = new Responder();
		responder.request_impl("request", "response", "a").then(function(v) Assert.equals("A", v));
		responder.respond_impl("request", "response", function(v) return null);
		responder.respond_impl("request", "response", function(v) return Promise.value(v.toUpperCase()));
	}
	
	public function testRespondRequestImplementation()
	{
		var responder = new Responder();
		responder.respond_impl("request", "response", function(v) return null);
		responder.respond_impl("request", "response", function(v) return Promise.value(v.toUpperCase()));
		responder.request_impl("request", "response", "a").then(function(v) Assert.equals("A", v));
	}
}