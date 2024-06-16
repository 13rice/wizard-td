package gameObject.spells;

import global.attribute.AttributeModifier.AttributeType;
import data.DataSpell;
import global.shared.Log;
import global.shared.MathUtils;
import nape.shape.Circle;
import org.si.cml.CMLFiber;
import org.si.cml.CMLObject;

/**
 * ...
 * @author 13rice
 */
class SpellCML extends CMLObject {
	public static inline var DEST_STATUS_OUT_OF_SCREEN = 0;
	public static inline var DEST_STATUS_FROM_CML = 2;

	/**
	 * Spell linked to the SpellCML
	 */
	public var owner(get, set):Spell;

	private var _owner:Spell = null;

	private var _cmlSequenceID:String;

	public var started(get, null):Bool;

	private var _started:Bool = false;

	private var _startAngle:Float = 0;

	/**
	 * arme inversé par rapport à l'axe Y
	 */
	private var _mirrorY:Bool;

	public var fiber(get, null):CMLFiber;

	private var _fiber:CMLFiber = null;

	/**
	 * Add a new Bullet scripted with CannonML
	 * - For the first Bullet associated with the unit, the bullet must be attached to the weapon and the unit
	 * - For bullets created from other bullets, the bullet must be attached to the missile and has no weapon
	 * @param	owner, link to a Spell
	 * @param	tmissile type of missile to fire
	 * @param	mirrorY inverted ?
	 * @param	weapon null if from another bullet
	 */
	public function new(owner:Spell, mirrorY:Bool, root:Bool) {
		super();

		// Owner is mandatory
		if (owner != null) {
			_owner = owner;

			// Root, bullet as a scripted weapon
			if (root) {
				// Sequence to execute
				_cmlSequenceID = "M" + owner.idType;

				create(_owner.x, _owner.y);
			} else {
				// Link the spellCML to the spell
				_owner.spellCML = this;
			}
		} else
			Log.error("Owner null");
	}

	/**
	 * Setting the owner position and rotation
	 */
	override public function onCreate():Void {
		_owner.angle = angle * MathUtils.DEG_TO_RAD;

		_owner.updatePosition(x, y);
	}

	/**
	 * // Refresh the owner position and rotation
	 */
	override public function onUpdate():Void {
		if (_owner._sprite.body != null)
			_owner._sprite.body.rotation = angle * MathUtils.DEG_TO_RAD;
		else
			_owner.angle = angle;

		_owner.updatePosition(x, y);
	}

	override public function onDestroy():Void {
		// Destroy the bullet with the projectile, for fragmentation bomb or whatever => use ko2
		if (_destructionStatus >= 2) {
			// Explosion
			/*
				if (_destructionStatus == 3)
					missile.explosionOnDestroy();
			 */

			_owner.kill();
		}

		_owner = null;
	}

	/**
	 * for new object created by "f" command
	 * Args can contain an ID to a different missile type from the original missile type. Used for fragmentations
	 * @param	args from the sequence, Spell ID
	 * @return
	 */
	override public function onFireObject(args:Array<Dynamic>):CMLObject {
		var spellCML:SpellCML = null;
		var spellId:Int = _owner.idType;
		var spell:Spell = null;

		if (_owner != null) {
			if (args.length > 0 && spellId != args[0]) {
				if (DataSpell.get().isTSpellExists(args[0])) {
					spellId = args[0];
				} else {
					// In case of error, keep the source ID
					Log.error('unknown ID : ${args[0]}, setting default spell type');
				}
			}

			// TODO apply damage multiplier for fragment element
			// var layer:Sprite = (_owner.enemy ? Game.get().gameLayer : Game.get().playerBulletLayer);
			// missile = tMissileFire.createMissile(layer, _owner, x, y, angle, (_weapon != null ? _weapon.offset : null), _mirrorY, 0, (_weapon != null ? _weapon.damageMultiplier : 1));
			spell = _owner.createChildInstance(x, y, spellId);

			// A missile can be null if the creation failed, outside of the gaming area for example
			if (spell != null) {
				// Hotfix for the player...
				if (!_owner.enemy && _fiber != null) {
					_fiber.target = PlayState.get().targetForPlayer;
				}
				spellCML = new SpellCML(spell, _mirrorY, false);

				// Keep same start angle for the child
				spellCML._startAngle = _startAngle;
			}
		}

		return spellCML;
	}

