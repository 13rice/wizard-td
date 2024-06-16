package gameObject;

import global.attribute.AttributeModifier.AttributeType;
import global.attribute.AttributeFlag;
import gameObject.attacks.DamageFlag;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxColor;
import gameObject.spells.Spell;
import global.shared.Hitbox;
import global.shared.Log;
import nape.callbacks.CbType;
import nape.dynamics.InteractionFilter;
import nape.phys.BodyType;
import openfl.display.Sprite;
import openfl.geom.ColorTransform;
import openfl.geom.Point;

// import global.buff.BuffBase;

/**
 * ...
 * @author 13rice
 */
class GameObject extends FlxSpriteGroup {
	public static var CB_ENEMY = new CbType();

	public static inline var FRIENDLY_MISSILE = 1 << 0;
	public static inline var FRIENDLY_UNIT = 1 << 1;
	public static inline var ENEMY_MISSILE = 1 << 2;
	public static inline var ENEMY_UNIT = 1 << 3;
	public static inline var FRIENDLY_BONUS = 1 << 4;
	public static inline var DOODAD = 1 << 5;
	public static inline var SPELL_AOE = 1 << 6;

	public static inline var LIMIT_INVU = 999999;

	public static inline var BIRTH_ANIM:String = "birth_";
	public static inline var DEATH_ANIM:String = "death_";
	public static inline var IDLE_ANIM:String = "idle_";

	public var idType:Int = 0;

	public var targetable(get, set):Bool;

	private var _targetable:Bool;

	public var invulnerable(get, set):Bool;

	private var _invulnerable:Bool;

	public var hitPoints(get, set):Float;

	private var _hitPoints:Float;

	public var totalHitPoints(default, null):Float;

	public var enable(get, set):Bool;

	private var _enable:Bool;
	private var _whiteMask:Bool;
	private var _removeWhiteMask:Int;
	private var _switchWhiteMask:Bool;

	public var speed(get, set):Float;

	private var _speed:Float;

	/** Paused if > 0 */
	private var _pauseMovement:Int;

	/** Paused if > 0 */
	private var _pauseFire:Int;

	public var baseWidth(get, null):Float;

	private var _baseWidth:Float = 0;

	public var baseHeight(get, null):Float;

	private var _baseHeight:Float = 0;

	/**
	 * Ally (false), or Enemy (true)
	 */
	public var enemy(get, set):Bool;

	private var _enemy:Bool;

	/**
	 * /!\ Pour une utilisation locale uniquement /!\
	 */
	private var _localPoint:Point;

	/**
	 * Pour relier l'élément à un autre (ex: missile à une cible)
	 */
	private var _lAttachTo:Array<GameObject>;

	/**
	 * Liste d'éléments rattachés à celui-ci, prévenir les éléments de la liste de la suppression de l'élément courant
	 */
	private var _lAttachFrom:Array<GameObject>;

	/** Graphics ============== */
	public var isAnimation:Bool = false;

	/** For simple graphic */
	public var frameName:String = "";

	public var atlasName(get, set):String;

	private var _atlasName:String = "";

	private var _atlas:FlxAtlasFrames = null;

	/** For animation only */
	@:isVar
	public var animationPrefix(get, set):String = "";

	/** For animation only */
	@:isVar
	public var fps(get, set):Int = 0;

	/** For animation only */
	@:isVar
	public var loop(get, set):Bool = true;

	/** Custom origin for rotation, must be set, centered otherwise */
	public var customOrigin(get, set):FlxPoint;

	private var _customOrigin:FlxPoint = null;

	/**
	 * First frame played for animation (-1 : random)
	 * Ignored if birth animation
	 * ⚠ For animation only
	 */
	public var frameStart(get, set):Int;

	private var _frameStart:Int = 0;

	/** Core sprite displayed */
	public var _sprite:GameSprite = null;

	/** Shared */
	public var hitbox(get, set):Hitbox;

	private var _hitbox:Hitbox = null;

	/** ape physics body type */
	public var bodyType(get, set):BodyType;

	private var _bodyType:BodyType = BodyType.KINEMATIC;

	/**
	 * Buffs
	 */
	// private var _lBuffs:Array<BuffBase>;

	/**
	 * Sound identifier on destroy
	 */
	public var soundDestroy(get, set):String;

	private var _soundDestroy:String;

