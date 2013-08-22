package thx.react;

#if macro
import haxe.macro.Expr;
using haxe.macro.Context;
using haxe.macro.TypeTools;
using thx.macro.MacroTypes;
#end
using thx.core.Types;


// TODO: add dequeue/dequeueMany to process and remove from the buffer
class Buffer
{
	var queues : Map<String, Array<Dynamic>>;
	var consumers : Map<String, Array<{
			handler : Array<Dynamic> -> Void,
			pos : Int
		}>>;
	public function new()
	{
		queues = new Map();
		consumers = new Map();
	}

	public function enqueue<T>(value : T)
	{
		enqueueMany([value]);
	}

	public function enqueueMany<T>(values : Iterable<T>)
	{
		var names = [];
		for(value in values)
		{
			var name  = Type.typeof(value).toString(),
				queue = ensureQueue(name);
			names.push(name);
			queue.push(value);
		}
		for(name in names)
			trigger(name);
	}

	function ensureQueue(name : String)
	{
		var queue = queues.get(name);
		if(null == queue)
			queues.set(name, queue = []);
		return queue;
	}

#if macro
	public static function getArrayArgumentType(handler : Expr)
	{
		var ftype  = Context.typeof(handler),
			type   = ftype.getArgumentType(0),
			cls    = type.getClass(),
			params = type.getClassTypeParameters();
		return params[0].toString();
	}

	public static function getArgumentType(handler : Expr)
	{
		var ftype  = Context.typeof(handler),
			type   = ftype.getArgumentType(0);
		return type.toString();
	}
#end

	macro public function processMany<T>(ethis : ExprOf<Buffer>, handler : Expr)
	{
		var name = getArrayArgumentType(handler);
		return macro $ethis.processManyImpl($v{name}, $handler);
	}

	@:noDoc @:noDisplay
	public function processManyImpl<T>(name : String, handler : Array<T> -> Void)
	{
		var list = consumers.get(name);
		if(null == list)
			consumers.set(name, list = []);
		list.push({ handler : cast handler, pos : 0 });
		trigger(name);
	}

	macro public function process<T>(ethis : ExprOf<Buffer>, handler : Expr)
	{
		var name = getArgumentType(handler);
		return macro $ethis.processImpl($v{name}, $handler);
	}

	@:noDoc @:noDisplay
	public function processImpl<T>(name : String, handler : T -> Void)
	{
		var list = consumers.get(name);
		if(null == list)
			consumers.set(name, list = []);
		list.push({ handler : cast function(list) list.map(handler), pos : 0 });
		trigger(name);
	}

	function trigger(name : String)
	{
		var list = consumers.get(name);
		if(null == list || list.length == 0)
			return;
		var queue = queues.get(name);
		if(null == queue)
			return;
		for(consumer in list)
		{
			var arr = queue.slice(consumer.pos),
				len = arr.length;
			if(len > 0) {
				consumer.handler(arr);
				consumer.pos += len;
			}
		}
	}
}