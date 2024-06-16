package global.attribute;

import data.DataSkill;
import gameObject.spells.Caster;
import global.attribute.AttributeModifier;

class AttributeController {
	public var attributesModifiers = new Map<AttributeType, AttributeModifier>();

	public function new() {}

	public function addFromTBaseAttributeModifier(tAttribute:TBaseAttributeModifier):Void {
		addAttributeModifier(tAttribute.attribute, tAttribute.createBaseAttributeModifer(), tAttribute.mod, tAttribute.id);
	}

	/**
	 * value : value (true) or multiplier (false)
	**/
	public function addAttributeModifier(type:AttributeType, modifier:BaseAttributeModifier, value:Bool, id:String = ""):Void {
		if (!attributesModifiers.exists(type)) {
			attributesModifiers.set(type, new AttributeModifier());
		}

		if (id.length == 0)
			attributesModifiers[type].addBonus(modifier, value);
		else
			attributesModifiers[type].addBonusWithId(modifier, value, id);
	}

	/**
		Apply critical chance and critical damage
	**/
	public function calculateSpellDamage(owner:Caster, value:Float):Float {
		var criticalDmg:Float = 1;
		if (Math.random() < calculateValue(CRITICAL_CHANCE, owner.flags, 0))
			criticalDmg = calculateValue(CRITICAL_DAMAGE, owner.flags, Constant.DEFAULT_CRITICAL_DAMAGE);

		return calculateValue(SPELL_DAMAGE, owner.flags, value) * criticalDmg;
	}

	public function calculateValue(id:AttributeType, flags:AttributeFlag, value:Float):Float {
		if (!attributesModifiers.exists(id))
			return value;

		return attributesModifiers[id].calculateValue(value, flags);
	}
}