	public function new(?x:Float = 0, ?y:Float = 0, ?hitPoints:Float = 0, createRectangularBody:Bool = true, enablePhysics:Bool = true) {
		super(x, y);

		_sprite = new GameSprite(this, 0, 0, null, createRectangularBody, enablePhysics);

		_targetable = false;
		_invulnerable = false;
		_hitPoints = hitPoints;
		totalHitPoints = hitPoints;
		_enable = true;
		_whiteMask = false;
		_removeWhiteMask = 0;
		_switchWhiteMask = false;
		_localPoint = new Point();
		_speed = 0.0;
		_soundDestroy = "";
		_pauseMovement = 0;
		_pauseFire = 0;

		_lAttachTo = null;
		_lAttachFrom = null;

		if (_hitPoints == 0.0)
			_targetable = false;
		else {
			_targetable = true;
			if (_hitPoints >= LIMIT_INVU) {
				_invulnerable = true;
			}
		}
	}

	override public function destroy():Void {
		if (_customOrigin != null) {
			_customOrigin.put();
			_customOrigin = null;
		}

		if (_sprite != null) {
			_sprite.destroyPhysObjects();
		}

		moves = false;

		super.destroy();
	}

	override public function update(elapsed:Float):Void {
		if (group != null)
			super.update(elapsed);

		// Remove white mask after damage
		if (_whiteMask && _removeWhiteMask == 0) {
			disableWhiteMask();
		} else if (_removeWhiteMask > 0) {
			// Skip x frames
			_removeWhiteMask--;
		}
	}

	/**
	 * After creating the GameObject try to enqueue birth / idle animations
	 */
	public function launchAnimation(frameIndex:Int = 0, flipX:Bool = false):Void {
		if (!isAnimation)
			initGraphics();
		else {
			initAtlas();

			if (hasAnim(BIRTH_ANIM))
				playAnimation(BIRTH_ANIM, false, true, false, false, 0, enqueueIdleAnimation, flipX);
			else
				playAnimation(IDLE_ANIM, loop, hasAnim(GameObject.IDLE_ANIM), false, false, frameIndex, flipX);
		}
	}

	public function playAnimation(name:String, loopAnim:Bool, addNameToPrefix:Bool = false, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0,
			callback:String->Void = null, flipX:Bool = false):Void {
		initAtlas();

		if (addNameToPrefix) {
			// To play a specific animation (birth, death etc.)
			_sprite.animation.addByPrefix(name, animationPrefix + name, fps, loopAnim, flipX);
		} else {
			// Single animation
			_sprite.animation.addByPrefix(name, animationPrefix, fps, loopAnim, flipX);
		}

		_sprite.animation.play(name, Force, Reversed, Frame);

		if (callback != null)
			_sprite.animation.finishCallback = callback;
		else if (!loopAnim)
			_sprite.animation.finishCallback = endAnimation;

		// Keep previous Offset
		var offsetX = _sprite.offset.x;
		var offsetY = _sprite.offset.y;

		// Update width / height, origin and offset
		_sprite.updateHitbox();

		// Preserve previous custom offset
		_sprite.offset.x = offsetX;
		_sprite.offset.y = offsetY;

		if (_customOrigin != null) {
			_sprite.origin.x = _customOrigin.x;
			_sprite.origin.y = _customOrigin.y;
		}

		// Don't add it twice
		if (members.indexOf(_sprite) < 0)
			add(_sprite);
	}

	public function updatePosition(x:Float, y:Float):Void {
		this.x = x;
		this.y = y;

		if (_sprite.body != null)
			_sprite.setPosition(x, y);
		else {
			// Bypass "body" positionning
			_sprite.x = x - _sprite.origin.x;
			_sprite.y = y - _sprite.origin.y;
		}
	}

	private function endAnimation(name:String):Void {
		alpha = 0;
	}

	public function enqueueIdleAnimation(name:String):Void {
		playAnimation(IDLE_ANIM, loop, true, false, false, 0, null, _sprite.animation.curAnim.flipX);
	}

	public function hasAnim(anim:String):Bool {
		var result:Bool = false;

		if (_atlas != null) {
			for (frame in _atlas.frames) {
				if (frame.name != null && StringTools.startsWith(frame.name, animationPrefix + anim)) {
					result = true;
					break;
				}
			}
		}

		return result;
	}

	/**
	 * For single sprite non animated
	 * Use playAnimation for Animation
	 * frameName must be set before calling this method
	 */
	public function initGraphics():Void {
		initAtlas();

		_sprite.animation.frameName = frameName;
		_sprite.resetSizeFromFrame();

		// Keep previous Offset
		var offsetX = _sprite.offset.x;
		var offsetY = _sprite.offset.y;

		// Update width / height, origin and offset
		_sprite.updateHitbox();

		// Preserve previous custom offset
		_sprite.offset.x = offsetX;
		_sprite.offset.y = offsetY;

		if (_customOrigin != null) {
			origin.x = _customOrigin.x;
			origin.y = _customOrigin.y;
		}

		add(_sprite);
	}

