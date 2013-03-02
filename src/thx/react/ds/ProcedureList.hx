package thx.react.ds;

import thx.core.Procedure;

class ProcedureList<T>
{

	var iterators : Map<Int, Int>;
	static var iterator_id : Int = 0;

	var a : Array<Procedure<T>>;
	public function new()
	{
		a = [];
		iterators = new Map();
	}

	public function add( item : Procedure<T> ) {
		a.push(item);
	}

	public function remove( v : Procedure<T>) : Bool {
		for(i in 0...a.length)
		{
			if(a[i].equal(v)) {
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

	public function iterator() : Iterator<Procedure<T>> {
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