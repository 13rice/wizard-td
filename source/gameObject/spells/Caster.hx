package gameObject.spells;

import gameObject.items.ItemScroll.Element;
import global.shared.Log;
import global.attribute.AttributeFlag;


/**
	Animations:
	* idle
	* casting_effect
**/
class Caster extends GameObject {
	public var flags = AttributeFlag.NONE;

	public function new(x:Float, y:Float, player:Bool) {
		super(x, y, 0, false, false);

		if (player) {
			flags = flags.add(AttributeFlag.PLAYER);
		} else {
			flags = flags.add(AttributeFlag.ALLY);
		}
	}

	public function addFlag(flag:AttributeFlag):AttributeFlag {
		return flags = flags.add(flag);
	}

	public function clearElementFlags():Void {
		for (el in Element.array()) {
			flags = flags.remove(Element.toAttributeFlag(el));
		}
	}

}