	public function start(startAngle:Float = 0):Void {
		if (!_started) {
			_started = true;
			_startAngle = startAngle;
			_fiber = execute(PlayState.get().cmlScript.childSequence[_cmlSequenceID], null, (_mirrorY ? 1 : 0));

			if (_fiber != null) {
				if (!_owner.enemy) {
					_fiber.target = PlayState.get().targetForPlayer;
				}
			} else
				Log.error("Sequence ID not found : " + _cmlSequenceID);
		} else {
			Log.warn('Bullet already started : $_cmlSequenceID');
		}
	}

	public static function rangeCML(fbr:CMLFiber):Float {
		var spellCML:SpellCML = spellFromFiber(fbr);

		var rangeFactor = PlayState.get().attributeController.calculateValue(AttributeType.SPELL_AOE, spellCML.owner.caster.flags, 1);
		return spellCML.owner.spellLevel.range * rangeFactor;
	}

	public static function heightRangeCML(fbr:CMLFiber):Float {
		var spellCML:SpellCML = spellFromFiber(fbr);

		return spellCML.owner.spellLevel.height;
	}

	public static function durationCML(fbr:CMLFiber):Float {
		var spellCML:SpellCML = spellFromFiber(fbr);

		var durationFactor = PlayState.get().attributeController.calculateValue(AttributeType.SPELL_DURATION, spellCML.owner.caster.flags, 1);
		return spellCML.owner.spellLevel.duration * durationFactor;
	}

	public static function angleCML(fbr:CMLFiber):Float {
		var spellCML:SpellCML = spellFromFiber(fbr);

		return spellCML._startAngle;
	}

	public static function levelCML(fbr:CMLFiber):Float {
		var spellCML:SpellCML = spellFromFiber(fbr);

		return spellCML.owner.spellLevel.level;
	}

	public static function casterXCML(fbr:CMLFiber):Float {
		var spellCML:SpellCML = spellFromFiber(fbr);

		return spellCML.owner.caster.x + 16;
	}

	public static function casterYCML(fbr:CMLFiber):Float {
		var spellCML:SpellCML = spellFromFiber(fbr);

		return spellCML.owner.caster.y + 16;
	}

	public static function scaleCML(fbr:CMLFiber, args:Array<Dynamic>):Void {
		var spell:Spell = spellFromFiber(fbr).owner;

		if (spell != null && spell.scale != null) {
			if (Math.isNaN(args[1])) {
				spell.scale.x = spell.scale.y = args[0];
			} else {
				spell.scale.x = args[0];
				spell.scale.y = args[1];
			}
		} else {
			Log.trace("spell or scale null");
		}
	}

	/**
	 * Modify the radius of the hitbox trough CML script.
	 * /!\ The hitbox MUST BE a CIRCLE shape
	 * @param	fbr
	 * @param	args
	 */
	static public function hitboxRadiusCML(fbr:CMLFiber, args:Array<Dynamic>):Void {
		var spell:Spell = spellFromFiber(fbr).owner;

		if (!Math.isNaN(args[0])) {
			cast(spell._sprite.body.shapes.at(0), Circle).radius = args[0];
		} else {
			Log.error("Missing parameter");
		}
	}

	public static inline function spellFromFiber(fbr:CMLFiber):SpellCML {
		return cast(fbr.object, SpellCML);
	}

	@:noCompletion
	function get_owner():Spell {
		return _owner;
	}

	@:noCompletion
	function set_owner(value:Spell):Spell {
		return _owner = value;
	}

	@:noCompletion
	function get_started():Bool {
		return _started;
	}

	@:noCompletion
	function get_fiber():CMLFiber {
		return _fiber;
	}
}
