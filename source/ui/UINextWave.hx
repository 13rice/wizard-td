package ui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.group.FlxSpriteGroup;
import flixel.ui.FlxButton;
import motion.Actuate;
import motion.easing.Expo;

/**
 * ...
 * @author 13rice
 */
class UINextWave extends FlxSpriteGroup {
	public static inline var WIDTH:Int = 88;
	public static inline var HEIGHT:Int = 56;

	var mask:FlxSprite = null;

	var sword:FlxSprite = null;

	var staff:FlxSprite = null;

	var btnGoAssault:FlxButton = null;

	var playNormal:FlxSprite = null;

	var playOver:FlxSprite = null;

	public function new(X:Float = 0, Y:Float = 0, MaxSize:Int = 0) {
		super(X, Y, MaxSize);

		var uiAtlas = PlayState.get().getAtlas(Constant.ATLAS_UI);

		mask = new FlxSprite(0, 0);
		mask.makeGraphic(FlxG.width + 200, HEIGHT, 0x99000000);
		mask.x -= mask.width / 2;

		sword = new FlxSprite(20, 20);
		sword.frames = uiAtlas;
		sword.animation.frameName = "go_assault_sword.png";
		sword.origin.set(8, 8);

		staff = new FlxSprite(20, 20);
		staff.frames = uiAtlas;
		staff.animation.frameName = "go_assault_staff.png";
		staff.origin.set(8, 8);

		var btnFrames = new FlxFramesCollection(uiAtlas.parent, uiAtlas.type, uiAtlas.border);
		btnFrames.frames.push(uiAtlas.getByName("go_assault_frame.png"));

		btnGoAssault = new FlxButton();
		btnGoAssault.frames = btnFrames;

		btnGoAssault.onOver.callback = onOverGoAssault;
		btnGoAssault.onOut.callback = onOutGoAssault;
		btnGoAssault.onUp.callback = nextWave;

		playNormal = new FlxSprite(52, 11);
		playNormal.frames = uiAtlas;
		playNormal.animation.frameName = "go_assault_btn_play.png";

		playOver = new FlxSprite(52, 11);
		playOver.frames = uiAtlas;
		playOver.animation.frameName = "go_assault_btn_play_hover.png";

		Actuate.tween(playNormal, 0.4, {x: this.x + 62}).reflect().repeat().ease(Expo.easeIn);
		Actuate.tween(playOver, 0.4, {x: this.x + 62}).reflect().repeat().ease(Expo.easeIn);

		add(mask);
		add(btnGoAssault);
		add(playNormal);
		add(playOver);

		add(sword);
		add(staff);

		PlayState.get().add(this);

		visible = false;
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
	}

	// @:setter(visible)
	override function set_visible(value:Bool):Bool {
		super.set_visible(value);

		if (value) {
			sword.scale.set(8, 8);
			staff.scale.set(8, 8);
			staff.visible = false;

			Actuate.tween(sword.scale, 1, {x: 2, y: 2});
			Actuate.tween(staff.scale, 1, {x: 2, y: 2}).delay(0.5);
			Actuate.timer(0.4).onComplete(function() {
				staff.visible = true;
			});
		}

		playOver.visible = false;

		return visible;
	}

	private function nextWave():Void {
		PlayState.get()._goNextWave = true;
	}

	private function onOverGoAssault():Void {
		playNormal.visible = false;
		playOver.visible = true;
	}

	private function onOutGoAssault():Void {
		playNormal.visible = true;
		playOver.visible = false;
	}
}