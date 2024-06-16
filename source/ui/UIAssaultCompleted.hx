package ui;

import openfl.Assets;
import flixel.text.FlxBitmapText;
import flixel.graphics.frames.FlxBitmapFont;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import openfl.geom.Rectangle;

/**
 * For Victory or Defeat
 * @author 13rice
 */
class UIAssaultCompleted extends FlxSpriteGroup {
	public static inline var WIDTH:Int = 244;
	public static inline var HEIGHT:Int = 120;

	var victory:Bool = true;

	var mask:FlxSprite = null;
	var panel:FlxUI9SliceSprite = null;

	var title:FlxBitmapText = null;

	var logo:FlxSprite = null;

	var frameWave:FlxSprite = null;

	var iconWave:FlxSprite = null;

	var waveText:FlxBitmapText = null;

	var frameTime:FlxSprite = null;

	var iconTime:FlxSprite = null;

	var timeText:FlxBitmapText = null;

	var btnRetry:FlxButton = null;

	public function new(X:Float = 0, Y:Float = 0, MaxSize:Int = 0) {
		super(X, Y, MaxSize);

		var uiAtlas = PlayState.get().getAtlas(Constant.ATLAS_UI);

		mask = new FlxSprite(0, 0);
		mask.makeGraphic(FlxG.width + 200, FlxG.height + 200, Constant.BLACK_MASK);
		mask.x -= 100;
		mask.y -= 100;

		// x1, y1, x2, y2
		var sliceArray = [12, 12, 76, 44];

		// FRAME ===================================================
		panel = new FlxUI9SliceSprite(FlxG.width / 2 - WIDTH / 2, FlxG.height / 2 - HEIGHT / 2, uiAtlas.getByName("go_assault_frame.png").paint(),
			new Rectangle(0, 0, WIDTH, HEIGHT), sliceArray);

		var bitmapFont = FlxBitmapFont.fromAngelCode(Constant.FONT_FANTASTIC_BMP, Xml.parse(Assets.getText(Constant.FONT_FANTASTIC_FNT)));
		title = new FlxBitmapText(bitmapFont);
		title.x = panel.x + 6;
		title.y = panel.y + 12;
		title.autoSize = false;
		title.alignment = FlxTextAlign.CENTER;
		title.fieldWidth = WIDTH;
		title.setBorderStyle(OUTLINE, 0xFF7A444A, 1);
		title.scale.set(2, 2);

		logo = new FlxSprite(panel.x + 30, panel.y + 8);
		logo.frames = uiAtlas;
		logo.animation.frameName = "logo_defeat.png";

		// TIME ================
		frameTime = new FlxSprite(panel.x + 60, panel.y + 83);
		frameTime.frames = uiAtlas;
		frameTime.animation.frameName = "frame_score_small.png";
		frameTime.updateHitbox();

		iconTime = new FlxSprite(frameTime.x + 9, frameTime.y + 3);
		iconTime.frames = uiAtlas;
		iconTime.animation.frameName = "clock.png";

		bitmapFont = FlxBitmapFont.fromAngelCode(Constant.FONT_FANTASTIC_BMP, Xml.parse(Assets.getText(Constant.FONT_FANTASTIC_FNT)));
		timeText = new FlxBitmapText(bitmapFont);
		timeText.x = iconTime.x;
		timeText.y = frameTime.y + 2;
		timeText.autoSize = false;
		timeText.alignment = FlxTextAlign.CENTER;
		timeText.fieldWidth = Std.int(frameTime.width);
		timeText.useTextColor = true;
		timeText.textColor = 0xFFFCF0E5;
		timeText.letterSpacing = 1;
		timeText.setBorderStyle(OUTLINE, 0xFF74563C, 1);
		timeText.text = "00:00";

		// WAVES ==================
		frameWave = new FlxSprite(panel.x + 60, panel.y + 50);
		frameWave.frames = uiAtlas;
		frameWave.animation.frameName = "frame_score_small.png";
		frameWave.updateHitbox();

		iconWave = new FlxSprite(frameWave.x + 9, frameWave.y + 3);
		iconWave.frames = uiAtlas;
		iconWave.animation.frameName = "level_swords.png";

		bitmapFont = FlxBitmapFont.fromAngelCode(Constant.FONT_FANTASTIC_BMP, Xml.parse(Assets.getText(Constant.FONT_FANTASTIC_FNT)));
		waveText = new FlxBitmapText(bitmapFont);
		waveText.x = iconWave.x;
		waveText.y = frameWave.y + 2;
		waveText.autoSize = false;
		waveText.alignment = FlxTextAlign.CENTER;
		waveText.fieldWidth = Std.int(frameWave.width);
		waveText.useTextColor = true;
		waveText.textColor = 0xFFFCF0E5;
		waveText.setBorderStyle(OUTLINE, 0xFF74563C, 1);
		waveText.text = "0 / 3";

		// RETRY ================================
		var btnFrames = new FlxFramesCollection(uiAtlas.parent, uiAtlas.type, uiAtlas.border);
		btnFrames.frames.push(uiAtlas.getByName("accept_std_released.png"));
		btnFrames.frames.push(uiAtlas.getByName("accept_std_hover.png"));
		btnFrames.frames.push(uiAtlas.getByName("accept_std_pressed.png"));

		btnRetry = new FlxButton(panel.x + 150, panel.y + 62);
		btnRetry.frames = btnFrames;

		btnRetry.onUp.callback = onRetry;

		add(mask);

		add(panel);
		add(logo);
		add(title);

		// add(frameWave);
		// add(iconWave);
		add(waveText);

		// add(iconTime);
		add(timeText);

		add(btnRetry);

		PlayState.get().add(this);

		visible = false;
	}

	/**
	 * 
	 * @param	timeSec elapsed time of the assault in seconds
	 * @param 	currentWave for defeat
	 */
	public function display(timeSec:Int, wavesCleared:Int = 0, waveCount:Int = 0) {
		visible = true;

		logo.animation.frameName = "logo_defeat.png";
		title.text = "Defeat";

		waveText.text = '$wavesCleared / $waveCount';

		timeText.text = "00:00";

		var min = Std.int(timeSec / 60);
		var sec = Std.int(timeSec % 60);
		timeText.text = (min < 10 ? "0" : "") + min + ":" + (sec < 10 ? "0" : "") + sec;
	}

	private function onRetry():Void {
		PlayState.get().retryAssault();
	}
}