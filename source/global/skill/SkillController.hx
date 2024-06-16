package global.skill;

import gameObject.items.ItemScroll.Element;
import global.attribute.AttributeFlag;
import global.attribute.AttributeModifier;
import global.attribute.AttributeController;

using Lambda;
using StringTools;

class SkillController {
	/** List of all available skills locked and unlocked **/
	private var skills:Map<String, Skill> = new Map();

	/** Link to the attribute controller to apply new skills / upgraded skills**/
	private var attributeController:AttributeController = null;

	public function new(tSkills:Map<String, Array<TSkillBaseAttributeModifier>>, attributeController:AttributeController) {
		this.attributeController = attributeController;

		// Create all the skills from the Skill type data
		for (tSkill in tSkills) {
			var skill = new Skill(tSkill);
			skills[skill.id] = skill;
			// Initialize attributes for unlocked skills
			if (skill.currentLevel > 0)
				this.attributeController.addFromTBaseAttributeModifier(skill.getCurrentTSkill());
		}
	}

	/**
		Initializes the skills for all affinity elements. The associated attributes are not initialized
	**/
	public function initializeAffinitySkills(tAffinitySkills:Map<String, Array<TSkillBaseAttributeModifier>>):Void {
		var affinityLevel = attributeController.calculateValue(AttributeType.ELEMENTAL_AFFINITY, AttributeFlag.PLAYER, 0);

		// Create all the skills from the Skill type data
		for (tSkill in tAffinitySkills) {
			var skill = new Skill(tSkill);
			skills[skill.id] = skill;

			// Level up to current affinity level
			while (skill.currentLevel < affinityLevel)
				if (!skill.levelUp())
					break;
		}
	}

	/**
		From the selected element in the Affinity selection, it initializes the attributes related to the Affinity skill
	**/
	public function initializeAffinityAttributes(element:Element):Void {
		var skill = getSkill(Constant.AFFINITY_PREFIX + element);

		if (skill != null && skill.currentLevel > 0)
			attributeController.addFromTBaseAttributeModifier(skill.getCurrentTSkill());
	}

	/**
		List of all skills, by skill ID
	**/
	public function getAllSkills():Map<String, Skill> {
		return skills;
	}

	/**
		List of skills for the given category
	**/
	public function getSkillsByCategory(category:String):Array<Skill> {
		return skills.filter(function(skill) return skill.category == category);
	}

	/**
		Sum of levels of all skills
	**/
	public function getTotalSkillLevels(excludeAffinity:Bool = true):Int {
		if (excludeAffinity)
			return skills.fold(function(skill, total) return total += skill.currentLevel, 0);
		return skills.fold(function(skill, total) return total += skill.currentLevel, 0);
	}

	/**
		Returns true if max level, false otherwise
	**/
	public function levelUpSkill(skill:Skill):Bool {
		if (skill == null)
			return false;

		if (skill.levelUp()) {
			// Update skill attributes
			attributeController.addFromTBaseAttributeModifier(skill.getCurrentTSkill());

			// Dispatch event
			Trigger.SKILL_LEVEL_UP.dispatch(skill.id);
		}

		return skill.currentLevel == skill.maxLevel;
	}

	public function getSkill(skillId:String):Skill {
		if (skillId == null)
			return null;

		return skills[skillId.toUpperCase()];
	}

	public function resetAll() {
		for (skill in skills)
			skill.reset();
	}
}