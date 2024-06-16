package save;

import openfl.utils.Object;

class Persistant<T> {
	@:isVar
	public var value(get, set):T;

	private var _id:String;

	private var _loaded:Bool = false;

	/**
	 *	
	**/
	public function new(id:String, defaultValue:T) {
		_id = id;
		value = defaultValue;
	}

	public function load():Void {
		if (!_loaded && _id != "" && PlayerAccount.get() != null) {
			var v = PlayerAccount.get().loadValue(_id);
			if (v != null)
				value = v;
			_loaded = true;
		}
	}

	private function saveValue(value:Object, flush:Bool = true):Void {
		if (_loaded && _id != "" && PlayerAccount.get() != null)
			PlayerAccount.get().saveValue(_id, value, flush);
	}

	@:noCompletion
	function get_value():T {
		load();
		return value;
	}

	@:noCompletion
	function set_value(v:T):T {
		saveValue(v);
		return value = v;
	}
}