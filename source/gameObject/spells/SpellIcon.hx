package gameObject.spells;

import global.attribute.AttributeModifier;
import openfl.Assets;
import flixel.text.FlxBitmapText;
import flixel.graphics.frames.FlxBitmapFont;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;

/**
 * ...
 * @author 13rice
 */
class SpellIcon extends FlxSpriteGroup {
	public static var WIDTH:Int = 32;
	public static var HEIGHT:Int = 32;

	private var _icon:FlxSprite = null;

	private var _maskCoolDown:FlxSprite = null;

	public var spellLevel(default, set):SpellLevel;

	private var _spellLevel:SpellLevel = null;

	private var _txtCoolDown:FlxBitmapText = null;

	/** Remaining cooldown in seconds */
	public var timer(get, null):Float;

	private var _timer:Float = 0;

	public function new(X:Float = 0, Y:Float = 0, sl:SpellLevel) {
		super(X, Y, 0);

		_spellLevel = sl;

		_icon = new FlxSprite(0, 0);
		_icon.frames = PlayState.get().getAtlas(Constant.ATLAS_UI);
		_icon.animation.frameName = _spellLevel.iconName;
		_icon.updateHitbox();
		add(_icon);

		_maskCoolDown = new FlxSprite(0, 0);
		_maskCoolDown.makeGraphic(WIDTH, HEIGHT, 0xaa000000);
		_maskCoolDown.visible = false;
		_maskCoolDown.updateHitbox();
		add(_maskCoolDown);

		var bitmapFont = FlxBitmapFont.fromAngelCode(Constant.FONT_MEDIUM_DIGIT_BMP, Xml.parse(Assets.getText(Constant.FONT_MEDIUM_DIGIT_FNT)));
		_txtCoolDown = new FlxBitmapText(bitmapFont);
		_txtCoolDown.x = 0;
		_txtCoolDown.autoSize = false;
		_txtCoolDown.alignment = FlxTextAlign.CENTER;
		_txtCoolDown.fieldWidth = Std.int(_icon.width);
		_txtCoolDown.setBorderStyle(OUTLINE, FlxColor.BLACK, 1);
		_txtCoolDown.y = (_icon.height - _txtCoolDown.height) / 2 - 10;

		add(_txtCoolDown);
	}

	/**
	 * Launch the cooldown (if necessary)
	 */
	public function start(caster:Caster):Void {
		if (caster != null)
			_timer = PlayState.get().attributeController.calculateValue(AttributeType.SPELL_CASTING_RATE, caster.flags, _spellLevel.coolDown);
		else
			_timer = _spellLevel.coolDown;
		_txtCoolDown.visible = _timer > 0;
		_maskCoolDown.visible = _timer > 0;

		if (_maskCoolDown.visible) {
			_maskCoolDown.setGraphicSize(Std.int(_icon.width), Std.int(_icon.height));
			_maskCoolDown.setPosition(_icon.x, _icon.y);
		}
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		if (_timer > 0) {
			// Update cooldown Text
			var value:Int = 0;

			_timer -= elapsed;
			_timer = Math.max(_timer, 0);

			// Round value for textfield
			value = Math.round(_timer);

			if (_timer < 1) {
				value = Math.round(_timer * 10);

				if (value == 10)
					_txtCoolDown.text = "1"; // Display 1
				else
					_txtCoolDown.text = "0." + value; // Display 0.x
			} else {
				// Display X
				_txtCoolDown.text = value + "";
			}

			// Update cooldown mask
			var initialTimer:Float = _spellLevel.coolDown;
			var newHeight = Math.round((_timer / initialTimer) * _icon.height);

			if (newHeight > 0) {
				_maskCoolDown.setGraphicSize(Std.int(_icon.width), newHeight);
				_maskCoolDown.y = (_icon.height - newHeight) / 2 + y;
			}

			// End of cooldown
			if (_timer <= 0) {
				_txtCoolDown.visible = _maskCoolDown.visible = false;
			}
		}
	}

	function get_timer():Float {
		return _timer;
	}

	function set_spellLevel(value:SpellLevel):SpellLevel {
		// Nothing to do
		if (_spellLevel == value)
			return _spellLevel;

		// Refresh icon
		if (this.visible) {
			if (_icon == null) {
				_icon = new FlxSprite(0, 0);
				add(_icon);
			}

			_icon.frames = PlayState.get().getAtlas(Constant.ATLAS_UI);
			_icon.animation.frameName = _spellLevel.iconName;
		}

		return _spellLevel = value;
	}
}