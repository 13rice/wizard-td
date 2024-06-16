package save;

import global.attribute.AttributeController;
import gameObject.GameObject;
import global.shared.Log;
import haxe.ds.Map;
import haxe.xml.Access;
import openfl.net.SharedObject;
import openfl.utils.Object;
import uuid.Uuid;

/**
 * ...
 * @author 13rice
 */
class PlayerAccount {
	public static var MOBILE_MODE:Bool = false;

	public var _sharedObject:SharedObject = null;

	/**
	 * 
	 * Length: 36
	 * @persistant
	 */
	public var UID(default, null):String;

	/**
	 * @persistant
	 */
	public var soundLevel(get, set):Float;

	private var _soundLevel:Float;

	/**
	 * @persistant
	 */
	public var musicLevel(get, set):Float;

	private var _musicLevel:Float;

	/**
	 * @persistant
	 */
	public var pseudo(get, set):String;

	private var _pseudo:String;

	/**
	 * Stats du joueur, actualisé à chaque chargement
	 * Stat / Valeur
	 * @persistant
	 */
	private var _playerStats:Map<String, Int>;

	/**
	 * Nombre de gemmes actuel
	 * @persistant
	 */
	public var money(get, set):Int;

	private var _money:Int;

	/**
	 * ID TEnemy / count
	 */
	private var _kills:Map<Int, Int>;

	public var player(get, set):Player;

	private var _player:Player;

	// Singleton
	private static var _aka:PlayerAccount = new PlayerAccount();

	public static function get():PlayerAccount {
		return _aka;
	}

	private function new() {
		_playerStats = new Map();

		_money = 0;
		UID = "";
	}

	public function loadValue(name:String):Object {
		return Reflect.field(_sharedObject.data, name);
	}

	public function loadConfiguration() {
		if (_sharedObject != null)
			return;

		// Current configuration
		_sharedObject = SharedObject.getLocal("__YouShallNotPass__");

		if (_sharedObject == null)
			trace("[ERROR] unable to load configuration");
		else {
			if (_sharedObject.data.soundlevel != null)
				_soundLevel = _sharedObject.data.soundlevel;
			else
				soundLevel = 0.2;

			if (_sharedObject.data.musiclevel != null)
				_musicLevel = _sharedObject.data.musiclevel;
			else
				musicLevel = 0.2;

			if (_sharedObject.data.pseudo != null)
				_pseudo = _sharedObject.data.pseudo;
			else
				pseudo = "Enter Your Name";

			if (_sharedObject.data.money != null)
				_money = _sharedObject.data.money;
			else
				money = 0;

			if (_sharedObject.data.UID != null)
				UID = _sharedObject.data.UID;
			else {
				UID = Uuid.nanoId();
				// saveValue("UID", UID);
			}

			var testUID = loadValue("UID");

			Log.trace('Player UID $UID');

			////////// TEST /////////
			/*_totalXp = 0;
				_xp = 0; */

			//////////////////

			Log.trace("");
		}
	}

	public function loadPlayerDatas() {
		// Stats
		if (_sharedObject.data.stats != null) {
			var stats:Xml = Xml.parse(_sharedObject.data.stats);
			loadPlayerStats(stats.firstElement());
			stats = null;

			Log.trace(_playerStats.toString());
		}

		// Player achievevements
		loadPlayerAchievements();
	}

	/**
	 * Avoid calling this during the game, it makes lag !
	 * Calls it during pause, end screen etc.
	 */
	public function flush() {
		_sharedObject.flush();
	}

	/**
		* Charge les stats depuis la réponse XML
		* Structure:
		* <stats>
					<stat> [N segments]
						<name>String</id>
						<value>Int</type>
					</stat>
				</stats>
		* @param	stats
	 */
	private function loadPlayerStats(stats:Xml):Void {
		var name:String = "";
		var value:Int = 0;

		// Retire l'ensemble des stats chargées auparavant
		for (key in _playerStats.keys()) {
			_playerStats.remove(key);
		}

		for (statNode in stats.elementsNamed("stat")) {
			for (statData in statNode.elements()) {
				switch (statData.nodeName) {
					case "name":
						name = statData.firstChild().nodeValue;
					case "value":
						value = Std.parseInt(statData.firstChild().nodeValue);
				}
			}

			_playerStats.set(name, value);
		}
	}

	/**
		* Sauvegare les stats au format XML
		* Structure:
		* <stats>
					<stat> [N segments]
						<name>String</id>
						<value>Int</type>
					</stat>
				</stats>
	 */
	public function saveStats():Xml {
		var xml:Xml = Xml.createDocument();
		var stats = Xml.createElement("stats");
		xml.addChild(stats);

		var statNode:Xml = null;
		var nameNode:Xml = null;
		var valueNode:Xml = null;

		for (key in _playerStats.keys()) {
			statNode = Xml.createElement("stat");
			nameNode = Xml.createElement("name");
			nameNode.addChild(Xml.createPCData(key));

			valueNode = Xml.createElement("value");
			valueNode.addChild(Xml.createPCData(_playerStats[key] + ""));

			statNode.addChild(nameNode);
			statNode.addChild(valueNode);

			stats.addChild(statNode);
		}

		_sharedObject.setProperty("stats", xml.toString());

		return xml;
	}

