package global.buff;

import flixel.FlxSprite;
import flixel.util.FlxDestroyUtil;
import gameObject.Unit;
import global.shared.Log;
import haxe.ds.Map;
import haxe.ds.StringMap;

/**
 * ...
 * @author 13rice
 */
class BuffPropertyModifier extends BuffBase {
	/** Buff act has an ability, ie no duration */
	private var _ability:Bool = false;

	/** properties to modify with given multiplier, example : { damageMultiplier : 1.5 } */
	private var _properties:Map<String, Float> = null;

	/** for comparison */
	private var _level:Int = 1;

	private var _buffName:String = "";

	public inline static var ID = "PROP_MOD";

	/**
	 * 
	 * @param	buffName
	 * @param	duration in sec, < 0 for infinite buff (ability)
	 * @param	properties Map<String, Float> or anonymous structures with properties to modify to the owner, values must be > 0
	 */
	public function new(buffName:String, duration:Float, properties:Dynamic, iconName:String = "", level:Int = 1) {
		super("PROP_MOD_" + buffName);

		_buffName = buffName;
		_duration = duration;

		if (Std.is(properties, StringMap)) {
			_properties = properties;
		} else {
			_properties = new Map();

			for (field in Reflect.fields(_properties)) {
				_properties[field] = Reflect.getProperty(_properties, field);
			}
		}

		_level = level;
		_ability = (_duration < 0);
		_iconName = iconName;
	}

	/**
	 * Returns a new BuffPropertyModifier cloning this
	 * @return
	 */
	override public function clone():BuffBase {
		var buff:BuffPropertyModifier = new BuffPropertyModifier(_buffName, _duration, _properties, _iconName, _level);
		buff._target = _target;

		return buff;
	}

	override public function applyTo(target:Unit):Bool {
		super.applyTo(target);

		// Buff effect
		if (_iconName != "" && _icon == null) {
			_icon = new FlxSprite(-15, -13);
			_icon.frames = PlayState.get().getAtlas(Constant.ATLAS_FX);
			_icon.animation.addByPrefix("idle", _iconName, 16);
			_icon.animation.play("idle");
		}

		// Place the buff in the lower right corner
		if (_target.enemy) {
			// Place the buff on the unit
			_target.add(_icon);
		}

		for (field => multiplier in _properties) {
			if (multiplier > 0) {
				Reflect.setProperty(_target, field, Reflect.getProperty(_target, field) * multiplier);
			} else
				Log.error('property = 0 : $field');
		}

		return true;
	}

	/**
	 * 
	 * @param	elapsedTime
	 * @return true if the effect is finished or the target removed, false otherwise
	 */
	override public function frameMove(elapsedTime:Float):Bool {
		if (_target == null || !_target.alive) {
			// Target destroyed
			return true;
		}

		if (!_ability)
			_duration -= elapsedTime;

		return !_ability && _duration <= 0;
	}

	override public function remove():Void {
		var multiplier:Float = 0;

		for (field => multiplier in _properties) {
			if (multiplier > 0) {
				Reflect.setProperty(_target, field, Reflect.getProperty(_target, field) / multiplier);
			} else
				Log.error('property = 0 : $field');
		}

		super.remove();
	}

	/**
	 * Compare this buff to otherBuff like operator "this < otherBuff"
	 * @param	otherBuff
	 * @return Comparison of level, if same level comparison of duration
	 */
	override public function lt(otherBuff:BuffBase):Bool {
		if (Type.getClass(otherBuff) != BuffPropertyModifier) {
			Log.error("Incorrect type for comparison : " + Type.getClass(otherBuff));
			return false;
		}

		var otherBuff:BuffPropertyModifier = cast(otherBuff, BuffPropertyModifier);

		return _level < otherBuff._level || (_level == otherBuff._level && _duration < otherBuff._duration);
	}
}