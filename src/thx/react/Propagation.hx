/**
 * ...
 * @author Franco Ponticelli
 */

package thx.react;

class Propagation
{
	static var instance = new Propagation();
	public static function cancel() throw instance
	function new() { }
}