package data;

import flixel.FlxG;
import global.TSound;
import global.shared.Log;
import haxe.ds.Map;
import haxe.xml.Access;


/**
 * Singleton
 * @author 13rice
 */
class DataSound
{
	
	// Chargement des données par XML
	private var _lTSounds:Map<Int /*id*/, TSound>;

	
	// Singleton
	private static var _instance = new DataSound();
	
	private function new()
	{
		_lTSounds = new Map<Int, TSound>();
	}
	
	public static function get():DataSound
	{
		return _instance;
	}
	
	/**
	 * Load all the spells datas from <spelldatas> node
	 * @param	node
	 */
	public function loadFromXML(node:Access):Void
	{
		if (node == null || node.name != "sounds")
		{
			trace("error loading xml data in DataSound");
			return;
		}
		
		// Sounds
		for (child in node.nodes.sound)
		{
			loadSound(child);
		}
	}
	
	/**
	 * Sound Sample
	 * 	<sound name="FirstWave" id="5000001" cmlscript="#SPEED1{v0.5, 0}
				{[[q$l1 * 15, $l * -15 n{4000001 &SPEED1}]10 ]2
				[q2 * 15, $l * -15 n{4000002 &SPEED1}]10}" />
	 * @param	node
	 * @return
	 */
	private function loadSound(node:Access):TSound
	{
		if (!checkSoundNode(node))
		{
			return null;
		}
		
		var id:Int = Std.parseInt(node.att.id);
		
		if (_lTSounds.exists(id))
			return _lTSounds[id];
		
		// Mandatory fields
		var src = (node.has.src ? node.att.src : "");
		var ext = (node.has.ext ? node.att.ext : "");
		
		
		// Optional
		var name = (node.has.name ? node.att.name : "");
		var volume = (node.has.volume ? Std.parseFloat(node.att.volume) : 1);
		var delay = (node.has.delay ? Std.parseFloat(node.att.delay) : 0);
		
		var tSound:TSound = new TSound(name, id, src, ext, volume, delay);
		
		_lTSounds[id] = tSound;
		
		return tSound;
	}
		
	/**
	 * Returns a wave definition
	 * @param	type : id TMissile
	 * @return  null si erreur
	 */
	public function getTSound(type:Int, clone:Bool = true):TSound
	{
		if (_lTSounds == null)
		{
			Log.error("_lTSounds null");
			return null;
		}
		
		if (!_lTSounds.exists(type))
		{
			Log.trace("ERROR can't find this kind of sound: " + type);
			return null;
		}
		
		var tSound:TSound = _lTSounds[type];
		
		/*
		if (clone)
			tWave = cast(tWave.copyTo(), Unit);
			*/
		
		return tSound;
	}
	
	public function isTSoundExists(waveId:Int):Bool
	{
		return _lTSounds.exists(waveId);
	}
		
	/**
	 * 
	 * @param	node
	 * @return
	 */
	public function checkSoundNode(node:Access):Bool
	{
		var result:Bool = true;
		
		if (!node.has.id)
		{
			Log.error("invalid Sound, attribute missing: id");
			result = false;
		}
		
		if (!node.has.src)
		{
			Log.error("invalid Sound, attribute missing: cmlScript");
			result = false;
		}
		
		if (!node.has.ext)
		{
			Log.error("invalid Sound, attribute missing: ext");
			result = false;
		}
		
		return true;
	}
	
	public function playSound(id:Int, volume:Float = 1.0)
	{
		var sound:TSound = getTSound(id);
		
		if (sound != null)
		{
			volume = volume * sound.volume;
			FlxG.sound.play('assets/sounds/${sound.source}.${sound.extension}', volume * sound.volume);
		}
	}
	
	
	/**
	 * Reset all Unit data
	 */
	public function reset()
	{
		_lTSounds = new Map<Int, TSound>();
	}
	
	
}
