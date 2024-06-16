package global.buff;

import flixel.FlxG;
import gameObject.Unit;
import global.shared.Log;
import haxe.Json;
import haxe.xml.Access;
import motion.Actuate;
import motion.easing.Quint;

/**
 * ...
 * @author 13rice
 */
class BuffManager
{
	
	private var _buffs:Array<BuffBase> = [];
	
	/** Displayed buff for the unit */
	private var _displayedBuffs:Map<Unit, Array<BuffBase>> = new Map();
	
	// Singleton
	private static var _buffManager:BuffManager = new BuffManager();
	
	public static function get():BuffManager
	{
		return _buffManager;
	}
	
	private function new() 
	{
	}
	
	/**
	 * Remove all buffs
	 */
	public function reset() : Void
	{
		for (buff in _buffs)
		{
			buff.remove();
		}
		
		_buffs = [];
		_displayedBuffs = new Map();
	}
	
	/**
	 * Adding a buff to the manager and for the given target
	 * @param	target
	 * @param	buff
	 */
	public function addBuff(target:Unit, buff:BuffBase)
	{
		if (target == null)
		{
			Log.error("target null");
			return;
		}
		
		if (buff == null)
		{
			Log.error("buff null");
			return;
		}
		
		var addBuff:Bool = true;
		
		var sameBuffsByType:Array<BuffBase> = _buffs.filter(function(b) { return b.name == buff.name && b.target == target; } );
		if (sameBuffsByType.length > 0)
		{
			// Replace the previous buff
			if (sameBuffsByType[0].lt(buff))
			{
				removeBuff(sameBuffsByType[0]);
				addBuff = true;
			}
			else // Keep the current buff, more powerful
				addBuff = false;
		}
		
		if (addBuff)
		{
			buff.applyTo(target);
			_buffs.push(buff);
		}
		
		if (buff.icon != null)
		{
			if (!_displayedBuffs.exists(target))
			{
				_displayedBuffs[target] = new Array();
			}
			
			if (!target.enemy)
			{
				// TODO BUFF PLAYER
				PlayState.get().add(buff.icon);
				
				buff.icon.x = FlxG.width - buff.icon.width / 2 - 2;
				buff.icon.y = 20;
			}
			
			_displayedBuffs[target].push(buff);
		}
	}
	
	/**
	 * Remove a specific buff
	 * @param	buff
	 * @return
	 */
	public function removeBuff(buff:BuffBase) : Bool
	{
		removeIcon(buff);
		
		// Remove and clean the buff, unusable after this point
		buff.remove();
		
		return _buffs.remove(buff);
	}
	
	public function frameMove(elapsedTime:Float) : Void
	{
		var buffsToRemove:Array<BuffBase> = null;
		
		// Update all the buffs
		for (buff in _buffs)
		{
			if (buff.frameMove(elapsedTime))
			{
				removeIcon(buff);
				buff.remove();
				
				if (buffsToRemove == null)
				{
					buffsToRemove = new Array();
				}
				buffsToRemove.push(buff);
			}
		}
		
		
		// Remove finished buff
		if (buffsToRemove != null)
		{
			for (buff in buffsToRemove)
			{
				_buffs.remove(buff);
			}
		}
	}
	
	public function loadFromXML(xml:Access):BuffBase
	{
		if (xml == null || xml.name != "buff")
		{
			Log.error('Incorrect node name $xml.name');
			return null;
		}
		
		var buff:BuffBase = null;
		
		if (xml.has.type)
		{
			var type:String = xml.att.type;
			
			switch (type)
			{
				/*case BuffDot.ID:
					buff = new BuffDot(xml.att.name,
						Std.parseFloat(xml.att.duration),
						Std.parseFloat(xml.att.damage),
						xml.has.lethal);*/
				case BuffPropertyModifier.ID:
					buff = new BuffPropertyModifier(xml.att.name,
						Std.parseFloat(xml.att.duration),
						Json.parse(xml.att.properties),
						xml.att.iconName,
						Std.parseInt(xml.att.level));
				/*case BuffStun.ID:
					buff = new BuffStun(Std.parseFloat(xml.att.duration),
						xml.has.movement,
						xml.has.fire);*/
				default:
					Log.error('Unknow type $type');
			}
		}
		else
		{
			Log.error('No type given');
		}
		
		
		return buff;
	}

	private function removeIcon(buff:BuffBase):Void
	{
		// Buff displayed ?
		if (buff.target != null && buff.icon != null)
		{
			var unitBuffs:Array<BuffBase> = _displayedBuffs[buff.target];
			
			var index:Int = unitBuffs.indexOf(buff);
			_displayedBuffs[buff.target].remove(buff);
			
			// Move the other buffs from the removing buff
			if (buff.target.isPlayer()) {
				for (i in index...unitBuffs.length) {
					Actuate.tween(unitBuffs[i].icon, 0.5, {y: FlxG.height - (BuffBase.HEIGHT / 2 - 2) - i * BuffBase.HEIGHT})
						.delay(i * 0.1)
						.ease(Quint.easeOut);
				}
			}	
		}
	}
	
}