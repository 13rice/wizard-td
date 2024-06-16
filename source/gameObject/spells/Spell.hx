package gameObject.spells;

import data.DataSound;
import effect.Effect;
import motion.Actuate;
import flixel.tweens.FlxTween;
import global.shared.Log;
import global.attribute.AttributeModifier.AttributeType;
import data.DataSpell;
import gameObject.GameObject;
import gameObject.Unit;
import global.buff.BuffBase;
import global.buff.BuffDot;
import global.buff.BuffManager;
import global.buff.BuffPropertyModifier;
import global.buff.BuffSpellOnDeath;
import global.shared.FlxTrailRenderer;
import haxe.ds.Map;
import nape.callbacks.CbType;
import nape.dynamics.InteractionFilter;

/**
 * ...
 * @author 13rice
 */
class Spell extends GameObject {
	public static var CB_SPELL = new CbType();

	public static var INTERACTION_FILTER = new InteractionFilter(GameObject.FRIENDLY_MISSILE, ~GameObject.FRIENDLY_MISSILE, GameObject.FRIENDLY_MISSILE,
		~GameObject.FRIENDLY_MISSILE);

	public var cmlScript(get, set):String;

	private var _cmlScript:String = "";

	public var spellLevel(get, set):SpellLevel;

	private var _spellLevel:SpellLevel = null;

	public var spellCML(get, set):SpellCML;

	private var _spellCML:SpellCML = null;

	public var parent(get, null):Spell;

	private var _parent:Spell = null;

	/** Effect, no collisions */
	public var effect(get, set):Bool;

	private var _effect:Bool = false;

	/** Destroy on collision (true) or piercing bullet (false) */
	public var collide(get, set):Bool;

	private var _collide:Bool = false;

	/** Flip on X axis one frame out of 2 */
	public var flipXAnim(get, set):Bool;

	private var _flipXAnim:Bool = false;

	public var damage(get, set):Float;

	private var _customDamage:Null<Float> = null;

	public var dot(get, set):Bool;

	private var _dot:Bool = false;

	/** Max collision per unit, 0 : infinite**/
	public var maxCollisionCount(get, set):Int;

	private var _maxCollisionCount:Int = 0;

	private var _currentChildFlip:Map<Int /*IdSpel*/, Bool> = null;

	public var buffId(get, set):String;

	private var _buffId:String = null;

	public var buffArgs(get, set):Array<String>;

	private var _buffArgs:Array<String> = null;

	public var buffImage(get, set):String;

	private var _buffImage:String = "";

	/** Collision apply, onDamage is triggered and damage are forced to 0 */
	public var noDamage(get, set):Bool;

	private var _noDamage:Bool = false;

	public var caster(get, set):Caster;

	private var _caster:Caster = null;

	/** Only for parent entity to count collision per unit **/
	private var collisionCount(get, null):Map<GameObject, Int> = null;

	public function new(?X:Float = 0, ?Y:Float = 0) {
		super(X, Y, 0, false, true);
	}

	override public function kill():Void {
		if (hasAnim(GameObject.DEATH_ANIM)) {
			playAnimation(GameObject.DEATH_ANIM, false, true, true, false, 0, function(String) {
				PlayState.get().removeSpell(this);
			}, _sprite.animation.curAnim.flipX);

			if (_sprite != null) {
				_sprite.destroyPhysObjects();
			}
		} else {
			PlayState.get().removeSpell(this);
		}
		// PlayState.get().removeSpell(this);
	}

	override public function destroy():Void {
		if (_spellCML != null) {
			_spellCML.destroy(SpellCML.DEST_STATUS_OUT_OF_SCREEN);
			_spellCML = null;
		}

		_currentChildFlip = null;

		super.destroy();
	}

	override function copyTo(clone:GameObject = null):GameObject {
		var spell:Spell = null;
		if (clone == null) {
			spell = new Spell(0, 0);
		} else {
			spell = cast(clone, Spell);
		}

		spell._cmlScript = _cmlScript;
		spell._spellLevel = _spellLevel;
		spell._hitbox = _hitbox;
		spell._effect = _effect;
		spell._flipXAnim = _flipXAnim;
		spell._sprite.offset.x = _sprite.offset.x;
		spell._sprite.offset.y = _sprite.offset.y;
		spell._collide = _collide;
		spell._buffId = _buffId;
		spell._buffArgs = _buffArgs;
		spell._buffImage = _buffImage;
		spell._customDamage = _customDamage;
		spell._noDamage = _noDamage;
		spell._dot = _dot;
		spell._maxCollisionCount = maxCollisionCount;

		return super.copyTo(spell);
	}

	public function start(x:Float, y:Float, spellLevel:SpellLevel, angle:Float, caster:Caster):Void {
		// Initial position
		this.x = x;
		this.y = y;
		_spellLevel = spellLevel;
		_caster = caster;

		// Root, emitter only
		_sprite.physicsEnabled = false;

		if (_spellCML == null) {
			_spellCML = new SpellCML(this, false, true);
			_spellCML.start(angle);
		}
	}

