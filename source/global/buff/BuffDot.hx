package global.buff;

import global.attribute.AttributeFlag;
import gameObject.attacks.DamageFlag;
import flixel.FlxSprite;
import gameObject.Unit;
import global.shared.Log;

/**
 * ...
 * @author 13rice
 */
class BuffDot extends BuffBase
{
	
	/** Damage or heal / sec */
	private var _damage:Float = 1;
	
	/** Can kill the target ? */
	private var _lethal:Bool = false;
	
	private var _dotName:String = "";
	
	public inline static var ID = "DOT";
	
	public function new(dotName:String, duration:Float, damage:Float, lethal:Bool, iconName:String) 
	{
		super("DOT" + dotName);
		
		_iconName = iconName;
		_dotName = dotName;
		_duration = duration;
		_damage = damage;
		_lethal = lethal;
	}
	
	/**
	 * Returns a new BuffDot cloning this
	 * @return
	 */
	override public function clone():BuffBase
	{
		var buff:BuffDot = new BuffDot(_dotName, _duration, _damage, _lethal, _iconName);
		buff._target = _target;
		
		return buff;
	}
	
	override public function applyTo(target:Unit):Bool 
	{
		super.applyTo(target);
		
		// Poison effect
		if (_iconName != "" && _icon == null)
		{
			_icon = new FlxSprite(-8, 0);
			_icon.frames = PlayState.get().getAtlas(Constant.ATLAS_FX);
			_icon.animation.addByPrefix("idle", _iconName, 32);
			_icon.animation.play("idle");
			_icon.updateHitbox();
			_icon.y = 1 - _icon.height;
		}
		
		// Place the buff in the lower right corner
		if (_target.enemy)
		{
			// Place the buff on the unit
			_target.add(_icon);
		}
		
		return true;
	}
	
	/**
	 * 
	 * @param	elapsedTime
	 * @return true if the effect is finished, false otherwise
	 */
	override public function frameMove(elapsedTime:Float):Bool {
		if (_target == null) {
			Log.warn("target null");
			return true;
		}
		else if (!_target.alive)
			return true;
		
		// Damage application
		if (_lethal || (_target.hitPoints > _damage * elapsedTime))
			_target.dealDamage(_damage * elapsedTime, null, DamageFlag.SPELL, AttributeFlag.NONE, false);
		
		_duration -= elapsedTime;
		
		return _duration <= 0;
	}
	
	/**
	 * Compare this buff to otherBuff like operator "this < otherBuff"
	 * @param	otherBuff
	 * @return Comparison of duration * damage, so total of damage over time
	 */
	override public function lt(otherBuff:BuffBase):Bool {
		if (Type.getClass(otherBuff) != BuffDot) {
			Log.error("Incorrect type for comparison : " + Type.getClass(otherBuff));
			return false;
		}
		
		return _duration * _damage < cast(otherBuff, BuffDot)._duration * cast(otherBuff, BuffDot)._damage;
	}
	
}