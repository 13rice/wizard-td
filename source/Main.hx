package;

import flixel.FlxG;
import flixel.FlxGame;
import openfl.display.Sprite;
import save.PlayerAccount;

class Main extends Sprite
{
	public function new()
	{
		super();
		
		FlxG.fixedTimestep = true;
		
		PlayerAccount.get().loadConfiguration();
		PlayerAccount.get().loadPlayerDatas();
		
		addChild(new FlxGame(800, 480, PlayState));
	}
}
