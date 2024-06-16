package ui;

import flixel.ui.FlxButton;
import flixel.graphics.frames.FlxFramesCollection;
import effect.Effect;
import lime.utils.Assets;
import flixel.text.FlxBitmapText;
import flixel.graphics.frames.FlxBitmapFont;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import gameObject.items.ItemScroll.Element;
import global.shared.Log;
import haxe.ds.Map;
import motion.Actuate;
import motion.easing.Cubic;

class UIScroll {
	private var _txtCount:FlxBitmapText = null;

	public var count(get, set):Int;

	private var _count:Int = 0;

	public var element(get, null):Element;

	private var _element:Element = Element.NONE;

	private var _index:Int = 0;

	private var _icon:FlxButton = null;

	private var _ui:UIGameScrolls = null;

	private var _over:Bool = false;

	public var x:Int = 0;

	public var y:Int = 0;

	public function new(ui:UIGameScrolls, element:Element, count:Int, index:Int) {
		_ui = ui;
		_count = count;
		_element = element;
		_index = index;

		var bitmapFont = FlxBitmapFont.fromAngelCode(Constant.FONT_MEDIUM_DIGIT_BMP, Xml.parse(Assets.getText(Constant.FONT_MEDIUM_DIGIT_FNT)));
		_txtCount = new FlxBitmapText(bitmapFont);
		_txtCount.x = index * 32;
		_txtCount.y = -12;
		_txtCount.autoSize = false;
		_txtCount.alignment = FlxTextAlign.CENTER;
		_txtCount.fieldWidth = 32;
		_txtCount.setBorderStyle(OUTLINE, FlxColor.BLACK, 1);
		_txtCount.text = "" + count;

		x = index * 32;
		y = 0;

		var uiAtlas = PlayState.get().getAtlas(Constant.ATLAS_UI);

		// NORMAL / HIGHLIGHT / PRESSED
		var btnFrames = new FlxFramesCollection(uiAtlas.parent, uiAtlas.type, uiAtlas.border);
		btnFrames.frames.push(uiAtlas.getByName("scroll_" + element + ".png"));
		btnFrames.frames.push(uiAtlas.getByName("scroll_" + element + "_hover.png"));
		btnFrames.frames.push(uiAtlas.getByName("scroll_" + element + "_pressed.png"));

		// Create the button
		_icon = new FlxButton(x, y);
		_icon.frames = btnFrames;
		_icon.onUp.callback = onClickElement;
		_icon.visible = (_count > 0);
		_icon.active = (_count > 0);

		ui.add(_icon);
		ui.add(_txtCount);
	}

	public function onClickElement():Void {
		PlayState.get().buttonClicked = true;
		PlayState.get().selectElement(_element);
	}

	@:noCompletion
	function set_count(value:Int):Int {
		if (_count != value) {
			_icon.visible = (value > 0);
			_icon.active = (value > 0);
			_txtCount.text = "" + value;
		}

		return _count = value;
	}

	@:noCompletion
	function get_count():Int {
		return _count;
	}

	@:noCompletion
	function get_element():Element {
		return _element;
	}
}

/**
 * ...
 * @author 13rice
 */
class UIGameScrolls extends FlxSpriteGroup {
	inline public static var WIDTH = 96;
	inline public static var HEIGHT = 32;

	private var _scrolls:Map<Element, UIScroll> = new Map();

	private var _player:Player = null;

	public function new(?X:Float = 0, ?Y:Float = 0, player:Player) {
		super(X, Y);

		_player = player;

		var elements = Element.array();
		var i:Int = 0;

		for (element in elements) {
			_scrolls[element] = new UIScroll(this, element, _player.scrolls[element], i);
			i++;
		}

		PlayState.get().add(this);
	}

	public function getElementPoint(element:Element):FlxPoint {
		if (!_scrolls.exists(element)) {
			Log.error("unknown element : " + element);
			return FlxPoint.get();
		}

		return FlxPoint.get(_scrolls[element].x + x, _scrolls[element].y + y);
	}

	public function addElement(element:Element):Void {
		if (!_scrolls.exists(element)) {
			Log.error("unknown element : " + element);
			return;
		}

		var scroll = _scrolls[element];
		scroll.count++;
		Effect.playEffectFromSpecificAtlas(scroll.x + x, scroll.y + y, "element_add", 20, Constant.ATLAS_UI);
	}

	public function refreshScrollsCount() {
		var elements = Element.array();
		for (element in elements) {
			_scrolls[element].count = _player.scrolls[element];
		}
	}
}