package global.attribute;

import macros.MyMacros;

enum abstract AttributeMod(Bool) from Bool to Bool {
	var VALUE = true;
	var MULTIPLIER = false;
}

enum abstract AttributeType(String) from String to String {
	var NONE;
	var SPELL_DAMAGE;
	var SPELL_CASTING_RATE;
	var SPELL_DURATION;
	var SPELL_AOE;
	var SPELL_RANGE;
	var CRITICAL_CHANCE;
	var CRITICAL_DAMAGE;
	var ADD_WIZARD;
	var FORTRESS_LIFE;
	var FORTRESS_DEFENSE;
	var FORTRESS_REGEN;
	var FORTRESS_SPIKE_DAMAGE;
	var RECYCLE_TWO;
	var RECYCLE_THREE;
	var REVIVE;
	var SCROLLS_LIMIT;
	var SCROLL_PER_WAVE;
	var ELEMENTAL_AFFINITY;
	var INITIAL_SCROLLS;
	var LIFE_LEACH;
	var DEFENSE_REDUCTION; // Percentage
	var BURN;
	var AREA_DAMAGE;
	var AREA_DAMAGE_CHANCE;
	var FREEZE_CHANCE;
	var FREEZE_DURATION; // Seconds
}

class TBaseAttributeModifier {
	public var id = "";
	public var value:Float;
	public var flags = AttributeFlag.NONE;
	public var mod = AttributeMod.VALUE;
	public var attribute = AttributeType.NONE;
	public var description:String = "";
	public var bonusDescription:String = "";

	public function new(id:String, value:Float, flags:AttributeFlag, mod:AttributeMod, attribute:AttributeType, description:String, bonusDescription:String) {
		MyMacros.initLocals();
	}

	public function createBaseAttributeModifer():BaseAttributeModifier {
		return new BaseAttributeModifier(value, flags);
	}
}

class BaseAttributeModifier {
	public var value:Float;
	public var flags = AttributeFlag.NONE;

	public function new(value:Float, flags:AttributeFlag) {
		this.value = value;
		this.flags = flags;
	}
}

class AttributeModifier {
	private var bonusValues:Array<BaseAttributeModifier> = [];
	private var bonusMultipliers:Array<BaseAttributeModifier> = [];

	private var bonusValuesWithId:Map<String, BaseAttributeModifier> = new Map();
	private var bonusMultipliersWithId:Map<String, BaseAttributeModifier> = new Map();

	public function new() {}

	public function addBonus(bonus:BaseAttributeModifier, value:AttributeMod) {
		if (value)
			addBonusValue(bonus);
		else
			addBonusMultiplier(bonus);
	}

	public function addBonusWithId(bonus:BaseAttributeModifier, value:AttributeMod, id:String) {
		if (value)
			addBonusValueWithId(bonus, id);
		else
			addBonusMultiplierWithId(bonus, id);
	}

	public function removeBonus(bonus:BaseAttributeModifier, value:AttributeMod) {
		if (value)
			removeBonusValue(bonus);
		else
			removeBonusMultiplier(bonus);
	}

	public function removeBonusById(id:String, value:AttributeMod) {
		if (value)
			removeBonusValueById(id);
		else
			removeBonusMultiplierById(id);
	}

	public function addBonusValueWithId(bonusValue:BaseAttributeModifier, id:String) {
		bonusValuesWithId[id] = bonusValue;
	}

	public function addBonusMultiplierWithId(bonusMultiplier:BaseAttributeModifier, id:String) {
		bonusMultipliersWithId[id] = bonusMultiplier;
	}

	public function addBonusValue(bonusValue:BaseAttributeModifier) {
		bonusValues.push(bonusValue);
	}

	public function addBonusMultiplier(bonusMultiplier:BaseAttributeModifier) {
		bonusMultipliers.push(bonusMultiplier);
	}

	public function removeBonusValueById(id:String) {
		bonusValuesWithId.remove(id);
	}

	public function removeBonusMultiplierById(id:String) {
		bonusMultipliersWithId.remove(id);
	}

	public function removeBonusValue(bonusValue:BaseAttributeModifier) {
		bonusValues.remove(bonusValue);
	}

	public function removeBonusMultiplier(bonusMultiplier:BaseAttributeModifier) {
		bonusMultipliers.remove(bonusMultiplier);
	}

	public function calculateValueInt(baseValue:Int, flags:AttributeFlag):Int {
		return Math.round(calculateValue(baseValue, flags));
	}

	public function calculateValue(baseValue:Float, flags:AttributeFlag):Float {
		var finalValue:Float = baseValue;

		for (bonusValue in bonusValues) {
			if (flags.match(bonusValue.flags))
				finalValue += bonusValue.value;
		}

		for (bonusValue in bonusValuesWithId) {
			if (flags.match(bonusValue.flags))
				finalValue += bonusValue.value;
		}

		for (bonusMultiplier in bonusMultipliers) {
			if (flags.match(bonusMultiplier.flags))
				finalValue *= bonusMultiplier.value;
		}

		for (bonusMultiplier in bonusMultipliersWithId) {
			if (flags.match(bonusMultiplier.flags))
				finalValue *= bonusMultiplier.value;
		}

		return finalValue;
	}
}