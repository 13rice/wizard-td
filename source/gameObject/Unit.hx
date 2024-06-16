package gameObject;

// import global.buff.Ability;
import global.DamageText;
import effect.Effect;
import global.attribute.AttributeFlag;
import global.attribute.AttributeModifier.AttributeType;
import flixel.util.FlxDirectionFlags;
import data.DataUnit;
import flixel.FlxG;
import flixel.FlxObject;
import gameObject.fortress.Wall;
import global.shared.Log;
import global.shared.MathUtils;
import haxe.xml.Access;
import gameObject.attacks.DamageFlag;
import nape.dynamics.InteractionFilter;
import nape.phys.BodyType;

enum UnitAction {
	WALK;
	ATTACK;
	DEATH;
	HIT;
	STUN;
	IDLE;
	VICTORY;
}

/**
 * ...
 * @author 13rice
 */
@:keepSub // for BUFF attributes
class Unit extends GameObject {
	public static inline var START_ID_UNIT:Int = 4000000;
	public static inline var START_ID_WAVE:Int = 5000000;

	public static var BLOOD_ANIM:Array<String> = ["bloodhit_", "BloodSharp_"];
	public static var INTERACTION_FILTER = new InteractionFilter(GameObject.ENEMY_UNIT, ~GameObject.ENEMY_UNIT, GameObject.ENEMY_UNIT, ~GameObject.ENEMY_UNIT);

	public var scoreValue(get, set):Int;

	private var _scoreValue:Int;

	/** For insert sprite on top : after index, or bottom layer : before index */
	public var spriteIndex(get, never):Int;

	private var _spriteIndex:Int = 0;

	/** Properties ======================= */
	/** Damage multiplier of weapon > 0 */
	public var damageMultiplier(get, set):Float;

	private var _damageMultiplier:Float = 1;

	/** Damage factor, between 0 and 1*/
	public var damageFactor(get, set):Float;

	private var _damageFactor:Float = 1;

	/** hit point regeneration (can be negative) */
	public var hpRegeneration(get, set):Float;

	private var _hpRegeneration:Float = 0;

	/** speed factor of CML unit generation and movement */
	public var cmlSlowFactor(get, set):Int;

	private var _timer:Int = 0;

	private var _action:UnitAction = WALK;

	/** Must be > 6 */
	private var _attackSpeed:Int = 30;

	private var _attackedWall:Wall = null;

	public var damage(get, set):Float;

	private var _damage:Float = 1;

	public var unitCML(get, set):UnitCML;

	private var _unitCML:UnitCML = null;

	private var _template:Bool = false;

	private var _tinyId:Int = 0;

	public var name(get, null):String;

	private var _name:String = "";

	public var displayName(get, null):String;

	private var _displayName:String = "";

	private var _unitType:Unit = null;

	public var parent(get, null):Unit;

	private var _parent:Unit = null;

	public var cmlScript(get, set):String;

	private var _cmlScript:String = "";

	public var unitCount(get, null):Int;

	private var _unitCount:Int = 0;

	public var level(get, null):Int;

	public var graphicX(get, null):Float;
	public var graphicY(get, null):Float;

	private var _level:Int = 0;

	public function new(?x:Float = 0, ?y:Float = 0, ?hitPoints:Float = 30, createRectangularBody:Bool = true, enablePhysics:Bool = true,
			template:Bool = false, animId:Int = 0) {
		super(x, y, hitPoints);

		_template = template;
		_scoreValue = 0;
		_enemy = true;
		_tinyId = animId;

		if (_template) {
			// Template unit, no Nape physics
			_sprite.physicsEnabled = enablePhysics;
		}
	}

