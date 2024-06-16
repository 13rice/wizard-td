package global.skill;

import save.Persistant;

class Skill {
	@:isVar
	public var _currentLevel:Persistant<Int> = null;

	public var currentLevel(get, never):Int;

	public var id(get, null):String;
	public var x(get, null):Int;
	public var y(get, null):Int;
	public var maxLevel(get, null):Int;
	public var category(get, null):String;
	public var stage(get, null):Int;

	private var lSkills:Array<TSkillBaseAttributeModifier> = [];

	/**
	 * @param skills list of levels
	**/
	public function new(skills:Array<TSkillBaseAttributeModifier>) {
		if (skills != null)
			lSkills = skills;
		_currentLevel = new Persistant<Int>(id, 0);
	}

	public function getFirstTSkill():TSkillBaseAttributeModifier {
		return lSkills[0];
	}

	public function getCurrentTSkill():TSkillBaseAttributeModifier {
		if (currentLevel > 0 && currentLevel <= lSkills.length)
			return lSkills[currentLevel - 1];

		return null;
	}

	/**
		Returns current TSkill, or first Tskill if current is null (level 0)
	**/
	public function getCurrentTSkillOrFirst():TSkillBaseAttributeModifier {
		return getCurrentTSkill() != null ? getCurrentTSkill() : getFirstTSkill();
	}

	public function getNextTSkill():TSkillBaseAttributeModifier {
		if (currentLevel >= 0 && currentLevel < lSkills.length)
			return lSkills[currentLevel];

		return null;
	}

	public function levelUp():Bool {
		if (currentLevel < lSkills.length) {
			_currentLevel.value++;
			return true;
		}
		return false;
	}

	public function isUnlocked():Bool {
		return currentLevel > 0;
	}

	public function reset() {
		_currentLevel.value = 0;
	}
	
	@:noCompletion
	public function get_currentLevel():Int {
		return _currentLevel.value;
	}

	@:noCompletion
	public function get_id():String {
		return (lSkills[0] != null ? lSkills[0].id : "");
	}
	@:noCompletion
	public function get_x():Int {
		return (lSkills[0] != null ? lSkills[0].x : 0);
	}

	@:noCompletion
	public function get_y():Int {
		return (lSkills[0] != null ? lSkills[0].y : 0);
	}

	@:noCompletion
	public function get_maxLevel():Int {
		return (lSkills[0] != null ? lSkills[0].maxLevel : 0);
	}

	@:noCompletion
	public function get_category():String {
		return (lSkills[0] != null ? lSkills[0].category : "");
	}
	@:noCompletion
	public function get_stage():Int {
		return (lSkills[0] != null ? lSkills[0].stage : 0);
	}
}