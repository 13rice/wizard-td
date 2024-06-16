package gameObject.spells;

import nape.constraint.Constraint;
import global.shared.PointUtils;
import global.shared.Log;
import gameObject.items.ItemScroll.Element;
import flixel.FlxG;
import ui.UISpellSelection;
import openfl.geom.Point;
import flixel.group.FlxGroup;

class CasterController {
	public static var SPELLFRAME_POSITION:Array<Point> = [
		for (j in 0...Constant.GRID_HEIGHT)
			for (i in 0...Constant.GRID_WIDTH)
				new Point(i * Constant.CELL_SIZE + Constant.BASE_GRID_X, j * Constant.CELL_SIZE + Constant.BASE_GRID_Y)
	];

	private var _wizardTowers:Array<Caster> = new Array();

	public var playerCaster(get, null):Caster;

	private var _spellsPosition:Array<SpellSkill> = [for (i in 0...SPELLFRAME_POSITION.length) null];
	private var _castersPosition:Array<Caster> = [for (i in 0...SPELLFRAME_POSITION.length) null];

	public var uiSpellSelection(null, set):UISpellSelection;

	private var _grpCasters:FlxTypedGroup<Caster> = null;

	@:isVar
	public var selectedSpellSkill(default, null):SpellSkill;

	public function new(grpCasters:FlxTypedGroup<Caster>) {
		_grpCasters = grpCasters;
		selectedSpellSkill = null;
	}

	public function init(uiSpellSelection:UISpellSelection) {
		this.uiSpellSelection = uiSpellSelection;
	}

	public function addSpell(spell:SpellSkill) {
		addSpellAtPosition(spell, -1);
	}

	/**
		position : given positin or -1 to fill the next available position
	**/
	public function addSpellAtPosition(spell:SpellSkill, position:Int):Void {
		var caster:Caster = null;
		Log.trace(position);

		if (position < 0) {
			for (i in 0...SPELLFRAME_POSITION.length) {
				if (_spellsPosition[i] != null)
					continue;
				position = i;
			}
		}

		_spellsPosition[position] = spell;

		// Instanciate a new caster for the available position
		caster = new Caster(0, 0, false);
		_wizardTowers[position] = caster;
		_grpCasters.add(_wizardTowers[position]);

		if (caster != null) {
			_spellsPosition[position] = spell;
			_castersPosition[position] = caster;
			updateSpellOfCasterByIndex(position);

			caster.x = SPELLFRAME_POSITION[position].x;
			caster.y = SPELLFRAME_POSITION[position].y;
		} else {
			FlxG.log.error("caster null, error adding spell");
		}
	}

	/**
		Free the slot
	**/
	public function removeSpell(spell:SpellSkill):Int {
		var index = _spellsPosition.indexOf(spell);
		if (index >= 0)
			_spellsPosition[index] = null;

		var position = _spellsPosition.indexOf(spell);
		if (position >= 0)
			_spellsPosition[position] = null;

		return position;
	}

	public function removeSpellAndCaster(spell:SpellSkill) {
		var position = removeSpell(spell);
		var caster = _castersPosition[position];

		_wizardTowers[_wizardTowers.indexOf(caster)] = null;
		_castersPosition[position] = null;

		caster.destroy();
	}

	public function spellCasting(grpEnemies:FlxTypedGroup<Unit>) {
		var state = PlayState.get();

		var xCaster:Float = 0;
		var yCaster:Float = 0;
		var distance:Float = 0;
		var target = null;
		var targetDistance:Float = 9999999;

		for (i in 0...SPELLFRAME_POSITION.length) {
			if (_spellsPosition[i] == null || !_spellsPosition[i].canCastSpell())
				continue;

			xCaster = _wizardTowers[i].x + Constant.CELL_SIZE / 2;
			yCaster = _wizardTowers[i].y + Constant.CELL_SIZE / 2;

			// Find an enemy
			for (enemy in grpEnemies) {
				if (enemy.x > 0 && enemy.alive) {
					distance = PointUtils.sqrDistance(xCaster, yCaster, enemy.x, enemy.y);
					if (distance < (_spellsPosition[i].spellLevel.areaWidth * _spellsPosition[i].spellLevel.areaWidth)
						&& distance < targetDistance) {
						targetDistance = distance;
						target = enemy;
					}
				}
			}
			if (target != null)
				state.spellCasting(target.x, target.y, _spellsPosition[i], _wizardTowers[i]);

			target = null;
			targetDistance = 9999;
		}
	}

	public function selectIndex(index:Int) {
		if (index < 0 || index >= SPELLFRAME_POSITION.length)
			return null;

		selectedSpellSkill = _spellsPosition[index];
		return selectedSpellSkill;
	}

	private function updateSpellOfCasterByIndex(position:Int):Void {
		if (position < 0
			|| position >= _castersPosition.length
			|| _castersPosition[position] == null
			|| _spellsPosition[position] == null)
			return;

		var caster = _castersPosition[position];
		var spell = _spellsPosition[position];

		// Removes elements from previous spell
		caster.clearElementFlags();

		// Adds elements of current spell
		for (element in spell.elements) {
			caster.addFlag(Element.toAttributeFlag(element));
		}
	}

	/**
		Select a spell for manual casting (index 0)
	**/
	public function selectSpellSkill(spellSkill:SpellSkill) {
		// TODO Manual spell casting
		/*for (i in 1..._spellsPosition.length) {
			if (_spellsPosition[i] == spellSkill) {
				_spellsPosition[i] = _spellsPosition[0];
				_spellsPosition[0] = spellSkill;

				var indexPlayerSpell = _spellsPosition.indexOf(_spellsPosition[0]);
				var indexBotSpell = _spellsPosition.indexOf(_spellsPosition[i]);

				switchSpells(indexPlayerSpell, indexBotSpell);

				break;
			}
		}*/
	}

	/**
		Refresh the casters position according to their index
	**/
	private function refreshCasterPosition() {
		for (i in 0..._castersPosition.length) {
			if (_castersPosition[i] == null)
				continue;

			_castersPosition[i].x = SPELLFRAME_POSITION[i].x;
			_castersPosition[i].y = SPELLFRAME_POSITION[i].y;
		}
	}

	@:noCompletion
	function get_playerCaster():Caster {
		return _wizardTowers[0];
	}

	@noCompletion
	function set_uiSpellSelection(value:UISpellSelection):UISpellSelection {
		return uiSpellSelection = value;
	}
}