	override function copyTo(clone:GameObject = null):GameObject {
		var unit:Unit = null;
		if (clone == null) {
			unit = new Unit(0, 0, _hitPoints, false, false, _template);
		} else {
			unit = cast(clone, Unit);
		}

		unit._template = _template;
		unit._name = _name;
		unit._displayName = _displayName;
		unit._cmlScript = _cmlScript;
		unit._unitCount = _unitCount;

		// Unit stats
		unit._damage = _damage;
		unit._tinyId = _tinyId;
		unit._level = _level;

		unit._sprite.offset.x = _sprite.offset.x;
		unit._sprite.offset.y = _sprite.offset.y;

		return super.copyTo(unit);
	}

	public function initTemplateFromNode(node:Access):Void {
		var damage:Int = (node.has.damage ? Std.parseInt(node.att.damage) : 1);
		var level:Int = (node.has.lvl ? Std.parseInt(node.att.lvl) : 1);

		initTemplate(Std.parseInt(node.att.id), node.att.name, node.att.displayName, node.att.tinyId, damage, level);
	}

	public function initTemplate(id:Int, name:String, displayName:String, tinyId:String, damage:Int, level:Int):Void {
		idType = id;
		_name = name;
		_displayName = displayName;
		_tinyId = Std.parseInt(tinyId);
		_damage = damage;
		_level = level;

		// To be sure
		_template = true;
	}

	public function initWave(id:Int, name:String, cmlScript:String, unitCount:Int):Void {
		idType = id;
		_name = name;
		this.cmlScript = cmlScript;
		_unitCount = unitCount;

		// To be sure
		_template = true;
	}

	override public function kill():Void {
		if (alive) {
			super.kill();

			if (_unitCML != null) {
				_unitCML.destroy(UnitCML.DEST_STATUS_FROM_GAME);
				_unitCML = null;
			}

			_action = UnitAction.DEATH;
			_timer = 0;
			_sprite.physicsEnabled = false;
			_sprite.animation.pause();

			// Keep the unit activated to animate his death
			exists = true;

			spawnBloodEffect(true);
		}
	}

	override public function destroy():Void {
		if (_unitCML != null) {
			_unitCML.destroy(UnitCML.DEST_STATUS_FROM_GAME);
			_unitCML = null;
		}
		super.destroy();
	}

	override public function update(elapsed:Float):Void {
		performAction();

		super.update(elapsed);
	}

	/**
	 * Damage from any source to the unit
	 * Override for damageReduction property
	 * @param	damange amount
	 * @return true if dead (hp <= 0), false otherwise
	 */
	override function dealDamage(damage:Float, source:GameObject, flag:DamageFlag, sourceFlag:AttributeFlag, mask:Bool = true):Bool {
		var dmgFactor = PlayState.get().attributeController.calculateValue(AttributeType.DEFENSE_REDUCTION, sourceFlag, _damageFactor);
		var realDamage:Float = damage * dmgFactor;
		var dmgText = DamageText.create(graphicX, graphicY, realDamage, false);

		if (dmgText != null)
			PlayState.get().add(dmgText);

		if (super.dealDamage(realDamage, source, flag, sourceFlag, mask)) {
			kill();
			PlayState.get().onUnitKilled(this, source);
			return true;
		} else if (realDamage > 1 && mask) {
			spawnBloodEffect(false);
		}

		return false;
	}

	/**
	 * Has to be overriden
	 * @return buff resistant or not (smaller effects)
	 */
	public function isBuffResistant():Bool {
		return false;
	}

	public function attackWall(wall:Wall):Void {
		_sprite.animation.pause();
		_timer = 0;
		_action = UnitAction.ATTACK;
		_attackedWall = wall;

		if (_unitCML != null) {
			_unitCML.pause();
		}
	}

	public function danceVictory():Void {
		if (alive) {
			_sprite.animation.pause();
			_timer = Math.round(Math.random() * -8);
			_action = UnitAction.VICTORY;

			if (_unitCML != null) {
				_unitCML.pause();
			}
		}
	}

	public function resetAndMoveForward():Void {
		_action = UnitAction.WALK;
		_sprite.animation.resume();
		_unitCML.resume();
		_sprite.offset.y = 0;

		if (_attackedWall != null) {
			updatePosition(x - 150, y);
			_unitCML.x = x;
		}
	}

