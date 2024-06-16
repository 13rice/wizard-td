package data;

import gameObject.Unit;
import gameObject.items.ItemScroll.Element;
import global.shared.Log;
import haxe.ds.Map;
import haxe.xml.Access;


/**
 * Singleton
 * @author 13rice
 */
@:allow(Unit)
class DataUnit
{
	
	/**
	 * All CannonML Sequences for units
	 */
	public var unitScript(get, never):String;
	private var _unitScript:String = "";
	
	// Chargement des données par XML
	private var _lTWaves:Map<Int /*id*/, Unit>;
	
	// Chargement des données par XML
	private var _lTUnits:Map<Int /*id*/, Unit>;

	
	// Singleton
	private static var _instance = new DataUnit();
	
	private function new()
	{
		_lTWaves = new Map<Int, Unit>();
		_lTUnits = new Map<Int, Unit>();
	}
	
	public static function get():DataUnit
	{
		return _instance;
	}
	
	/**
	 * Load all the spells datas from <spelldatas> node
	 * @param	node
	 */
	public function loadFromXML(node:Access):Void
	{
		if (node == null || node.name != "unitdatas")
		{
			trace("error loading xml data in DataUnit");
			return;
		}
		
		// Waves
		for (child in node.node.waves.nodes.wave)
		{
			loadWave(child);
		}
		
		// Units
		for (child in node.node.units.nodes.unit)
		{
			loadUnit(child);
		}
	}
	
	/**
	 * Wave Sample
	 * 	<wave name="FirstWave" id="5000001" cmlscript="#SPEED1{v0.5, 0}
				{[[q$l1 * 15, $l * -15 n{4000001 &SPEED1}]10 ]2
				[q2 * 15, $l * -15 n{4000002 &SPEED1}]10}" />
	 * @param	node
	 * @return
	 */
	private function loadWave(node:Access):Unit
	{
		if (!checkWaveNode(node))
		{
			return null;
		}
		
		var id:Int = Std.parseInt(node.att.id);
		
		if (_lTWaves.exists(id))
			return _lTWaves[id];
		
		var wave:Unit = new Unit(0, 0, 0, false, false, true);
		
		wave.initWave(id, node.att.name, node.att.cmlScript, Std.parseInt(node.att.unitCount));
		
		_lTWaves[id] = wave;
		
		// Add the script to the master wave script
		_unitScript += wave.cmlScript;
		
		return wave;
	}
	
	/**
	 * Unit sample
	 * <unit id="4000001" name="spearman" displayName="Spearman" hp="30" tinyId="0"/>
	 * @param	node
	 * @return
	 */
	private function loadUnit(node:Access):Unit
	{
		if (!checkUnitNode(node))
		{
			return null;
		}
		
		var id:Int = Std.parseInt(node.att.id);
		
		if (_lTUnits.exists(id))
			return _lTUnits[id];
		
		var unit:Unit = new Unit(0, 0, Std.parseFloat(node.att.hp), false, false, true);
		
		unit.initTemplateFromNode(node);
		
		_lTUnits[id] = unit;
		
		return unit;
	}
		
	/**
	 * Returns a wave definition
	 * @param	type : id TMissile
	 * @return  null si erreur
	 */
	public function getTWave(type:Int, clone:Bool = true):Unit
	{
		if (_lTWaves == null)
		{
			Log.error("_lTWaves null");
			return null;
		}
		
		if (!_lTWaves.exists(type))
		{
			Log.trace("ERROR can't find this kind of wave: " + type);
			return null;
		}
		
		var tWave:Unit = _lTWaves[type];
		
		if (clone)
			tWave = cast(tWave.copyTo(), Unit);
		
		return tWave;
	}
	
	public function isTWaveExists(waveId:Int):Bool
	{
		return _lTWaves.exists(waveId);
	}
	
	/**
	 * Renvoie un type de missile
	 * @param	type : id SpellSkill
	 * @return  null si erreur
	 */
	public function getTUnit(type:Int, clone:Bool = true):Unit
	{
		if (_lTUnits == null)
		{
			Log.error("_lTUnits null");
			return null;
		}
		
		if (!_lTUnits.exists(type))
		{
			Log.error("ERROR can't find this kind of unit : " + type);
			return null;
		}
		
		var tUnit:Unit = _lTUnits[type];
		
		if (clone)
		{
			tUnit = cast(tUnit.copyTo(), Unit);
		}
		
		return tUnit;
	}
	
	/**
	 * 
	 * @param	node
	 * @return
	 */
	public function checkWaveNode(node:Access):Bool
	{
		if (!node.has.id)
		{
			Log.error("invalid Wave, attribute missing: id");
			return false;
		}
		
		if (!node.has.cmlScript)
		{
			Log.error("invalid Wave, attribute missing: cmlScript");
			return false;
		}
		
		if (!node.has.unitCount)
		{
			Log.error("invalid Wave, attribute missing: unitCount");
			return false;
		}
		
		return true;
	}
	
	/**
	 * 
	 * @param	node
	 * @return
	 */
	public function checkUnitNode(node:Access):Bool
	{
		if (!node.has.id)
		{
			Log.error("invalid Unit node, attribute missing: id");
			return false;
		}
		
		if (!node.has.name)
		{
			Log.error("invalid Unit node, attribute missing: name");
			return false;
		}
		
		if (!node.has.hp)
		{
			Log.error("invalid Unit node, attribute missing: hp");
			return false;
		}
		
		return true;
	}
	
	/**
	 * Reset all Unit data
	 */
	public function reset()
	{
		_lTWaves = new Map<Int, Unit>();
		_lTUnits = new Map<Int, Unit>();
		
		_unitScript = "";
	}
	
	function get_unitScript():String 
	{
		return _unitScript;
	}
	
	
}
