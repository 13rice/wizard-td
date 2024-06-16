package ui;

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
class UILifeProgressBar extends FlxSpriteGroup {
	public static inline var WIDTH:Int = 56;
	public static inline var HEIGHT:Int = 56;

	public static inline var PROGRESS_BAR_SIZE:Int = 164;

	/** Reference to the player */
	private var _player:Player = null;

	private var _background:FlxSprite = null;

	private var _lifeStart:FlxSprite = null;
	private var _lifeRepeat:FlxSprite = null;
	private var _lifeEnd:FlxSprite = null;

	public var max(get, set):Int;

	private var _max:Int = 0;

	private var _count:Int = 0;
	private var _txtLife:FlxBitmapText = null;

	public function new(X:Float = 0, Y:Float = 0, player:Player) {
		super(X, Y);

		_player = player;

		// Load the images from atlas
		var uiAtlas = PlayState.get().getAtlas(Constant.ATLAS_UI);

		// Background
		_background = new FlxSprite();
		_background.frames = uiAtlas;
		_background.animation.frameName = "pb_life_background.png";
		_background.updateHitbox();

		// Spawn progress bar ===============
		_lifeStart = new FlxSprite();
		_lifeStart.frames = uiAtlas;
		_lifeStart.animation.frameName = "pb_life_start.png";
		_lifeStart.updateHitbox();
		_lifeStart.x = 6;
		_lifeStart.y = 6;

		_lifeRepeat = new FlxSprite();
		_lifeRepeat.frames = uiAtlas;
		_lifeRepeat.animation.frameName = "pb_life_repeat.png";
		_lifeRepeat.updateHitbox();
		_lifeRepeat.x = 9;
		_lifeRepeat.y = 6;
		_lifeRepeat.origin.x = 0;

		_lifeEnd = new FlxSprite();
		_lifeEnd.frames = uiAtlas;
		_lifeEnd.animation.frameName = "pb_life_end.png";
		_lifeEnd.updateHitbox();
		_lifeEnd.y = 6;

		// Percent counter
		var bitmapFont = FlxBitmapFont.fromAngelCode(Constant.FONT_SMALL_DIGIT_BMP, Xml.parse(Assets.getText(Constant.FONT_SMALL_DIGIT_FNT)));
		_txtLife = new FlxBitmapText(bitmapFont);
		_txtLife.x = 0;
		_txtLife.y = 10;
		_txtLife.autoSize = false;
		_txtLife.alignment = FlxTextAlign.CENTER;
		_txtLife.fieldWidth = Std.int(_background.width);
		_txtLife.setBorderStyle(OUTLINE, FlxColor.BLACK, 1);

		add(_background);

		add(_lifeStart);
		add(_lifeRepeat);
		add(_lifeEnd);

		add(_txtLife);

		PlayState.get().add(this);

		_lifeStart.visible = _lifeRepeat.visible = _lifeEnd.visible = false;
	}

	override function update(elapsed:Float):Void {
		var newScale = Math.round((_player.life / _player.lifeMax) * PROGRESS_BAR_SIZE);

		// Update scale of repeat pattern
		_lifeRepeat.scale.x = newScale;

		// Move start chunk
		_lifeEnd.x = _lifeRepeat.x + _lifeRepeat.scale.x;

		// Change visibility (for first call)
		_lifeStart.visible = _lifeRepeat.visible = _lifeEnd.visible = (_player.life > 0);
		// Percent of life displayed
		_txtLife.text = _player.life + "";
	}

	@:noCompletion
	function get_max():Int {
		return _max;
	}

	@:noCompletion
	function set_max(value:Int):Int {
		return _max = value;
	}
}