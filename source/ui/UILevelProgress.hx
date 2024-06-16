package ui;

import worldmap.Assault;
import openfl.Assets;
import flixel.graphics.frames.FlxBitmapFont;
import flixel.text.FlxBitmapText;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;

/**
 * ...
 * @author 13rice
 */
class UILevelProgress extends FlxSpriteGroup {
	public static inline var WIDTH:Int = 128;
	public static inline var HEIGHT:Int = 32;

	private var _background:FlxSprite = null;

	private var _assault:Assault = null;

	private var _previousLevel:Int = 0;
	private var _txtLevel:FlxBitmapText = null;

	public function new(X:Float = 0, Y:Float = 0, assault:Assault) {
		super(X, Y);

		_assault = assault;

		// Load the images from atlas
		var uiAtlas = PlayState.get().getAtlas(Constant.ATLAS_UI);

		// Background
		_background = new FlxSprite();
		_background.frames = uiAtlas;
		_background.animation.frameName = "pb_level_background.png";
		_background.updateHitbox();

		// Percent counter
		var bitmapFont = FlxBitmapFont.fromAngelCode(Constant.FONT_SMALL_DIGIT_BMP, Xml.parse(Assets.getText(Constant.FONT_SMALL_DIGIT_FNT)));
		_txtLevel = new FlxBitmapText(bitmapFont);
		_txtLevel.x = 0;
		_txtLevel.y = 10;
		_txtLevel.autoSize = false;
		_txtLevel.alignment = FlxTextAlign.CENTER;
		_txtLevel.fieldWidth = Std.int(_background.width);
		_txtLevel.setBorderStyle(OUTLINE, FlxColor.BLACK, 1);

		add(_background);

		add(_txtLevel);

		PlayState.get().add(this);
	}

	override function update(elapsed:Float):Void {
		var currentLevel = _assault.currentWaveId + 1;

		if (currentLevel != _previousLevel) {
			_txtLevel.text = 'Level : $currentLevel / 48';
			_previousLevel = currentLevel;
		}
	}
}