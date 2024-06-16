package gameObject.spells;

import data.DataSpell;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.util.FlxDestroyUtil;
import gameObject.items.ItemScroll.Element;
import global.shared.Log;
import ui.UISpellTooltip;

/**
 * ...
 * @author 13rice
 */
class SpellSkill {
	public var idType(get, null):Int;

	private var _idType:Int = 0;

	/** Reference to the player, null for a template */
	public var player(get, set):Player;

	private var _player:Player = null;

	private var _spellLevels:Array<SpellLevel> = new Array();

	public var spellLevel(get, null):SpellLevel;

	public var nextLevel(get, null):SpellLevel;

	public var level(get, never):Int;

	public var currentLevel(get, never):Int;

	private var _currentLevel:Int = 0;

	public var spellIcon(get, null):SpellIcon;

	private var _spellIcon:SpellIcon = null;

	public var elements(get, null):Array<Element>;

	private var _elements:Array<Element> = [Element.NONE, Element.NONE];

	public var spellIndex(get, set):Int;

	private var _spellIndex:Int = 0;

	/** Tooltip for the spell, on mouse over [Web/PC] / selection [android] */
	public var tooltip(default, null):UISpellTooltip = null;

	private var _name:String = "";

	public function new(id:Int = 0, name:String = "", spellIndex:Int = 0) {
		_idType = id;
		_name = name;
		_spellIndex = spellIndex;
	}

	public function destroy():Void {
		// TODO SpelLLevel destroy
		_spellLevels = null;

		_spellIcon = FlxDestroyUtil.destroy(_spellIcon);

		tooltip = FlxDestroyUtil.destroy(tooltip);

		_elements = null;
	}

	public function addSpellLevel(spellLevel:SpellLevel):SpellLevel {
		_spellLevels[spellLevel.level - 1] = spellLevel;

		return spellLevel;
	}

	public function generateIcon():FlxSprite {
		if (_spellIcon == null)
			_spellIcon = new SpellIcon(0, 0, _spellLevels[_currentLevel]);
		else {
			_spellIcon.spellLevel = _spellLevels[_currentLevel];
		}

		return _spellIcon;
	}

	/**
	 * Not stored in the SpellSkill
	 * @return
	 */
	public function generateBigIcon():FlxSprite {
		var name:String = spellLevel.iconName;

		var sprite:FlxSprite = new FlxSprite();
		sprite.frames = PlayState.get().getAtlas(Constant.ATLAS_UI);
		sprite.animation.frameName = name;

		return sprite;
	}

	public function moveIcon(x:Float, y:Float):Void {
		if (_spellIcon != null) {
			_spellIcon.x = x;
			_spellIcon.y = y;
		}
	}

	/**
		* The spell can be casted:
			- the spell is ready
			- enough mana from the player
	**/
	public function canCastSpell():Bool {
		// Spell not ready
		if (_spellIcon != null && _spellIcon.timer > 0)
			return false;

		return true;
	}
	/**
	 * 
	 * @param	x
	 * @param	y
	 * @param	angle in Degres
	 * @return
	 */
	public function start(x:Float, y:Float, angle:Float, caster:Caster):Spell {
		var spell:Spell = DataSpell.get().getTSpell(spellLevel.spellId);
		spell.start(x, y, spellLevel, angle, caster);
		PlayState.get().addSpell(spell);

		if (_spellIcon != null) {
			_spellIcon.start(caster);
		}

		return spell;
	}

	public function copyTo(clone:SpellSkill = null):SpellSkill {
		if (clone == null) {
			clone = new SpellSkill(_idType, _name, _spellIndex);
		} else {
			clone = cast(clone, SpellSkill);

			clone._idType = _idType;
			clone._name = _name;
			clone._spellIndex = _spellIndex;
		}

		clone._spellLevels = _spellLevels.copy();
		clone._currentLevel = _currentLevel;
		clone._elements = _elements.copy();

		return clone;
	}

	public function overlapsPoint(point:FlxPoint):Bool {
		return _spellIcon.overlapsPoint(point);
	}

	public function isReady():Bool {
		return _spellIcon.timer <= 0;
	}

	/**
	 * Is these three elements are matching with this spell Skill ?
	 * @param	el0 first element
	 * @param	el1 second element
	 * @param	el2 third element
	 */
	public function matchElements(el0:Element, el1:Element, el2:Element) {
		var elements = _elements.copy();

		elements.remove(el0);
		elements.remove(el1);
		elements.remove(el2);

		// If there's no elements remaining, it's a match !
		return elements.length == 0;
	}

	public function onLevelUp():Bool {
		if (!isLevelable())
			return false;

		_currentLevel++;

		return true;
	}

	/**
	 * Can be level up ? ie not at the last level
	 */
	public function isLevelable() {
		return _currentLevel < _spellLevels.length - 1;
	}

	public function upgradable(scrolls:Map<Element, Int>):Bool {
		var result = false;

		if (isLevelable()) {
			// Two identicals
			if (_elements[0] == _elements[1]) {
				result = scrolls[_elements[0]] >= 2;
			} else {
				// all differents
				result = scrolls[_elements[0]] >= 1 && scrolls[_elements[1]] >= 1;
			}
		}

		return result;
	}

	/**
	 * 1, 2 different elements to craft ?
	 * @return count of different elements to craft the Spell
	 */
	public function differentElementCount():Int {
		// Two identicals
		if (_elements[0] == _elements[1]) {
			return 1;
		}
		// all differents
		return 2;
	}

	public function generateTooltip():Void {
		if (tooltip == null) {
			tooltip = new UISpellTooltip(350, 170);
		}

		tooltip.display(this);
	}

	@:noCompletion
	function get_spellLevel():SpellLevel {
		if (_currentLevel < 0 && _currentLevel >= _spellLevels.length) {
			Log.error("Invalid level " + _currentLevel);
			return null;
		}

		return _spellLevels[_currentLevel];
	}

	@:noCompletion
	function get_nextLevel():SpellLevel {
		var nextLevel = _currentLevel + 1;
		if (nextLevel < 0 && nextLevel >= _spellLevels.length) {
			Log.error("Invalid level " + nextLevel);
			return null;
		}

		return _spellLevels[nextLevel];
	}

	@:noCompletion
	function get_spellIndex():Int {
		return _spellIndex;
	}

	@:noCompletion
	function set_spellIndex(value:Int):Int {
		return _spellIndex = value;
	}

	@:noCompletion
	function get_elements():Array<Element> {
		return _elements;
	}

	@:noCompletion
	function get_spellIcon():SpellIcon {
		return _spellIcon;
	}

	@:noCompletion
	function get_idType():Int {
		return _idType;
	}

	@:noCompletion
	function get_currentLevel():Int {
		return _currentLevel;
	}

	@:noCompletion
	function get_level():Int {
		return _currentLevel + 1;
	}

	@:noCompletion
	function get_player():Player {
		return _player;
	}

	@:noCompletion
	function set_player(value:Player):Player {
		return _player = value;
	}
}
