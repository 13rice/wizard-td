package global.buff;

import gameObject.spells.Caster;
import data.DataSpell;
import flixel.FlxSprite;
import gameObject.Unit;
import gameObject.spells.Spell;
import gameObject.spells.SpellLevel;

/**
 * ...
 * @author 
 */
class BuffSpellOnDeath extends BuffBase {
	public inline static var ID = "SPELL_DEATH";

	private var _lastTargetX:Float = 0;
	private var _lastTargetY:Float = 0;

	private var _spellId:Int = 0;

	private var _spellLevel:SpellLevel = null;

	private var _caster:Caster = null;

	public function new(name:String, duration:Float, spellId:Int, spellLevel:SpellLevel, iconName:String, caster:Caster) {
		super(name);

		_iconName = iconName;
		_duration = duration;
		_spellId = spellId;
		_spellLevel = spellLevel;
		_caster = caster;
	}

	override public function applyTo(target:Unit):Bool {
		super.applyTo(target);

		if (target != null) {
			_lastTargetX = target.x;
			_lastTargetY = target.y;
		}

		// Buff effect
		if (_iconName != "" && _icon == null) {
			_icon = new FlxSprite(-6, -12);
			_icon.frames = PlayState.get().getAtlas(Constant.ATLAS_FX);
			_icon.animation.addByPrefix("idle", _iconName, 8);
			_icon.animation.play("idle");
		}

		// Place the buff in the lower right corner
		if (_target.enemy) {
			// Place the buff on the unit
			_target.add(_icon);
		}

		return true;
	}

	override public function frameMove(elapsedTime:Float):Bool {
		if (_target == null || !_target.alive) {
			var spell:Spell = DataSpell.get().getTSpell(_spellId, true);
			spell.start(_lastTargetX, _lastTargetY, _spellLevel, 0, _caster);
			PlayState.get().addSpell(spell);

			return true;
		} else {
			_lastTargetX = _target.x;
			_lastTargetY = _target.y;
		}

		return _duration <= 0;
	}
}
