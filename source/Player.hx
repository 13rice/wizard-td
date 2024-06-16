package;

import effect.Effect;
import global.shared.Log;
import data.DataSound;
import gameObject.GameObject;
import global.Trigger;
import global.attribute.AttributeFlag;
import global.attribute.AttributeModifier;
import gameObject.spells.CasterController;
import data.DataSpell;
import flixel.FlxG;
import gameObject.Unit;
import gameObject.items.ItemScroll.Element;
import gameObject.spells.SpellSkill;

/**
 * ...
 * @author 13rice
 */
class Player {
	public var scrolls(get, null):Map<Element, Int>;

	private var _scrolls:Map<Element, Int> = null;

	public var spells(get, null):Map<Int, SpellSkill>;

	private var _spells:Map<Int, SpellSkill> = null;

	public var spellBuffered(get, null):SpellSkill;

	private var _spellBuffered:SpellSkill = null;

	public var lifeMax(get, null):Float;

	private var _lifeMax:Float = 20;

	public var life(get, null):Float;

	private var _life:Float = 20;

	private var _defense:Float = 1.0;

	private static var _player:Player = new Player();

	private var _casterController:CasterController;

	public static function get():Player {
		return _player;
	}

	private function new() {}

	public function onNewLevel(casterController:CasterController):Void {
		_casterController = casterController;
		_lifeMax = PlayState.get().attributeController.calculateValue(AttributeType.FORTRESS_LIFE, AttributeFlag.PLAYER, _lifeMax);
		_life = _lifeMax;
		_spells = new Map();

		
		_scrolls = [
			Element.FIRE => Constant.DEFAULT_SCROLLS,
			Element.METAL => Constant.DEFAULT_SCROLLS,
			Element.WATER => Constant.DEFAULT_SCROLLS
		];

		/*_scrolls = [
			Element.FIRE => 0,
			Element.METAL => 0,
			Element.WATER => 0
		];*/
		Trigger.UNIT_KILLED.add(onUnitKilled);
	}

	/**
		@return true if the element is added, false otherwise
	**/
	public function onAddElement(element:Element):Bool {
		_scrolls[element]++;

		return true;
	}

	public function onAddSpell(spellSkill:SpellSkill):Bool {
		spellSkill.player = this;

		_spells[spellSkill.idType] = spellSkill;

		spellSkill.generateTooltip();

		for (element in spellSkill.elements) {
			_scrolls[element]--;
		}

		return true;
	}

	public function initializeFirstSpell(element:Element):SpellSkill {
		var spellID = Constant.SPELL_BASE_FIRE_ID;

		switch (element) {
			case FIRE:
				spellID = Constant.SPELL_BASE_FIRE_ID;
			case METAL:
				spellID = Constant.SPELL_BASE_METAL_ID;
			case WATER:
				spellID = Constant.SPELL_BASE_WATER_ID;
			case NONE:
				Log.error('Element must be different from NONE');
		}

		var spellSkill = DataSpell.get().getTSpellSkill(spellID);
		_casterController.addSpellAtPosition(spellSkill, Constant.FIRST_POSITION);

		return spellSkill;
	}

	public function hasSpellFromElement(el0:Element, el1:Element, el2:Element):Bool {
		return spellFromElement(el0, el1, el2) != null;
	}

	public function spellFromElement(el0:Element, el1:Element, el2:Element):SpellSkill {
		for (spell in _spells) {
			if (spell.matchElements(el0, el1, el2)) {
				return spell;
			}
		}

		return null;
	}
	
	public function onLevelUpSpell(spellSkill:SpellSkill) {
		spellSkill.generateTooltip();

		for (element in spellSkill.elements) {
			_scrolls[element]--;
		}
	}

	public function onRemoveSpell(spellSkill:SpellSkill):Void {
		if (spellSkill == null)
			return;

		if (_spells.exists(spellSkill.idType)) {
			_spells.remove(spellSkill.idType);
		} else {
			FlxG.log.error("Player doesn't have spell : " + spellSkill.idType);
		}
	}

	/**
		Event end of a level
		* Reset scrolls
		* Reset Spells
	**/
	public function onEndLevel() {
		_scrolls = [
			Element.FIRE => 0,
			Element.METAL => 0,
			Element.WATER => 0
		];

		_spells = null;
	}

	/**
		Event end of a wave
		* Regeneration
	**/
	public function onEndWave():Void {
		_life += PlayState.get().attributeController.calculateValue(AttributeType.FORTRESS_REGEN, AttributeFlag.PLAYER, 0);
		_life = Math.min(_life, _lifeMax);
	}

	public function dealDamage(damage:Float):Bool {
		var fortressDefense = PlayState.get().attributeController.calculateValue(AttributeType.FORTRESS_DEFENSE, AttributeFlag.PLAYER, _defense);
		_life -= damage * fortressDefense;
		_life = Math.max(_life, 0);

		return _life <= 0;
	}

	public function revive():Void {
		var lifeFactor = PlayState.get().attributeController.calculateValue(AttributeType.REVIVE, AttributeFlag.PLAYER, 0);
		_life = _lifeMax * lifeFactor;
	}

	public function flushBufferedSpell() {
		_spellBuffered = null;
	}

	private function onUnitKilled(killed:Unit, killer:GameObject):Void {
		if (killer != _casterController.playerCaster)
			return;

		// Noting to do, so far...
	}

	/**
		Adds life to the player, the amount can't exceed player max life
	**/
	private function addLife(life:Float):Void {
		_life += life;
		_life = Math.min(_life, _lifeMax);
	}

	@:noCompletion
	function get_spells():Map<Int, SpellSkill> {
		return _spells;
	}

	@:noCompletion
	function get_spellBuffered():SpellSkill {
		return _spellBuffered;
	}

	@:noCompletion
	function get_scrolls():Map<Element, Int> {
		return _scrolls;
	}

	@:noCompletion
	function get_life():Float {
		return _life;
	}

	@:noCompletion
	function get_lifeMax():Float {
		return _lifeMax;
	}
}