	private function initAtlas():Void {
		if (_atlasName == "") {
			Log.error("No atlas defined");
			return;
		}

		if (_atlas == null) {
			_atlas = PlayState.get().getAtlas(_atlasName);

			if (_atlas == null) {
				Log.error("Play animation impossible");
				return;
			}
		}

		_sprite.frames = _atlas;
	}

	/**
	 * Initialize the hitbox with the physics engine (Nape)
	 */
	public function createHitbox(cbType:CbType, filter:InteractionFilter) {
		if (_hitbox == null) {
			Log.error("No hit box defined");
			return;
		}

		_hitbox.createBody(_sprite, _bodyType);
		_sprite.body.setShapeFilters(filter);
		_sprite.body.cbTypes.add(cbType);
	}

	/**
	 * Supported with core sprite
	 * @return this sprite group
	 */
	override public function loadGraphicFromSprite(Sprite:FlxSprite):FlxSprite {
		return _sprite.loadGraphicFromSprite(Sprite);
	}

	/**
	 * Supported with core sprite
	 */
	override public function loadGraphic(Graphic:FlxGraphicAsset, Animated:Bool = false, Width:Int = 0, Height:Int = 0, Unique:Bool = false,
			?Key:String):FlxSprite {
		return _sprite.loadGraphic(Graphic, Animated, Width, Height, Unique, Key);
	}

	/**
	 * This functionality isn't supported in SpriteGroup
	 * @return this sprite group
	 */
	override public function loadRotatedGraphic(Graphic:FlxGraphicAsset, Rotations:Int = 16, Frame:Int = -1, AntiAliasing:Bool = false,
			AutoBuffer:Bool = false, ?Key:String):FlxSprite {
		return _sprite.loadRotatedGraphic(Graphic, Rotations, Frame, AntiAliasing, AutoBuffer, Key);
	}

	/**
	 * This functionality isn't supported in SpriteGroup
	 * @return this sprite group
	 */
	override public function makeGraphic(Width:Int, Height:Int, Color:Int = FlxColor.WHITE, Unique:Bool = false, ?Key:String):FlxSprite {
		return _sprite.makeGraphic(Width, Height, Color, Unique, Key);
	}

	public function copyTo(clone:GameObject = null):GameObject {
		if (clone == null) {
			clone = new GameObject();
		}

		// Clone FlxTypedSpriteGroup attributes
		clone.x = x;
		clone.y = y;
		clone.maxSize = maxSize;

		for (sprite in group.members) {
			if (sprite != null) {
				clone.add(cast sprite.clone());
			}
		}

		// Clone GameObject attributes
		clone.atlasName = atlasName;
		clone.idType = idType;
		clone._targetable = _targetable;
		clone._invulnerable = _invulnerable;
		clone._hitPoints = _hitPoints;
		clone.totalHitPoints = totalHitPoints;
		clone._enable = _enable;
		clone._speed = _speed;
		clone._pauseMovement = _pauseMovement;
		clone._pauseFire = _pauseFire;
		clone._baseWidth = _baseWidth;
		clone._baseHeight = _baseHeight;
		clone._enemy = _enemy;
		clone._localPoint = _localPoint.clone();
		clone.isAnimation = isAnimation;
		clone.frameName = frameName;
		clone._atlas = _atlas;
		clone.animationPrefix = animationPrefix;
		clone.fps = fps;
		clone.loop = loop;
		clone.frameStart = frameStart;
		clone._customOrigin = (_customOrigin != null ? FlxPoint.get(_customOrigin.x, _customOrigin.y) : null);

		return clone;
	}

	/**
	 * Add a white mask
	 */
	public function enableWhiteMask():Void {
		if (!_whiteMask) {
			// Masque blanc
			_whiteMask = true;
			_sprite.setColorTransform(2, 2, 2, 1, 150, 150, 150);

			// Skip x frames
			_removeWhiteMask = 4;
		}
	}

	/**
	 * Restore default color
	 */
	public function disableWhiteMask():Void {
		if (_whiteMask) {
			_whiteMask = false;
			_sprite.setColorTransform(1, 1, 1, 1);
		}
	}

	////////////////////////////////////////////////////////////////
	///	BASICS
	////////////////////////////////////////////////////////////////

