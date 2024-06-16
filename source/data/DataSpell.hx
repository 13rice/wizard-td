package data;

import gameObject.items.ItemScroll.Element;
import gameObject.spells.Spell;
import gameObject.spells.SpellLevel;
import gameObject.spells.SpellSkill;
import global.shared.Log;
import haxe.ds.Map;
import haxe.xml.Access;


/**
 * Singleton
 * Types de missile des unités ainsi que leur chargement depuis un fichier xml
 * @author 13rice
 */
@:allow(SpellSkill)
class DataSpell
{
	
	/**
	 * All CannonML Sequences for bullets
	 */
	public var spellScript(get, never):String;
	private var _spellScript:String = "";
	
	// Chargement des données par XML
	private var _lTSpells:Map<Int /*id*/, Spell>;
	
	// Chargement des données par XML
	private var _lTSpellSkill:Map<Int /*id*/, SpellSkill>;
	
	/**
	 * Elements by string order
	 * @see Element.sort
	 */
	private var _spellsByElements:Map < Element, Map<Element, SpellSkill>> = new Map();
	
	// Singleton
	private static var _instance = new DataSpell();
	
	private function new()
	{
		_lTSpells = new Map<Int, Spell>();
		_lTSpellSkill = new Map<Int, SpellSkill>();
		
		/*
		_spellsByElements =
			[Element.DEATH => 	[Element.DEATH => [Element.DEATH => null]
								[Element.DEATH => [Element.DEATH => null]];*/
		
		var elements = Element.array();
		
		_spellsByElements = 
			[for (el0 in elements)
				el0 => [for (el1 in elements)
						el1 => null]];
	}
	
	public static function get():DataSpell
	{
		return _instance;
	}
	
	/**
	 * Load all the spells datas from <spelldatas> node
	 * @param	node
	 */
	public function loadFromXML(node:Access):Void
	{
		if (node == null || node.name != "spelldatas")
		{
			trace("error loading xml data in DataSpell");
			return;
		}
		
		// Spells
		for (child in node.node.spells.nodes.spell)
		{
			loadSpell(child);
		}
		
		// SpellSkills
		for (child in node.node.spellSkills.nodes.spellSkill)
		{
			loadSpellSkill(child);
		}
	}
	
	/**
	 * Spell Sample
	 * 	<spell id="1000999" cmlscript="[w171 ho0 [f8 w13]3 w30]" atlasName="fx.png" animationPrefix="sonicboom_" fps="14">
			<hitbox shape="box" width="64" height="15" x1="0" y1="13"/>
		</spell>
	 * @param	node
	 * @return
	 */
	private function loadSpell(node:Access):Spell
	{
		if (!checkSpellNode(node))
		{
			return null;
		}
		
		var id:Int = Std.parseInt(node.att.id);
		
		if (_lTSpells.exists(id))
			return _lTSpells[id];
		
		var spell:Spell = new Spell(0, 0);
		
		// Load GameObject's datas
		DataManager.loadGameObjectFromXml(node, spell);
		
		// Template spell, no Nape physics
		spell._sprite.physicsEnabled = false;
		
		
		// CML Scrit
		spell.cmlScript = node.att.cmlscript;
		
		// Effect ? no collision
		if (node.has.effect)
		{
			spell.effect = (Std.parseInt(node.att.effect) == 1);
		}
		
		// Flip X animation ?
		if (node.has.flipX)
		{
			spell.flipXAnim = (Std.parseInt(node.att.flipX) == 1);
		}
		
		// Collide or piercing ?
		spell.collide = node.has.collide ? (Std.parseInt(node.att.collide) == 1) : false;
		
		// Buff ?
		if (node.has.buff)
		{
			spell.buffId = node.att.buff;
			
			var i = 0;
			while (node.has.resolve('buffArg$i'))
			{
				if (i == 0)
					spell.buffArgs = [node.att.resolve('buffArg$i')];
				else
					spell.buffArgs.push(node.att.resolve('buffArg$i'));
				
				i++;
			}
			
			if (node.has.buffImg)
				spell.buffImage = node.att.buffImg;
		}
		
		// No damage but collide ?
		if (node.has.noDmg)
		{
			spell.noDamage = Std.parseInt(node.att.noDmg) == 1;
		}
		
		// Damage over Time / DOT ?
		spell.dot = node.has.dot;
		
		// Maximum collision count
		if (node.has.maxCollisionCount) {
			spell.maxCollisionCount = Std.parseInt(node.att.maxCollisionCount);
		}
		
		_lTSpells[id] = spell;
		
		// Add the script to the master spell script
		_spellScript += spell.cmlScript;
		
		return spell;
	}
	
