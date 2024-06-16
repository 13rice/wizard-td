package data;

import flixel.math.FlxPoint;
import gameObject.GameObject;
import global.shared.Hitbox;
import global.shared.Log;
import haxe.xml.Access;
import openfl.Assets;

/**
 * Classe pour traiter un xml et charger les donnees contenues
 * Utilise les differentes classes de chargement selon la donnee:
	 * DataEnemy
	 * DataEnemyWave
	 * DataMissile
	 * DataPlanet
	 * DataLevelWave
 * @author 13rice
 */
class DataManager
{
	
	public static var masterScript:String = "";

	public static var dataLoaded:Bool = false;
	
	public static function loadData():Void
	{
		if (dataLoaded)
			return;

		// Sound Init
		var data:String = Assets.getText(AssetPaths.tsounds__xml);
		var xml:Access = new Access(Xml.parse(data)).node.data;
		
		DataSound.get().loadFromXML(xml.node.sounds);
		// Spell Init
		data = Assets.getText(AssetPaths.tmissiles__xml);
		xml = new Access(Xml.parse(data)).node.data;
		
		DataSpell.get().loadFromXML(xml.node.spelldatas);
		
		// Unit Init
		data = Assets.getText(AssetPaths.tunits__xml);
		xml = new Access(Xml.parse(data)).node.data;
		
		DataUnit.get().loadFromXML(xml.node.unitdatas);
		// Skill Init
		data = Assets.getText(AssetPaths.tskills__xml);
		xml = new Access(Xml.parse(data)).node.data;

		DataSkill.get().loadLevelsFromXML(xml.node.levels);
		DataSkill.get().loadSkillsFromXML(xml.node.skilltree, true);
		DataSkill.get().loadSkillsFromXML(xml.node.affinity, false);

		dataLoaded = true;
	}
	
	
	/**
	 * 
	 * @param	node
	 * @return
	 */
	public static function isValidGameObjectNode(node:Access):Bool
	{		
		if (!node.has.frameName
			&& !node.has.animationPrefix)
		{
			
			Log.error("Node missing for animated GameObject");
			return false;
		}
		
		return true;
	}
	
	
	
	public static function loadGameObjectFromXml(node:Access, tObject:GameObject):GameObject
	{
		if (!isValidGameObjectNode(node))
		{
			return null;
		}
		
		if (tObject == null)
			tObject = new GameObject();
		
		tObject.idType = Std.parseInt(node.att.id);
		
		tObject.atlasName = node.att.atlasName;
		tObject.isAnimation = !node.has.frameName; 
		
		if (!tObject.isAnimation)
		{
			// Simple frame
			tObject.frameName = node.att.frameName;
		}
		else
		{
			// Animated
			tObject.animationPrefix = node.att.animationPrefix;
			if (node.has.fps)
				tObject.fps = Std.parseInt(node.att.fps);
			else
				tObject.fps = Constant.DEFAULT_ANIM_FPS;
				
			if (node.has.loop)
				tObject.loop = (Std.parseInt(node.att.loop) == 1);
			
			if (node.has.frame)
				tObject.frameStart = Std.parseInt(node.att.frame);
		}
		
		
		// Custom hitbox
		if (node.hasNode.hitbox)
		{
			tObject.hitbox = Hitbox.loadFromXml(node.node.hitbox);
		}
		else
		{
			if (node.has.ox || node.has.oy)
			{
				tObject.customOrigin = FlxPoint.get();
				
				// Custom offset
				if (node.has.ox)
					tObject.customOrigin.x = Std.parseInt(node.att.ox);
				
				if (node.has.oy)
					tObject.customOrigin.y = Std.parseInt(node.att.oy);
			}
			
			if (node.has.offx)
			{
				tObject._sprite.offset.x = Std.parseInt(node.att.offx);
			}
			
			if( node.has.offy)
			{
				tObject._sprite.offset.y = Std.parseInt(node.att.offy);
			}
		}
		
		return tObject;
	}
	
}