package gameObject.fortress;

import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.group.FlxGroup;
import gameObject.fortress.Wall.WallType;

/**
 * ...
 * @author 13rice
 */
class Fortress extends FlxGroup {
	private var front:FlxSprite = new FlxSprite();

	public function new(MaxSize:Int = 0) {
		super(MaxSize);

		add(new Wall(WallType.TOWER, 500, 394, 1000));
	}

	override public function kill():Void {
		super.kill();

		exists = true;
	}
}