	/**
	 * Spell Skill sample
	 * <spellSkill id="2000125" name="sonicboom" el0="death" el1="death" el2="death">
			<spellLevels>
				<spellLevel name="Sonic Boom - niveau 1" spellId="1000999" coolDown="1" level="1" damage="10" icon="blue_06.png" description="Boom it hurts !" arg1="123456" />
				<spellLevel name="Sonic Boom - niveau 2" spellId="1000999" coolDown="1" level="2" damage="30" icon="blue_06.png" description="Boom it hurts more !" arg1="" />
			</spellLevels>
		</spellSkill>
	 * @param	node
	 * @return
	 */
	private function loadSpellSkill(node:Access):SpellSkill
	{
		if (!checkSpellSkillNode(node))
		{
			return null;
		}
		
		var id:Int = Std.parseInt(node.att.id);
		var name:String = node.att.name;
		
		if (_lTSpellSkill.exists(id))
			return _lTSpellSkill[id];
		
		var spellSkill:SpellSkill = new SpellSkill(id, name);
		
		if (node.has.el0 && node.has.el1) {
			spellSkill.elements[0] = cast(node.att.el0, Element);
			spellSkill.elements[1] = cast(node.att.el1, Element);

			_spellsByElements[spellSkill.elements[0]][spellSkill.elements[1]] = spellSkill;
		}
		
		for (spellLevelNode in node.node.spellLevels.nodes.spellLevel)
		{
			spellSkill.addSpellLevel(loadSpellLevel(spellLevelNode));
		}
		
		_lTSpellSkill[id] = spellSkill;
		
		return spellSkill;
	}
	
	/**
	 * Spell Level sample
	 * <spellLevel name="Sonic Boom - niveau 1" spellId="1000999" coolDown="1" level="1" damage="10" icon="blue_06.png" description="Boom it hurts !" arg1="123456" />
	 * @param	node
	 * @return
	 */
	private function loadSpellLevel(node:Access):SpellLevel
	{
		if (!checkSpellLevelNode(node))
		{
			return null;
		}
		
		var name:String = node.att.name;
		var spellId:Int = Std.parseInt(node.att.spellId);
		var level:Int = Std.parseInt(node.att.level);
		var iconName:String = node.att.icon;
		var description:String = node.has.description ? node.att.description : "";
		var damage:Float = node.has.damage ? Std.parseFloat(node.att.damage) : 0;
		var coolDown:Float = node.has.coolDown ? Std.parseFloat(node.att.coolDown) : 0;
		var range:Float = node.has.range ? Std.parseFloat(node.att.range) : 0;
		var duration:Float = node.has.duration ? Std.parseFloat(node.att.duration) : 0;
		var areaAngle:Float = node.has.areaAngle ? Std.parseFloat(node.att.areaAngle) : 0;
		var height:Float = node.has.height ? Std.parseFloat(node.att.height) : 0;
		var areaWidth:Null<Float> = node.has.areaWidth ? Std.parseFloat(node.att.areaWidth) : null;
		var short:String = node.has.short ? node.att.short : "";
		
		// Damage type
		
		var damageType:DamageType = DMG_TYPE_NORMAL;
		if (node.has.dmgType)
		{
			switch (node.att.dmgType)
			{
				case "%":
					damageType = DamageType.DMG_TYPE_PERCENT_CURRENT;
				case "%max":
					damageType = DamageType.DMG_TYPE_PERCENT_MAX;
			}
		}
		
		return new SpellLevel(spellId, level, iconName, name, description, coolDown, damage, range, duration, areaAngle, height, areaWidth,
			damageType, short);
	}
	
