package gameObject;

import global.shared.Log;
import global.shared.MathUtils;
import nape.shape.Circle;
import org.si.cml.CMLFiber;
import org.si.cml.CMLObject;

/**
 * ...
 * @author 13rice
 */
class UnitCML extends CMLObject
{
	public static inline var DEST_STATUS_FROM_GAME = 0;
	public static inline var DEST_STATUS_FROM_CML = 2;
	/**
	 * Unit linked to the UnitCML
	 */
	public var owner(get, set):Unit;
	private var _owner:Unit = null;
	
	private var _cmlSequenceID:String;
	
	public var started(get, null):Bool;
	private var _started:Bool = false;
	
	public var fiber(get, null):CMLFiber;
	private var _fiber:CMLFiber = null;

	private var _paused:Bool = false;
	
	/**
	 * Add a new Unit scripted with CannonML
	 * @param	owner, link to a Unit
	 * @param	root, first sequence for the creation of other real units.
	 */
	public function new(owner:Unit, root:Bool) 
	{
		super();
		
		// Owner is mandatory
		if (owner != null)
		{
			_owner = owner;
			
			// Root, Unit as a group or a level
			if (root)
			{
				// Sequence to execute
				_cmlSequenceID = "U" + owner.idType;
				
				create(_owner.x, _owner.y);
			}
			else
			{
				// Link the unitCML to the unit
				_owner.unitCML = this;
			}
		}
		else
			Log.error("Owner null for UnitCML");
			
	}
	
	override public function update(elapsedTime:Float) {
		if (!_paused)
			super.update(elapsedTime);
	}

	/**
	 * Setting the owner position and rotation
	 */
	override public function onCreate():Void 
	{
		_owner.angle = angle * MathUtils.DEG_TO_RAD;
		
		_owner.updatePosition(x, y);
	}
	
	/**
	 * Refresh the owner position and rotation
	 */
	override public function onUpdate() : Void
    {
		if (_owner._sprite.body != null)
			_owner._sprite.body.rotation = angle * MathUtils.DEG_TO_RAD;
		else
			_owner.angle = angle;
		
		_owner.updatePosition(x, y);
    }
	
	override public function onDestroy() : Void
    {
		// Destroy the unitCML with the owner, for sub unit, invocation or whatever => use ko2
		if (_destructionStatus >= 2)
		{
			// Explosion
			/*
			if (_destructionStatus == 3)
				missile.explosionOnDestroy();
			*/
			
			_owner.kill();
		}
		
		_owner = null;
    }
	
	override public function onNewObject(args:Array<Dynamic>):CMLObject 
	{
		var unitCML:UnitCML = null;
		var unit:Unit = null;
		var unitId:Int = Unit.START_ID_UNIT;
		
		if (_owner != null)
		{
			if (args.length > 0)
			{
				unitId = args[0];
			}
			else
			{
				Log.warn('no id, default id : $unitId');
			}
			
			unit = _owner.createUnitInstance(x, y, unitId);
			
			// A unit can be null if the creation failed
			if (unit != null)
			{
				// Hotfix for the player...
				if (!_owner.enemy && _fiber != null)
				{
					_fiber.target = PlayState.get().targetForPlayer;
				}
				unitCML = new UnitCML(unit, false);
			}
			
		}
		
		return unitCML;
	}
	
	/**
	 * TO BE USED FOR RANGE UNITS
	 * for new object created by "f" command
	 * Args can contain an ID to a different missile type from the original missile type. Used for fragmentations
	 * @param	args from the sequence, Spell ID
	 * @return
	 */
    override public function onFireObject(args:Array<Dynamic>) : CMLObject
    {
		var unitCML:UnitCML = null;
		/*var spellId:Int = _owner.idType;
		var spell:Spell = null;
		
		if (_owner != null)
		{
			if (args.length > 0 && spellId != args[0])
			{
				if (DataSpell.get().isTSpellExists(args[0]))
				{
					spellId = args[0];
				}
				else
				{
					// In case of error, keep the source ID
					Log.error('unknown ID : ${args[0]}, setting default spell type');
				}
			}
			
			// TODO apply damage multiplier for fragment element
			//var layer:Sprite = (_owner.enemy ? Game.get().gameLayer : Game.get().playerBulletLayer);
			//missile = tMissileFire.createMissile(layer, _owner, x, y, angle, (_weapon != null ? _weapon.offset : null), _mirrorY, 0, (_weapon != null ? _weapon.damageMultiplier : 1));
			spell = _owner.createChildInstance(x, y, spellId);
			
			
			// A missile can be null if the creation failed, outside of the gaming area for example
			if (spell != null)
			{
				// Hotfix for the player...
				if (!_owner.enemy && _fiber != null)
				{
					_fiber.target = PlayState.get().targetForPlayer;
				}
				spellCML = new SpellCML(spell, _mirrorY, false);
				
				// Keep same start angle for the child
				spellCML._startAngle = _startAngle;
			}
		}*/
		
		return unitCML;
	}
	
	public function start(sequence:String = ""):Void
	{
		if (!_started)
		{
			_started = true;
			if (sequence == "")
				sequence = _cmlSequenceID;

			_fiber = execute(PlayState.get().cmlScript.childSequence[sequence], null, 0);
			
			if (_fiber != null)
			{
				if (!_owner.enemy)
				{
					_fiber.target = PlayState.get().targetForPlayer;
				}
			}
			else
				Log.error("Sequence ID not found : " + sequence);
		}
		else
		{
			Log.warn('Unit already started : $_cmlSequenceID');
		}
	}
	
	public static function scaleCML(fbr:CMLFiber, args:Array<Dynamic>):Void 
	{
		var unit:Unit = unitFromFiber(fbr).owner;
		
		if (Math.isNaN(args[1]))
		{
			unit.scale.x = unit.scale.y = args[0];
		}
		else
		{
			unit.scale.x = args[0];
			unit.scale.y = args[1];
		}
	}
	
	/**
	 * Modify the radius of the hitbox trough CML script.
	 * /!\ The hitbox MUST BE a CIRCLE shape
	 * @param	fbr
	 * @param	args
	 */
	static public function hitboxRadiusCML(fbr:CMLFiber, args:Array<Dynamic>):Void 
	{
		var unit:Unit = unitFromFiber(fbr).owner;
		
		if (!Math.isNaN(args[0]))
		{
			cast(unit._sprite.body.shapes.at(0), Circle).radius = args[0];
		}
		else
		{
			Log.error("Missing parameter");
		}
	}
	
	public static inline function unitFromFiber(fbr:CMLFiber):UnitCML
	{
		return cast(fbr.object, UnitCML);
	}
	public function pause() {
		_paused = true;
	}

	public function resume() {
		_paused = false;
	}
	
	@:noCompletion
	function get_owner():Unit 
	{
		return _owner;
	}
	
	@:noCompletion
	function set_owner(value:Unit):Unit 
	{
		return _owner = value;
	}
	
	@:noCompletion
	function get_started():Bool 
	{
		return _started;
	}
	
	@:noCompletion
	function get_fiber():CMLFiber 
	{
		return _fiber;
	}
	
	override public function get_angle() : Float
	{
		return super.get_angle() + 180;
	}
	override public function halt():Void {
		super.halt();
		_started = false;
	}
}