	/**
	 * Damage from spell source to the gameObject
	 * @param	damange amount
	 * @return true if dead (hp <= 0), false otherwise
	 */
	public function dealDamageFromSpell(spell:Spell, source:GameObject, mask:Bool = true):Bool {
		var damage:Float = 0;

		switch (spell.spellLevel.damageType) {
			case DMG_TYPE_NORMAL:
				damage = spell.damage;
			case DMG_TYPE_PERCENT_CURRENT:
				damage = (spell.damage / 100) * _hitPoints;
			case DMG_TYPE_PERCENT_MAX:
				damage = (spell.damage / 100) * totalHitPoints;
		}

		return dealDamage(damage, source, DamageFlag.SPELL, spell.caster.flags, mask);
	}

	public function dealDamage(damage:Float, source:GameObject, flag:DamageFlag, sourceFlag:AttributeFlag, mask:Bool = true):Bool {
		_hitPoints -= damage;

		if (mask)
			enableWhiteMask();

		return _hitPoints <= 0.0;
	}

	////////////////////////////////////////////////////////////////
	///	GETTERS / SETTERS
	////////////////////////////////////////////////////////////////
	public function isEnable(?obj:GameObject = null):Bool {
		return _enable;
	}

	public function setEnable(b:Bool):Void {
		_enable = b;
	}

	public function getHitPoints():Float {
		return _hitPoints;
	}

	private function get_speed():Float {
		return _speed;
	}

	private function set_speed(value:Float):Float {
		return _speed = value;
	}

	/** Only the player returns true */
	public function isPlayer():Bool {
		return false;
	}

	@:noCompletion
	function get_soundDestroy():String {
		return _soundDestroy;
	}

	@:noCompletion
	function set_soundDestroy(value:String):String {
		return _soundDestroy = value;
	}

	@:noCompletion
	function get_hitPoints():Float {
		return _hitPoints;
	}

	@:noCompletion
	function set_hitPoints(value:Float):Float {
		return _hitPoints = value;
	}

	@:noCompletion
	function get_enemy():Bool {
		return _enemy;
	}

	@:noCompletion
	function set_enemy(value:Bool):Bool {
		return _enemy = value;
	}

	@:noCompletion
	function get_targetable():Bool {
		return _targetable;
	}

	@:noCompletion
	function set_targetable(value:Bool):Bool {
		return _targetable = value;
	}

	@:noCompletion
	function get_invulnerable():Bool {
		return _invulnerable;
	}

	@:noCompletion
	function set_invulnerable(value:Bool):Bool {
		return _invulnerable = value;
	}

	@:noCompletion
	function get_baseWidth():Float {
		return _baseWidth;
	}

	@:noCompletion
	function get_baseHeight():Float {
		return _baseHeight;
	}

	@:noCompletion
	function get_enable():Bool {
		return isEnable();
	}

	@:noCompletion
	function set_enable(value:Bool):Bool {
		return _enable = value;
	}

	@:noCompletion
	function get_animationPrefix():String {
		return animationPrefix;
	}

	@:noCompletion
	function set_animationPrefix(value:String):String {
		return animationPrefix = value;
	}

	@:noCompletion
	function get_atlasName():String {
		return _atlasName;
	}

	@:noCompletion
	function set_atlasName(value:String):String {
		return _atlasName = value;
	}

	@:noCompletion
	function get_fps():Int {
		return fps;
	}

	@:noCompletion
	function set_fps(value:Int):Int {
		return fps = value;
	}

	@:noCompletion
	function get_hitbox():Hitbox {
		return _hitbox;
	}

	@:noCompletion
	function set_hitbox(value:Hitbox):Hitbox {
		return _hitbox = value;
	}

	@:noCompletion
	function get_loop():Bool {
		return loop;
	}

	@:noCompletion
	function set_loop(value:Bool):Bool {
		return loop = value;
	}

	@:noCompletion
	function get_frameStart():Int {
		return _frameStart;
	}

	@:noCompletion
	function set_frameStart(value:Int):Int {
		return _frameStart = value;
	}

	@:noCompletion
	function get_bodyType():BodyType {
		return _bodyType;
	}

	@:noCompletion
	function set_customOrigin(value:FlxPoint):FlxPoint {
		return _customOrigin = value;
	}

	@:noCompletion
	function get_customOrigin():FlxPoint {
		return _customOrigin;
	}

	@:noCompletion
	function set_bodyType(value:BodyType):BodyType {
		return _bodyType = value;
	}
}
