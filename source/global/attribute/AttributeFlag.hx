package global.attribute;

enum abstract AttributeFlag(Int) from Int to Int {
	var NONE = 0;
	// Owner
	var PLAYER = value(0); // 1
	var ALLY = value(1); // 2
	var ENEMY = value(2); // 4
	// Elements
	var FIRE = value(3); // 8
	var METAL = value(4); // 16
	var WATER = value(5); // 32
	var ANY_OWNER = PLAYER | ALLY | ENEMY;
	var ANY_ELEMENT = FIRE | METAL | WATER;
	var ANY = ANY_OWNER | ANY_ELEMENT;

	static inline function value(index:Int)
		return 1 << index;

	inline public function remove(mask:AttributeFlag):AttributeFlag {
		return this & ~mask;
	}

	inline public function add(mask:AttributeFlag):AttributeFlag {
		return this | mask;
	}

	inline public function contains(mask:AttributeFlag):Bool {
		return this & mask != 0;
	}

	inline public function matchOwner(mask:AttributeFlag):Bool {
		return this & mask & ANY_OWNER != 0;
	}

	inline public function matchElement(mask:AttributeFlag):Bool {
		return this & mask & ANY_ELEMENT != 0;
	}

	/**
		Shortcut for mathOwner and Element
	**/
	inline public function match(mask:AttributeFlag):Bool {
		// No flags in common
		if (!mask.contains(this))
			return false;

		var result:Bool = true;
		if (this & ANY_OWNER != 0 && mask & ANY_OWNER != 0)
			result = result && mask.matchOwner(this);
		if (this & ANY_ELEMENT != 0 && mask & ANY_ELEMENT != 0)
			result = result && mask.matchElement(this);

		return result;
	}
}