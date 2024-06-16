package global.buff;

import flixel.FlxSprite;
import flixel.util.FlxDestroyUtil;
import gameObject.Unit;

/**
 * Buff Ideas, not (yet) implemented, because not the most useful or hard to implement :
 * - Invisibility
 * - Slow movement (nightmare !)
 * - Slow fire (maybe with some modification of CanonML)
 * - Leech (player has 1 hp, enemy never touch the player)
 * 
 * 
 * Implemented :
 * 	- Property modifier, any get / set property of a unit can be modified, multiple at same time
 *  - Dot Damage, damage over time, or heal
 *  - Stun, pause the unit, movement and or fire
 * 
 * @author 13rice
 */
class BuffBase
{
	public static inline var HEIGHT:Int = 32;
	
	public var name(get, null):String;
	private var _name:String;
	
	public var target(get, null):Unit;
	private var _target:Unit = null;
	
	/** Displayed icon, if necessary */
	public var icon(get, null):FlxSprite;
	private var _icon:FlxSprite = null;
	
	/** in sec */
	private var _duration:Float = 1;
	
	private var _iconName:String = "";
	
	public inline static var ID = "BASE";
	
	private function new(name:String) 
	{
		_name = name;
	}
	
	/**
	 * Returns a new BuffBase cloning this
	 * @return
	 */
	public function clone():BuffBase
	{
		var buff:BuffBase = new BuffBase(_name);
		buff._target = _target;
		
		return buff;
	}
	
	public function applyTo(target:Unit):Bool 
	{
		_target = target;
		return true;
	}
	
	/**
	 * 
	 * @param	elapsedTime
	 * @return true if the effect is finished, false otherwise
	 */
	public function frameMove(elapsedTime:Float):Bool 
	{
		return false;
	}
	
	public function remove():Void 
	{
		if (_icon != null && _target != null)
		{
			if (_target.group != null)
				_target.remove(_icon);
			
			_icon = FlxDestroyUtil.destroy(_icon);
		}
		
		target = null;
	}
	
	/**
	 * Compare this buff to otherBuff like operator "this < otherBuff"
	 * Both buffs MUST BE of equal types for child class
	 * @param	otherBuff
	 * @return
	 */
	public function lt(otherBuff:BuffBase):Bool
	{
		return true;
	}
	
	function get_target():Unit 
	{
		return _target;
	}
	
	function get_name():String 
	{
		return _name;
	}
	
	function get_icon():FlxSprite 
	{
		return _icon;
	}
	
}