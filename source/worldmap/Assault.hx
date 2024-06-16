package worldmap;

import save.PlayerAccount;

/**
 * ...
 * @author 13rice
 */
class Assault {
	/** Number of Waves and waves by assaults for this level */
	public var waves(default, null):Array<Wave>;

	public var waveCount(get, null):Int;

	public var assaultId:Int;

	public var currentWaveId(default, null):Int;

	public function new(id:Int, waves:Array<Wave>) {
		assaultId = id;
		this.waves = waves;

		currentWaveId = 0;
	}

	public function nextWave():Wave {
		currentWaveId++;

		if (currentWaveId < waves.length)
			return waves[currentWaveId];

		return null;
	}

	function get_waveCount():Int {
		return waves != null ? waves.length : 0;
	}
}