	/**
	 * Renvoie un type de missile
	 * @param	type : id TMissile
	 * @return  null si erreur
	 */
	public function getTSpell(type:Int, clone:Bool = true):Spell
	{
		if (_lTSpells == null)
		{
			Log.error("_lTSpells null");
			return null;
		}
		
		if (!_lTSpells.exists(type))
		{
			Log.trace("ERROR can't find this kind of spell: " + type);
			return null;
		}
		
		var tSpell:Spell = _lTSpells[type];
		
		if (clone)
			tSpell = cast(tSpell.copyTo(), Spell);
		
		return tSpell;
	}
	
	public function isTSpellExists(spellId:Int):Bool
	{
		return _lTSpells.exists(spellId);
	}
	
	/**
	 * Renvoie un type de missile
	 * @param	type : id SpellSkill
	 * @return  null si erreur
	 */
	public function getTSpellSkill(type:Int, clone:Bool = true):SpellSkill
	{
		if (_lTSpellSkill == null)
		{
			Log.error("_lTSpellSkill null");
			return null;
		}
		
		if (!_lTSpellSkill.exists(type))
		{
			Log.error("ERROR can't find this kind of spell skill: " + type);
			return null;
		}
		
		var tSpellSkill:SpellSkill = _lTSpellSkill[type];
		
		if (clone)
			tSpellSkill = cast(tSpellSkill.copyTo(), SpellSkill);
		
		return tSpellSkill;
	}
	
	
	public function getTSpellSkillFromElements(elements:Array<Element>, clone:Bool = true):SpellSkill
	{
		if (_lTSpellSkill == null)
		{
			Log.error("_lTSpells null");
			return null;
		}
		
		elements.sort(Element.sort);
		
		var tSpellSkill:SpellSkill = _spellsByElements[elements[0]][elements[1]];
		
		if (clone && tSpellSkill != null)
			tSpellSkill = cast(tSpellSkill.copyTo(), SpellSkill);
		
		return tSpellSkill;
	}
	
	/**
	 * 
	 * @param	node
	 * @return
	 */
	public function checkSpellNode(node:Access):Bool
	{
		if (!DataManager.isValidGameObjectNode(node))
		{
			Log.error("invalid GameObject: " + node);
			return false;
		}
		
		if (!node.has.cmlscript)
		{
			Log.error("invalid GameObject, attribute missing: cmlscript");
			return false;
		}
		
		return true;
	}
	
	/**
	 * 
	 * @param	node
	 * @return
	 */
	public function checkSpellSkillNode(node:Access):Bool
	{
		if (!node.has.id)
		{
			Log.error("invalid SpellSkill node, attribute missing: id");
			return false;
		}
		
		if (!node.has.name)
		{
			Log.error("invalid SpellSkill node, attribute missing: name");
			return false;
		}
		
		return true;
	}
	
	/**
	 * 
	 * @param	node
	 * @return
	 */
	public function checkSpellLevelNode(node:Access):Bool
	{
		if (!node.has.name)
		{
			Log.error("invalid SpellSkill node, attribute missing: name");
			return false;
		}
		
		if (!node.has.spellId)
		{
			Log.error("invalid SpellSkill node, attribute missing: spellId");
			return false;
		}
		
		if (!node.has.level)
		{
			Log.error("invalid SpellSkill node, attribute missing: level");
			return false;
		}
		
		return true;
	}
	
	function get_spellScript():String 
	{
		return _spellScript;
	}
	
	
}
		
