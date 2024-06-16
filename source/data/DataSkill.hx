package data;

import global.skill.TSkillBaseAttributeModifier;
import global.attribute.AttributeFlag;
import global.attribute.AttributeModifier;
import global.shared.Log;
import haxe.ds.Map;
import haxe.xml.Access;
import Constant;

/**
 * Singleton
 * For :
 * Skills
 * @author 13rice
 */
@:allow(TBaseAttributeModifier)
@:allow(AttributeModifier)
@:allow(AttributeController)
class DataSkill {
	// Chargement des données par XML
	private var _lTBaseAttributes:Map<Int /*level*/, Map<String /*id*/, TBaseAttributeModifier>>;
	private var _lTAbilities:Map<Int /*level*/, Map<String /*id*/, TBaseAttributeModifier>>;
	private var _lTSkillsTree:Map<String /*id*/, Array<TSkillBaseAttributeModifier>>;
	private var _lTSkillsAffinity:Map<String /*id*/, Array<TSkillBaseAttributeModifier>>;

	// Singleton
	private static var _instance = new DataSkill();

	private function new() {
		_lTBaseAttributes = new Map<Int, Map<String /*id*/, TBaseAttributeModifier>>();
		_lTSkillsTree = new Map<String /*id*/, Array<TSkillBaseAttributeModifier>>();
		_lTSkillsAffinity = new Map<String /*id*/, Array<TSkillBaseAttributeModifier>>();
		_lTAbilities = new Map<Int, Map<String /*id*/, TBaseAttributeModifier>>();
	}

	public static function get():DataSkill {
		return _instance;
	}

	public function getAllTSkillsTree():Map<String /*id*/, Array<TSkillBaseAttributeModifier>> {
		return _lTSkillsTree;
	}
	public function getAllTSkillsAffinity():Map<String /*id*/, Array<TSkillBaseAttributeModifier>> {
		return _lTSkillsAffinity;
	}

	/**
	 * Load all the spells datas from <spelldatas> node
	 * @param	node
	 */
	public function loadLevelsFromXML(node:Access):Void {
		if (node == null || node.name != "levels") {
			trace("error loading xml data in DataSkill, levels node expected");
			return;
		}

		// Levels
		for (child in node.nodes.level) {
			loadLevel(child);
		}
	}

	/**
	 * Load all the skills datas from <skilltree> or <affinity> node
	 * @param	node
	 */
	public function loadSkillsFromXML(node:Access, skillTree:Bool):Void {
		if (node == null || (node.name != "skilltree" && node.name != "affinity")) {
			trace("error loading xml data in DataSkill, <skilltree> or <affinity> node expected");
			return;
		}

		// Skill tree
		for (category in node.nodes.category) {
			loadSkillCategory(category, skillTree ? _lTSkillsTree : _lTSkillsAffinity);
		}
	}

	/**
		* Level Sample
		* 		<category id="Alchemy">
					<skill id="PLAYER_RECYCLE_TWO" bonus="0.7" mod="0" attribute="RECYCLE_TWO" flag="1" desc="Allows to recycle. 70 % chance to recycle two elements per spell level." name="Conversion" maxLevel="4" stage="1" x="200" y="170" />
					<skill id="FORTRESS_REGEN" bonus="5" mod="1" attribute="FORTRESS_REGEN" flag="1" desc="Restore 5 damage after each wave" name="Regeneration" maxLevel="4" stage="2" x="145" y="160" />
			</category>
		* @param	node
		* @return
	 */
	private function loadSkillCategory(node:Access, lTSkills:Map<String /*id*/, Array<TSkillBaseAttributeModifier>>):Void {
		if (!checkCategoryNode(node)) {
			return;
		}

		var categoryId:String = node.att.id;

		// Load Skills
		for (skillNode in node.nodes.skill) {
			var skill:TSkillBaseAttributeModifier = loadSkilltreeSkill(skillNode, categoryId);
			if (skill == null)
				continue;

			if (!lTSkills.exists(skill.id))
				lTSkills[skill.id] = new Array();

			lTSkills[skill.id][skill.level] = skill;
		}
	}

	/**
		* Level Sample
		* 	<level id="1">
					<skills>
						<skill id="PLAYER_RATE_LVLUP" bonus="1.01" mod="0" attribute="SPELL_CASTING_RATE" flag="1" desc="Player casting rate: +1%" bonusDesc="+1%" />
						<skill id="PLAYER_DMG_LVLUP" bonus="1.05" mod="0" attribute="SPELL_DAMAGE" flag="1" desc="Player damage: +5%" bonusDesc="+5%" />
					</skills>
					<abilities>
						<skill id="ADD_WIZARD" bonus="1" mod="1" attribute="ADD_WIZARD" flag="1" desc="Adds another wizard casting spells with you. At vero eos et accusamus et iusto odio dignissimos ducimus qui blanditiis" bonusDesc="" />
					</abilities>
				</level>
		* @param	node
		* @return
	 */
	private function loadLevel(node:Access):Void {
		if (!checkLevelNode(node)) {
			return;
		}

		var id:Int = Std.parseInt(node.att.id);

		// Load Skills
		var skills:Map<String, TBaseAttributeModifier> = new Map();

		if (node.hasNode.skills) {
			for (skillNode in node.node.skills.nodes.skill) {
				var skill:TBaseAttributeModifier = loadSkill(skillNode);
				if (skill == null)
					continue;

				var skillId:String = skillNode.att.id;
				skills[skillId] = skill;
			}

			_lTBaseAttributes[id] = skills;
		}

		// Load Abilities
		var abilities:Map<String, TBaseAttributeModifier> = new Map();

		if (node.hasNode.abilities) {
			for (abilityNode in node.node.abilities.nodes.skill) {
				var skill:TBaseAttributeModifier = loadSkill(abilityNode);
				if (skill == null)
					continue;

				var skillId:String = abilityNode.att.id;
				abilities[skillId] = skill;
			}

			_lTAbilities[id] = abilities;
		}
	}

