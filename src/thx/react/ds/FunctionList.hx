package thx.react.ds;

class FunctionList
{

	var iterators : Map<Int, Int>;
	static var iterator_id : Int = 0;

	var a : Array<Dynamic>;
	public function new()
	{
		a = [];
		iterators = new Map();
	}

	public function add( item : Dynamic ) {
		a.push(item);
	}

	public function remove( v : Dynamic ) : Bool {
		for(i in 0...a.length)
		{
			if(Reflect.compareMethods(a[i], v)) {
				updateIterators(i);
				a.splice(i, 1);
				return true;
			}
		}
		return false;
	}

	function updateIterators(i : Int)
	{
		var index;
		for(key in iterators.keys())
		{
			index = iterators.get(key);
			if(i < index)
			{
				iterators.set(key, index - 1);
			}
		}
	}

	public function iterator() : Iterator<Dynamic> {
		var key = ++iterator_id;
		iterators.set(key, 0);
		return {
			next : function() {
				var index = iterators.get(key) ;
				iterators.set(key, index+1);
				return a[index];
			},
			hasNext : function() {
				if(iterators.exists(key) && iterators.get(key) < a.length) {
					return true;
				} else {
					iterators.remove(key);
					return false;
				}
			}
		};
	}
}