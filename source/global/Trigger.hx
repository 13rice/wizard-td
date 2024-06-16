package global;
import gameObject.Unit;
import flixel.util.FlxSignal.FlxTypedSignal;
import gameObject.GameObject;

/**
 * ...
 * @author 
 */
class Trigger 
{
	
	
	/** Killed Unit / Killer */
	public static var UNIT_KILLED = new FlxTypedSignal<Unit->GameObject->Void>();
	
	/** Damaged unit / damage dealer */
	public static var UNIT_DAMAGED = new FlxTypedSignal<GameObject->GameObject->Void>();

	/** Skill Level up **/
	public static var SKILL_LEVEL_UP = new FlxTypedSignal</*skill id*/ String->Void>();
	
	public static function destroy():Void
	{
		UNIT_KILLED.removeAll();
		UNIT_DAMAGED.removeAll();
		SKILL_LEVEL_UP.removeAll();
	}
	
}