	public function createChildInstance(x:Float, y:Float, idSpell:Int):Spell {
		var child:Spell = DataSpell.get().getTSpell(idSpell);
		child._parent = this;
		child._spellLevel = _spellLevel;
		child.caster = caster;
		child._customDamage = _customDamage;

		child.launchAnimation(child.frameStart, (_currentChildFlip != null ? _currentChildFlip[idSpell] : false));

		// Flip X child animation
		if (child.flipXAnim) {
			if (_currentChildFlip == null)
				_currentChildFlip = new Map();

			if (!_currentChildFlip.exists(idSpell))
				_currentChildFlip[idSpell] = true;
			else
				_currentChildFlip[idSpell] = !_currentChildFlip[idSpell];
		}

		if (!child._effect) {
			child.createHitbox(Spell.CB_SPELL, Spell.INTERACTION_FILTER);
		} else {
			child._sprite.physicsEnabled = false;
		}

		child.updatePosition(x, y);

		child = PlayState.get().addSpell(child);

		return child;
	}

	/**
		Is this spell will apply damage to the unit ?
	**/
	public function applyDamage(unit:GameObject):Bool {
		if (maxCollisionCount <= 0)
			return true;

		if (parent == null) {
			return !collisionCount.exists(unit) || collisionCount[unit] < maxCollisionCount;
		}
		return parent.applyDamage(unit);
	}

	public function onDamageUnit(unit:Unit):Void {
		if (unit.invulnerable)
			return;

		// Apply spell buff
		if (_buffId != null) {
			var buff:BuffBase = null;

			switch (_buffId) {
				case BuffPropertyModifier.ID:
					buff = new BuffPropertyModifier(spellLevel.name, spellLevel.duration, [_buffArgs[0] => _buffArgs[1]], _buffImage);
				case BuffSpellOnDeath.ID:
					buff = new BuffSpellOnDeath(spellLevel.name, spellLevel.duration, Std.parseInt(_buffArgs[0]), spellLevel, _buffImage, _caster);
				case BuffDot.ID:
					buff = new BuffDot(spellLevel.name, spellLevel.duration, Std.parseFloat(_buffArgs[0]), true, _buffImage);
				default:
			}

			if (buff != null) {
				BuffManager.get().addBuff(unit, buff);
			}
		}

		if (maxCollisionCount > 0)
			addCollision(unit);
	}

	private function addCollision(unit:Unit):Int {
		if (_parent != null)
			return _parent.addCollision(unit);

		if (!collisionCount.exists(unit))
			collisionCount[unit] = 1;
		else
			collisionCount[unit]++;

		return collisionCount[unit];
	}

	function get_spellCML():SpellCML {
		return _spellCML;
	}

	@:noCompletion
	function get_parent():Spell {
		return _parent;
	}

	@:noCompletion
	function set_spellCML(value:SpellCML):SpellCML {
		return _spellCML = value;
	}

	@:noCompletion
	function set_cmlScript(value:String):String {
		if (value.length > 0) {
			// TODO manage mirroring

			// Convert the script in a CannonML sequence
			// Format : #ID {q x, y script};
			_cmlScript = '#M$idType {q$$1 * -1, $$2 * -1 $value};';
		} else {
			_cmlScript = value;
		}

		return _cmlScript;
	}

	@:noCompletion
	function get_cmlScript():String {
		return _cmlScript;
	}

	@:noCompletion
	function get_effect():Bool {
		return _effect;
	}

	@:noCompletion
	function set_effect(value:Bool):Bool {
		return _effect = value;
	}

	@:noCompletion
	function get_spellLevel():SpellLevel {
		return _spellLevel;
	}

	@:noCompletion
	function set_spellLevel(value:SpellLevel):SpellLevel {
		return _spellLevel = value;
	}

	@:noCompletion
	function get_flipXAnim():Bool {
		return _flipXAnim;
	}

	@:noCompletion
	function set_flipXAnim(value:Bool):Bool {
		return _flipXAnim = value;
	}

	@:noCompletion
	function get_collide():Bool {
		return _collide;
	}

	@:noCompletion
	function get_damage():Float {
		if (_noDamage)
			return 0.0;

		return PlayState.get().attributeController.calculateSpellDamage(caster, _customDamage != null ? _customDamage : _spellLevel.damage);
	}

	@:noCompletion
	function set_damage(value:Float):Float {
		return _customDamage = value;
	}

	@:noCompletion
	function set_collide(value:Bool):Bool {
		return _collide = value;
	}

	@:noCompletion
	function get_buffId():String {
		return _buffId;
	}

	@:noCompletion
	function set_buffId(value:String):String {
		return _buffId = value;
	}

	@:noCompletion
	function get_buffArgs():Array<String> {
		return _buffArgs;
	}

	@:noCompletion
	function set_buffArgs(value:Array<String>):Array<String> {
		return _buffArgs = value;
	}

	@:noCompletion
	function get_buffImage():String {
		return _buffImage;
	}

	@:noCompletion
	function set_buffImage(value:String):String {
		return _buffImage = value;
	}

	@:noCompletion
	function get_noDamage():Bool {
		return _noDamage;
	}

	@:noCompletion
	function set_noDamage(value:Bool):Bool {
		return _noDamage = value;
	}

	@:noCompletion
	function get_dot():Bool {
		return _dot;
	}

	@:noCompletion
	function set_dot(value:Bool):Bool {
		return _dot = value;
	}

	@:noCompletion
	function get_maxCollisionCount():Int {
		return _maxCollisionCount;
	}

	@:noCompletion
	function set_maxCollisionCount(value:Int):Int {
		return _maxCollisionCount = value;
	}

	@:noCompletion
	function get_collisionCount():Map<GameObject, Int> {
		if (collisionCount == null)
			collisionCount = new Map<GameObject, Int>();

		return collisionCount;
	}
	@:noCompletion
	function get_caster():Caster {
		return _caster;
	}

	@:noCompletion
	function set_caster(value:Caster):Caster {
		return _caster = value;
	}
}