	/**
	 * Launch CML Script for a wave / unit
	 */
	public function start():Void {
		// Root, emitter only
		_sprite.physicsEnabled = false;

		if (_unitCML == null) {
			_unitCML = new UnitCML(this, true);
			_unitCML.start();
		}
	}

	/**
	 * Unit factory
	 * @param	x
	 * @param	y
	 * @param	unitId
	 * @return
	 */
	public function createUnitInstance(x:Float, y:Float, unitId:Int):Unit {
		var tUnit:Unit = null;
		var unit:Unit = null;

		if (unitId >= START_ID_UNIT && unitId < START_ID_WAVE) {
			tUnit = DataUnit.get().getTUnit(unitId, false);
			unit = tUnit.createUnitFromTemplate(x, y);
		}

		return unit;
	}

	//////////////////////////////////////////////////////////////////////////////
	///	PRIVATE
	//////////////////////////////////////////////////////////////////////////////

	function performAction() {
		switch (_action) {
			case WALK:
			// Do nothing
			case ATTACK:
				switch (_timer) {
					case 1:
						_sprite.offset.x += 1;
					case 4:
						_sprite.offset.x -= 3;

						// Apply damage
						_attackedWall.dealDamage(_damage, this, DamageFlag.MELEE, AttributeFlag.ENEMY);
						PlayState.get().removeUnit(this);
					case 6:
						_sprite.offset.x += 2;
					default:
						if (_timer == _attackSpeed) _timer = 0;
				}

				_timer++;
			case DEATH:
				switch (_timer) {
					case 1:
						_sprite.offset.y += 7;
					case 4:
						_sprite.offset.y -= 2;
						_sprite.body.rotation -= 45 * MathUtils.DEG_TO_RAD;
					case 6:
						_sprite.offset.y -= 2;
						_sprite.body.rotation -= 45 * MathUtils.DEG_TO_RAD;
					case 8:
						_sprite.offset.y -= 3;
					case 16:
						alpha = 0.75;
					case 28:
						alpha = 0.5;
					case 40:
						alpha = 0.25;
					case 52:
						PlayState.get().removeUnit(this);
					default:
				}

				_timer++;
			case VICTORY:
				switch (_timer) {
					case 1:
						_sprite.offset.y += 5;
					case 3:
						_sprite.offset.y += 2;
					case 6:
						_sprite.offset.y -= 2;
					case 10:
						_sprite.offset.y -= 5;
					case 20:
						_timer = 0;
				}

				_timer++;
			default:
		}
	}

	function createUnitFromTemplate(x:Float, y:Float):Unit {
		var unit:Unit = null;

		if (_template) {
			FlxG.log.notice('Create unit $idType');

			unit = new Unit(x, y, hitPoints, true, true, false, _tinyId);

			unit._unitType = this;
			unit.updatePosition(x, y);
			unit._damage = _damage;
			unit._level = _level;

			unit.initSpriteAndPhysics();

			unit = PlayState.get().addUnit(unit);
		} else {
			Log.error("Not a template unit");
		}

		return unit;
	}

	/**
	 * 
	 * @param	kill
	 */
	function spawnBloodEffect(kill:Bool) {
		// Some blood
		if ((kill && Math.random() < Constant.BLOOD_KILL_FACTOR) || (!kill && Math.random() < Constant.BLOOD_DAMAGE_FACTOR)) {
			Effect.playEffect(_sprite.body.position.x, _sprite.body.position.y, BLOOD_ANIM[Math.floor(Math.random() * BLOOD_ANIM.length)], 35).center();
		}
	}

