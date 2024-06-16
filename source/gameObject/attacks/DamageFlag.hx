package gameObject.attacks;

enum abstract DamageFlag(Int) from Int to Int {
	var NONE = 0;
	var MELEE = value(0); // 1
	var RANGE = value(1); // 2
	var SPELL = value(2); // 4
	var THORN = value(3); // 8
	var ANY = MELEE | RANGE | SPELL;

	static inline function value(index:Int)
		return 1 << index;

	inline public function remove(mask:DamageFlag):DamageFlag {
		return this & ~mask;
	}

	inline public function add(mask:DamageFlag):DamageFlag {
		return this | mask;
	}

	inline public function contains(mask:DamageFlag):Bool {
		return this & mask != 0;
	}
}