	/**
	 * Skill sample
	 * <skill id="PLAYER_DMG_LVLUP" bonusValue="1" bonusMultiplier="5" attribute="SPELL_DAMAGE" flag="1">
	 * @param	node
	 * @return
	 */
	private function loadSkill(node:Access):TBaseAttributeModifier {
		if (!checkSkillNode(node))
			return null;

		// Load Skill
		var flag:AttributeFlag = (node.has.flag ? Std.parseInt(node.att.flag) : AttributeFlag.ANY);
		var mod:AttributeMod = Std.parseInt(node.att.mod) == 1;
		var attribute = new TBaseAttributeModifier(node.att.id, Std.parseFloat(node.att.bonus), flag, mod, node.att.attribute, node.att.desc,
			node.att.bonusDesc);

		return attribute;
	}

	/**
		* Skilltree skill sample
			<skill id="FORTRESS_DEFENSE" bonus="0.2" mod="0" attribute="FORTRESS_DEFENSE" flag="1" desc="Increase the defense of the fortress to 20%" name="Transmute" maxLevel="4" stage="2" x="185" y="120" level="3" />
		* @param	node
		* @return
	 */
	private function loadSkilltreeSkill(node:Access, category:String):TSkillBaseAttributeModifier {
		if (!checkSkillTreeNode(node))
			return null;

		// Load Skill
		var flag:AttributeFlag = (node.has.flag ? Std.parseInt(node.att.flag) : AttributeFlag.ANY);
		var mod:AttributeMod = Std.parseInt(node.att.mod) == 1;
		var attribute = new TSkillBaseAttributeModifier(node.att.id, Std.parseFloat(node.att.bonus), flag, mod, node.att.attribute, node.att.desc,
			node.att.bonusDesc,
			Std.parseInt(node.att.x), Std.parseInt(node.att.y), node.att.name, Std.parseInt(node.att.level), Std.parseInt(node.att.maxLevel), category,
			Std.parseInt(node.att.stage));

		return attribute;
	}

	/**
	 * Returns skills for a level
	 * @param	level : id TLevel
	 * @return  empty map if error
	 */
	public function getTBaseAttributes(level:Int):Map<String, TBaseAttributeModifier> {
		if (_lTBaseAttributes == null) {
			Log.error("_lTBaseAttribute null");
			return new Map();
		}

		if (!_lTBaseAttributes.exists(level)) {
			Log.trace("ERROR can't find this kind of level: " + level);
			return new Map();
		}

		return _lTBaseAttributes[level];
	}

	/**
	 * Returns abilities for a level
	 * @param	level : id TLevel
	 * @return  null if error
	 */
	public function getTAbilities(level:Int):Map<String, TBaseAttributeModifier> {
		if (_lTAbilities == null) {
			Log.error("_lTAbilities null");
			return new Map();
		}

		if (!_lTAbilities.exists(level)) {
			Log.trace("ERROR can't find this kind of level: " + level);
			return new Map();
		}

		return _lTAbilities[level];
	}

	public function isTLevelExists(levelId:Int):Bool {
		return _lTBaseAttributes.exists(levelId);
	}

	/**
	 * 
	 * @param	node
	 * @return
	 */
	public function checkLevelNode(node:Access):Bool {
		return checkNode(node, "Level", "id");
	}

	/**
	 * 
	 * @param	node
	 * @return
	 */
	public function checkCategoryNode(node:Access):Bool {
		return checkNode(node, "Category", "id");
	}

	/**
	 * 
	 * @param	node
	 * @return
	 */
	public function checkSkillNode(node:Access):Bool {
		return checkNode(node, "Skill", "id")
			&& checkNode(node, "Skill", "attribute")
			&& checkNode(node, "Skill", "bonus")
			&& checkNode(node, "Skill", "mod");
	}

	/**
	 * 
	 * @param	node
	 * @return
	 */
	public function checkSkillTreeNode(node:Access):Bool {
		return checkSkillNode(node) && checkNode(node, "Skill", "x") && checkNode(node, "Skill", "y") && checkNode(node, "Skill", "name")
			&& checkNode(node, "Skill", "level") && checkNode(node, "Skill", "maxLevel");
	}

	private inline function checkNode(node:Access, entity:String, attribute:String):Bool {
		if (!node.has.resolve(attribute)) {
			Log.error('invalid $entity, attribute missing: $attribute');
			return false;
		}

		return true;
	}
}