	function initSpriteAndPhysics() {
		// Atlas with all tiny buddies
		_sprite.loadGraphic(AssetPaths.sprite_sheet__png, true, 32, 32);

		// Random
		var id:Int = _tinyId;

		// 8 units by line
		var i:Int = (id % 8);
		// 8 units by line
		var j:Int = Math.floor(id / 8);

		_sprite.setFacingFlip(FlxDirectionFlags.LEFT, true, false);
		_sprite.setFacingFlip(FlxDirectionFlags.RIGHT, false, false);

		_sprite.animation.frameIndex = j * 8 + i;

		_sprite.facing = FlxDirectionFlags.RIGHT;

		add(_sprite);
		_spriteIndex = members.indexOf(_sprite);

		_sprite.updateHitbox();
		_sprite.createRectangularBody(20, 20, BodyType.KINEMATIC);
		_sprite.body.setShapeFilters(Unit.INTERACTION_FILTER);
		_sprite.body.cbTypes.add(GameObject.CB_ENEMY);

		_sprite.offset.x = 0;
		_sprite.offset.y = 0;
		_sprite.width = 20;
		_sprite.height = 20;
	}

	//////////////////////////////////////////////////////////////////////////////
	///	GETTERS / SETTERS
	//////////////////////////////////////////////////////////////////////////////

	@:noCompletion
	function get_damageMultiplier():Float {
		return _damageMultiplier;
	}

	@:noCompletion
	function set_damageMultiplier(value:Float):Float {
		if (value < 0)
			value = 0.001;

		return _damageMultiplier = value;
	}

	@:noCompletion
	function get_hpRegeneration():Float {
		return _hpRegeneration;
	}

	@:noCompletion
	function set_hpRegeneration(value:Float):Float {
		return _hpRegeneration = value;
	}

	@:noCompletion
	function get_cmlSlowFactor():Int {
		return (_unitCML != null ? _unitCML.slowFactor : 1);
	}

	@:noCompletion
	function set_cmlSlowFactor(value:Int):Int {
		return (_unitCML != null ? _unitCML.slowFactor = value : 1);
	}

	@:noCompletion
	function get_damageFactor():Float {
		return _damageFactor;
	}

	@:noCompletion
	function set_damageFactor(value:Float):Float {
		if (value < 0)
			value = 0;

		return _damageFactor = value;
	}

	@:noCompletion
	function get_scoreValue():Int {
		return _scoreValue;
	}

	@:noCompletion
	function get_spriteIndex():Int {
		return _spriteIndex;
	}

	@:noCompletion
	function set_scoreValue(value:Int):Int {
		return _scoreValue = value;
	}

	@:noCompletion
	function get_damage():Float {
		return _damage;
	}

	@:noCompletion
	function set_damage(value:Float):Float {
		return _damage = value;
	}

	@:noCompletion
	function get_unitCML():UnitCML {
		return _unitCML;
	}

	@:noCompletion
	function get_name():String {
		if (_unitType != null)
			return _unitType.name;

		return _name;
	}

	@:noCompletion
	function get_displayName():String {
		if (_unitType != null)
			return _unitType.displayName;

		return _displayName;
	}

	@:noCompletion
	function set_unitCML(value:UnitCML):UnitCML {
		return _unitCML = value;
	}

	@:noCompletion
	function get_parent():Unit {
		return _parent;
	}

	@:noCompletion
	function set_cmlScript(value:String):String {
		if (value.length > 0) {
			// Convert the script in a CannonML sequence
			// Format : #U<ID> {<script>};
			_cmlScript = '#U$idType {$value};';
		} else {
			_cmlScript = value;
		}

		return _cmlScript;
	}

	@:noCompletion
	function get_unitCount():Int {
		return _unitCount;
	}

	@:noCompletion
	function get_level():Int {
		return _level;
	}

	@:noCompletion
	function get_cmlScript():String {
		return _cmlScript;
	}
	@:noCompletion
	function get_graphicX():Float {
		return x - _sprite.offset.x;
	}

	@:noCompletion
	function get_graphicY():Float {
		return y - _sprite.offset.y;
	}
}
