package ui;

import flixel.math.FlxPoint;
import flixel.text.FlxBitmapText;
import flixel.graphics.frames.FlxBitmapFont;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import gameObject.spells.SpellLevel;
import gameObject.spells.SpellSkill;
import global.shared.Log;
import motion.Actuate;
import motion.easing.Sine;
import openfl.geom.Rectangle;
import openfl.text.AntiAliasType;
import openfl.Assets;

/**
 * Display a tooltip for a spell
 *
 * __________________________________________________
 * | <Titre>										|
 * | <Description>									|
 * | Niveau X: <description du niveau x>			|
 * | Niveau x + 1: <description du niveau x + 1> 	|
 * ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * @author 13rice
 */
class UISpellTooltip extends FlxSpriteGroup {
	public static var FONT_TITLE:String = "Venice Classic";
	public static var FONT_TEXT:String = "Retroville NC";
	private static var MARGIN:Int = 5;
	private static var WIDTH:Int = 5 * Constant.CELL_SIZE;

	/* Reference to the current spellskill displayed, with associate level etc. */
	private var _spellSkill:SpellSkill = null;

	/**
	 * Spell name
	 */
	private var _txtName:FlxBitmapText;

	/**
	 * Description de la compétence
	 */
	private var _txtDesc:FlxBitmapText;

	/**
	 * Texte:
	 		 * Niveau x
	 		 * Niveau x + 1
	 */
	private var _txtLevel:FlxBitmapText = null;

	private var _icoDamage:FlxSprite = null;
	private var _txtDamage:FlxBitmapText = null;
	private var _icoRange:FlxSprite = null;
	private var _txtRange:FlxBitmapText = null;

	/**
	 * Description des niveaux x et x + 1
	 */
	private var _txtLevelDesc:FlxText;

	public function new(X:Float, Y:Float) {
		super(X, Y, 0);

		var uiAtlas = PlayState.get().getAtlas(Constant.ATLAS_UI);

		// Name
		var bitmapFont = FlxBitmapFont.fromAngelCode(Constant.FONT_FANTASTIC_BMP, Xml.parse(Assets.getText(Constant.FONT_FANTASTIC_FNT)));
		_txtName = new FlxBitmapText(bitmapFont);
		_txtName.multiLine = true;
		_txtName.x = 0;
		_txtName.y = 5;
		_txtName.alignment = FlxTextAlign.CENTER;
		_txtName.fieldWidth = WIDTH;
		_txtName.wordWrap = true;
		_txtName.autoSize = false;
		_txtName.textColor = 0xFFCFC6B8;
		_txtName.useTextColor = true;
		_txtName.text = "Sword spell";
		add(_txtName);

		bitmapFont = FlxBitmapFont.fromAngelCode(Constant.FONT_SMALL_TEXT_BMP, Xml.parse(Assets.getText(Constant.FONT_SMALL_TEXT_FNT)));
		_txtDesc = new FlxBitmapText(bitmapFont);
		_txtDesc.multiLine = true;
		_txtDesc.x = 0;
		_txtDesc.y = 3 * Constant.CELL_SIZE;
		_txtDesc.fieldWidth = WIDTH;
		_txtDesc.wordWrap = true;
		_txtDesc.autoSize = false;
		_txtDesc.textColor = 0xFFCFC6B8;
		_txtDesc.useTextColor = true;
		_txtDesc.text = "Cast a chain lightning bouncing from enemy to enemy. Dealing 10 damage to each target.";
		add(_txtDesc);

		// Next level text
		bitmapFont = FlxBitmapFont.fromAngelCode(Constant.FONT_SMALL_TEXT_BMP, Xml.parse(Assets.getText(Constant.FONT_SMALL_TEXT_FNT)));
		_txtLevel = new FlxBitmapText(bitmapFont);
		_txtLevel.multiLine = true;
		_txtLevel.fieldWidth = WIDTH;
		_txtLevel.wordWrap = true;
		_txtLevel.autoSize = false;
		_txtLevel.x = 0;
		_txtLevel.y = 5 * Constant.CELL_SIZE;
		_txtLevel.textColor = 0xFFF4B41B;
		_txtLevel.useTextColor = true;
		add(_txtLevel);

		// DAMAGE
		_icoDamage = new FlxSprite(0, 1 * Constant.CELL_SIZE);
		_icoDamage.frames = uiAtlas;
		_icoDamage.animation.frameName = "ico_damage.png";
		add(_icoDamage);

		bitmapFont = FlxBitmapFont.fromAngelCode(Constant.FONT_SMALL_TEXT_BMP, Xml.parse(Assets.getText(Constant.FONT_SMALL_TEXT_FNT)));
		_txtDamage = new FlxBitmapText(bitmapFont);
		_txtDamage.x = 1 * Constant.CELL_SIZE + 6;
		_txtDamage.y = 1 * Constant.CELL_SIZE + 8;
		_txtDamage.fieldWidth = WIDTH - Constant.CELL_SIZE;
		_txtDamage.wordWrap = true;
		_txtDamage.autoSize = false;
		_txtDamage.textColor = 0xFFCFC6B8;
		_txtDamage.useTextColor = true;
		_txtDamage.text = "10 /s";
		_txtDamage.updateHitbox();
		add(_txtDamage);

		_icoRange = new FlxSprite(0, 2 * Constant.CELL_SIZE);
		_icoRange.frames = uiAtlas;
		_icoRange.animation.frameName = "ico_range.png";
		add(_icoRange);

		bitmapFont = FlxBitmapFont.fromAngelCode(Constant.FONT_SMALL_TEXT_BMP, Xml.parse(Assets.getText(Constant.FONT_SMALL_TEXT_FNT)));
		_txtRange = new FlxBitmapText(bitmapFont);
		_txtRange.x = 1 * Constant.CELL_SIZE + 6;
		_txtRange.y = 2 * Constant.CELL_SIZE + 8;
		_txtRange.fieldWidth = WIDTH - Constant.CELL_SIZE;
		_txtRange.wordWrap = true;
		_txtRange.autoSize = false;
		_txtRange.textColor = 0xFFCFC6B8;
		_txtRange.useTextColor = true;
		_txtRange.text = "4";
		add(_txtRange);

		visible = false;
	}

	override public function destroy():Void {
		_txtName = FlxDestroyUtil.destroy(_txtName);
		_txtDesc = FlxDestroyUtil.destroy(_txtDesc);
		_txtLevel = FlxDestroyUtil.destroy(_txtLevel);

		super.destroy();
	}

	public function display(spellSkill:SpellSkill) {
		visible = true;

		refresh(spellSkill);
	}

	public function refresh(spellSkill:SpellSkill) {
		_spellSkill = spellSkill;

		var spellLevel = _spellSkill.spellLevel;
		var nextLevel = _spellSkill.nextLevel;

		_txtName.text = spellLevel.name;

		_txtDamage.text = spellLevel.damage + "";
		_txtRange.text = spellLevel.areaWidth + "";

		_txtDesc.text = spellLevel.description;
		if (nextLevel != null && nextLevel.shortDescription != "") {
			_txtLevel.text = "Next level : " + nextLevel.shortDescription;
			_txtLevel.visible = true;
		} else {
			_txtLevel.visible = false;
		}
	}
}