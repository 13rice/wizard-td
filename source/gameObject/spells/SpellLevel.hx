package gameObject.spells;

import openfl.utils.Dictionary;

/**
 * "dmgType" attribute in the spells data
 */
enum DamageType {
	DMG_TYPE_NORMAL; // attribute not set
	DMG_TYPE_PERCENT_CURRENT; // "%"
	DMG_TYPE_PERCENT_MAX; // "%max"
}

/**
 * To add an attribute to a spell, add :
 * 	- the private var
 * 	- the property
 * 	- the xml extraction
 * 	- the init in constructor
 * @author 13rice
 */
@:allow(Spell)
class SpellLevel {
	public var spellId(get, null):Int;

	private var _spellId:Int = 0;

	// In seconds
	public var coolDown(get, null):Float;

	private var _coolDown:Float = 0;

	private var _level:Int = 1;

	public var level(get, null):Int;

	// In seconds
	public var duration(get, set):Float;

	private var _duration:Float = 0;

	public var damage(get, set):Float;

	private var _damage:Float = 10;

	/** In pixels */
	public var range(get, set):Float;

	private var _range:Float = 0;

	public var areaAngle(get, set):Float;

	private var _areaAngle:Float = 0;

	public var height(get, set):Float;

	private var _height:Float = 0;

	public var damageType(get, null):DamageType;

	private var _damageType:DamageType = DMG_TYPE_NORMAL;

	/** For specific width != range, return range if null */
	public var areaWidth(get, set):Null<Float>;

	private var _areaWidth:Null<Float> = null;

	/** For complex spells with radius damage, dot etc. */
	private var _damages:Map<String, Float> = null;

	public var iconName(get, null):String;

	private var _iconName:String = "";

	public var name:String = "";

	public var description(get, null):String;

	private var _description:String = "";

	/* Short description, eg for next level tooltip */
	public var shortDescription(get, null):String;

	private var _shortDescription:String = "";

	public function new(spellId:Int, level:Int, iconName:String, name:String, description:String, coolDown:Float, damage:Float, range:Float = 0,
			duration:Float = 0, ?damages:Map<String, Float>, areaAngle:Float = 0, height:Float = 0, areaWidth:Null<Float> = null,
			damageType:DamageType = DMG_TYPE_NORMAL, short:String = "") {
		_spellId = spellId;
		_level = level;
		_iconName = iconName;
		this.name = name;
		this._description = description;
		_shortDescription = short;
		_coolDown = coolDown;
		_damage = damage;
		_range = range;
		_duration = duration;
		_damages = damages;
		_areaAngle = areaAngle;
		_height = height;
		_areaWidth = areaWidth;
		_damageType = damageType;
	}

	public function addDamage(id:String, value:Float):Void {
		_damages[id] = value;
	}

	private function formatDescription(desc:String):String {
		var result:String = desc;
		var begin:Bool = true;
		var startIndex:Int = result.indexOf("%%");
		var endIndex:Int = 0;
		var variable:String = "";
		var value:String = "";

		while (startIndex != -1) {
			startIndex += 2;
			endIndex = result.indexOf("%%", startIndex);

			// Variable name
			variable = result.substring(startIndex, endIndex);

			// Retrieve value
			value = Reflect.getProperty(this, variable) + "";

			// Replace in desination string
			// result = StringTools.replace(result, "%%" + variable + "%%", "::" + value + "::");
			result = StringTools.replace(result, "%%" + variable + "%%", value);

			// Find next variable
			startIndex = result.indexOf("%%", startIndex);
		}

		return result;
	}

	@:noCompletion
	function get_iconName():String {
		return _iconName;
	}

	@:noCompletion
	function get_coolDown():Float {
		return _coolDown;
	}

	@:noCompletion
	function get_spellId():Int {
		return _spellId;
	}

	@:noCompletion
	function get_level():Int {
		return _level;
	}

	@:noCompletion
	function get_range():Float {
		return _range;
	}

	@:noCompletion
	function set_range(value:Float):Float {
		return _range = value;
	}

	@:noCompletion
	function get_duration():Float {
		return _duration;
	}

	@:noCompletion
	function set_duration(value:Float):Float {
		return _duration = value;
	}

	@:noCompletion
	function get_areaAngle():Float {
		return _areaAngle;
	}

	@:noCompletion
	function set_areaAngle(value:Float):Float {
		return _areaAngle = value;
	}

	@:noCompletion
	function get_height():Float {
		return _height;
	}

	@:noCompletion
	function set_height(value:Float):Float {
		return _height = value;
	}

	@:noCompletion
	function get_areaWidth():Float {
		if (_areaWidth == null)
			return _range;

		return _areaWidth;
	}

	@:noCompletion
	function set_areaWidth(value:Float):Float {
		return _areaWidth = value;
	}

	@:noCompletion
	function get_damage():Float {
		return _damage;
	}

	@:noCompletion
	function get_description():String {
		return formatDescription(_description);
	}

	@:noCompletion
	function get_shortDescription():String {
		return formatDescription(_shortDescription);
	}

	@:noCompletion
	function set_damage(value:Float):Float {
		return _damage = value;
	}

	@:noCompletion
	function get_damageType():DamageType {
		return _damageType;
	}
}