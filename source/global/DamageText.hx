package global;

import flixel.group.FlxGroup.FlxTypedGroup;
import openfl.Assets;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.text.FlxText.FlxTextAlign;
import flixel.graphics.frames.FlxBitmapFont;
import flixel.text.FlxBitmapText;

class DamageText extends FlxBitmapText {
	private static var bitmapFont:FlxBitmapFont = null;

	private static var damageTexts:FlxTypedGroup<DamageText> = new FlxTypedGroup();

	private static function createDamageText():DamageText {
		var txt = new DamageText(bitmapFont);

		txt.autoSize = false;
		txt.alignment = FlxTextAlign.CENTER;
		txt.fieldWidth = 20;
		txt.setBorderStyle(OUTLINE, 0xAA000000, 1);
		txt.useTextColor = true;
		return txt;
	}
	public static function create(x:Float, y:Float, damage:Float, critical:Bool):DamageText {
		if (damage < 1)
			return null;

		if (bitmapFont == null) {
			bitmapFont = FlxBitmapFont.fromAngelCode(Constant.FONT_SMALL_DIGIT_BMP, Xml.parse(Assets.getText(Constant.FONT_SMALL_DIGIT_FNT)));
			PlayState.get().add(damageTexts);
		}

		var txt = damageTexts.recycle(null, DamageText.createDamageText);
		txt.font = bitmapFont;
		txt.x = x - 8;
		txt.y = y - 10;
		txt.textColor = (critical ? 0xffffdd00 : 0xffffffff);
		txt.text = Math.floor(damage) + "";
		txt.scale.set(0.5, 0.5);
		FlxTween.tween(txt, {"scale.x": critical ? 1.2 : 1, "scale.y": critical ? 1.2 : 1}, 0.2, {ease: FlxEase.backOut});
		FlxTween.tween(txt, {x: txt.x - 5 + Math.random() * 10, y: txt.y - 15}, 0.3, {
			ease: FlxEase.cubeOut,
			onComplete: function(_) {
				txt.kill();
			}
		});
		/*FlxTween.tween(txt, {x: txt.x}, 0.3, {
			onComplete: function(_) {
				txt.kill();
			}
		});*/

		return txt;
	}
}