	/**
		* Charge les objets depuis la réponse XML
		* Structure:
		* <items>
					<item> [N segments]
						[...]
					</item>
				</items>
		* @param	items Xml configuration
	 */
	private function loadItems(items:Access):Void {
		/*var item:Item = null;

			// Retire l'ensemble des items chargées auparavant
			for (item in _items)
			{
				_items.remove(item.id);
				item.remove();
			}

			if (items.name != "items")
			{
				Log.error("Invalid node name: " + items.name);
				return;
			}

			for (itemNode in items.nodes.item)
			{
				// Création de l'objet
				item = new Item();
				item.loadFromXml(itemNode);
				
				_items.set(item.id, item);
		}*/
	}

	/**
		* Charge les achievements depuis la réponse XML
		* Structure:
		* <achievements>
					<achievement> [N segments]
						[...]
					</achievement>
				</achievements>
		* @param	achievements Xml configuration
	 */
	private function loadAchievements(achievements:Access):Void {
		/*var achievement:AchievementBase = null;

			// Retire l'ensemble des achievements chargés auparavant
			for (achievement in _achievements)
			{
				_achievements.remove(achievement.id);
				achievement.remove();
			}

			if (achievements.name != "achievements")
			{
				Log.error("Invalid node name: " + achievements.name);
				return;
			}

			for (achievementNode in achievements.nodes.achievement)
			{
				// Création de l'achievement
				achievement = AchievementFactory.instance.createAchievement();
				achievement.loadFromXml(achievementNode.x);
				
				_achievements.set(achievement.id, achievement);
		}*/
	}

	/**
	 * 
	 */
	private function loadPlayerAchievements():Void {
		/*if (_sharedObject.data.achievements != null)
			{
				_achievementsUnlocked = _sharedObject.data.achievements.split(",").map(Std.parseInt);
				
				if (_achievements != null)
				{
					// Unlock the achievements
					for (idAchievement in _achievementsUnlocked)
					{
						_achievements[idAchievement].unlockedBefore();
					}
				}
		}*/
	}

	/**
		* Sauvegare les missions au format XML
		* Structure:
		* <missions>
					<mission> [N segments]
						[...]
					</mission>
				</missions>
				</stats>
	 */
	public function savePlayerMissions():Xml {
		var xml:Xml = Xml.createDocument();
		/*var missions = Xml.createElement("missions");
			xml.addChild(missions);

			var missionNode:Xml = null;

			for (mission in _currentMissions)
			{
				// Save if enabled
				if (mission.status != Mission.SUCCESS)
				{
					missionNode = mission.toXml(true);
					missions.addChild(missionNode);
				}
			}

			_sharedObject.setProperty("missions", xml.toString()); */

		return xml;
	}

	/**
	 * Renvoi une statistique du joueur, ex: kill_class1, kill_total etc.
	 * @param	stat
	 * @return valeur de la statistique, 0 si non trouvé
	 */
	public function getPlayerStat(stat:String):Int {
		var result:Int = 0;

		if (_playerStats == null) {
			Log.error("ERREUR: _playerStats NULL !");
			return result;
		}

		if (_playerStats.exists(stat)) {
			result = _playerStats.get(stat);
		}

		return result;
	}

	public function setPlayerStat(stat:String, value:Int):Void {
		_playerStats.set(stat, value);
	}

	/**
	 * 
	 * @param	stat to modify
	 * @param	add to the current value (can be negative)
	 * @return new value
	 */
	public function addPlayerStat(stat:String, add:Int):Int {
		var value:Int = getPlayerStat(stat);
		value += add;
		setPlayerStat(stat, value);

		return value;
	}

	public function saveValue(name:String, value:Object, flush:Bool = true):Void {
		_sharedObject.setProperty(name, value);

		if (flush)
			this.flush();
	}

	public function toString():String {
		var text:String = 'Pseudo : $_pseudo\nsoundLevel : $_soundLevel\nmusicLevel : $_musicLevel';
		// text += '\nmissions completed : [${_missionsCompleted.join(", ")}]';

		return text;
	}

	/**
	 * Call after a new game is launched
	 * @event
	 */
	public function onNewGame():Void {
		Log.trace("");
	}

	/**
	 * Call after these events:
	 * 	- Restart
	 *  - Defeat (before save)
	 * @event
	 */
	public function onEndGame(score:Int):Void {
		Log.trace("");
	}

	/////////////////////////////////////////////////////////////////////
	///	SETTERS / GETTERS
	/////////////////////////////////////////////////////////////////////

	function get_soundLevel():Float {
		return _soundLevel;
	}

	function set_soundLevel(value:Float):Float {
		saveValue("soundlevel", value);
		return _soundLevel = value;
	}

	function get_musicLevel():Float {
		return _musicLevel;
	}

	function set_musicLevel(value:Float):Float {
		saveValue("musiclevel", value);
		return _musicLevel = value;
	}

	function get_pseudo():String {
		return _pseudo;
	}

	function set_pseudo(value:String):String {
		saveValue("pseudo", value);
		return _pseudo = value;
	}

	function get_player():Player {
		return _player;
	}

	function set_player(value:Player):Player {
		return _player = value;
	}

	function get_money():Int {
		return _money;
	}

	function set_money(value:Int):Int {
		saveValue("money", value);
		return _money = value;
	}

	/////////////////////////////////////////////////////////////////////
	///	TEST
	/////////////////////////////////////////////////////////////////////

	public function deleteAll():Void {
		_sharedObject.clear();

		_sharedObject = null;

		loadConfiguration();
	}
}