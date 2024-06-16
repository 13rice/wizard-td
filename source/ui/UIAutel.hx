package ui;

import data.DataSpell;
import effect.Effect;
import global.attribute.AttributeFlag;
import global.attribute.AttributeModifier;
import lime.utils.Assets;
import flixel.graphics.frames.FlxBitmapFont;
import flixel.text.FlxBitmapText;
import data.DataSound;
import flash.geom.Rectangle;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.ui.FlxSpriteButton;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxSpriteUtil;
import gameObject.items.ItemScroll.Element;
import gameObject.spells.SpellSkill;
import motion.Actuate;
import motion.easing.Bounce;
import motion.easing.Elastic;
import motion.easing.Linear;
import motion.easing.Quart;
import ui.UISpellSelection.SpellSelectionFrame;

class ScrollSelection extends FlxSprite {
	public var element:Element = Element.NONE;

	public function new(?X:Float = 0, ?Y:Float = 0, element:Element = Element.NONE) {
		super(X, Y);

		this.element = element;
	}
}

/**
 * ...
 * @author 13rice
 */
class UIAutel extends FlxSpriteGroup {
	public static inline var WIDTH:Int = 96;

	private var _player:Player = null;

	private var _scrollBtnSlot:Array<Array<FlxButton>> = [null, null];
	private var _scrollTxtSlot:Array<Array<FlxBitmapText>> = [null, null];

	private var _currentElements:Array<ScrollSelection> = [null, null];

	private var _recycleTexts:Array<FlxBitmapText> = [null, null];

	private var _btnCraft:FlxButton = null;

	private var _currentSpell:SpellSkill = null;

	private var _tooltip:UISpellTooltip = null;

	private var _levelUpBtn:FlxButton = null;

	private var _recycleBtn:FlxButton = null;

	private var _spellFrame:FlxSprite = null;

	private var _recycling:Bool = false;

	private var _replaceSprite:FlxSprite = null;

	private var _uiSpellSelection:UISpellSelection = null;

	private var _btnsNext:Array<FlxButton> = [];

	private var _btnsPrevious:Array<FlxButton> = [];

	public function new(?X:Float = 0, ?Y:Float = 0, player:Player, uiSpellSelection:UISpellSelection) {
		super(X, Y);

		_player = player;
		_uiSpellSelection = uiSpellSelection;

		// Load the images from atlas
		var uiAtlas = PlayState.get().getAtlas(Constant.ATLAS_UI);

		// Craft Button =================
		var btnFrames = new FlxFramesCollection(uiAtlas.parent, uiAtlas.type, uiAtlas.border);
		btnFrames.frames.push(uiAtlas.getByName("btn_craft.png"));
		btnFrames.frames.push(uiAtlas.getByName("btn_craft_hover.png"));
		btnFrames.frames.push(uiAtlas.getByName("btn_craft_clicked.png"));

		// Create the button
		_btnCraft = new FlxButton(21 * Constant.CELL_SIZE, 5 * Constant.CELL_SIZE);
		_btnCraft.frames = btnFrames;
		_btnCraft.onUp.callback = onClickCraftTower;
		_btnCraft.visible = false;
		add(_btnCraft);

		// Level Up Button =================

		// NORMAL / HIGHLIGHT / PRESSED
		btnFrames = new FlxFramesCollection(uiAtlas.parent, uiAtlas.type, uiAtlas.border);
		btnFrames.frames.push(uiAtlas.getByName("btn_upgrade.png"));
		btnFrames.frames.push(uiAtlas.getByName("btn_upgrade_hover.png"));
		btnFrames.frames.push(uiAtlas.getByName("btn_upgrade_clicked.png"));

		// Create the button
		_levelUpBtn = new FlxButton(21 * Constant.CELL_SIZE, 5 * Constant.CELL_SIZE);
		_levelUpBtn.frames = btnFrames;
		_levelUpBtn.onUp.callback = onLevelUp;
		_levelUpBtn.visible = false;
		add(_levelUpBtn);

		// Recycle Button =================

		// NORMAL / HIGHLIGHT / PRESSED
		btnFrames = new FlxFramesCollection(uiAtlas.parent, uiAtlas.type, uiAtlas.border);
		btnFrames.frames.push(uiAtlas.getByName("btn_recycle.png"));
		btnFrames.frames.push(uiAtlas.getByName("btn_recycle_hover.png"));
		btnFrames.frames.push(uiAtlas.getByName("btn_recycle_clicked.png"));

		// Create the button
		_recycleBtn = new FlxButton(20 * Constant.CELL_SIZE, 5 * Constant.CELL_SIZE);
		_recycleBtn.frames = btnFrames;
		_recycleBtn.onUp.callback = onRecycle;
		_recycleBtn.visible = false;
		add(_recycleBtn);

		// Next / previous =============
		btnFrames = new FlxFramesCollection(uiAtlas.parent, uiAtlas.type, uiAtlas.border);
		btnFrames.frames.push(uiAtlas.getByName("btn_next.png"));
		btnFrames.frames.push(uiAtlas.getByName("btn_next_hover.png"));
		btnFrames.frames.push(uiAtlas.getByName("btn_next_pressed.png"));

		for (i in 0...2) {
			// Create the button
			var btn = new FlxButton((21 + i * 2) * Constant.CELL_SIZE, 2 * Constant.CELL_SIZE);
			btn.frames = btnFrames;
			btn.onUp.callback = onNext.bind(i);
			btn.visible = false;
			add(btn);

			_btnsNext.push(btn);
		}

		btnFrames = new FlxFramesCollection(uiAtlas.parent, uiAtlas.type, uiAtlas.border);
		btnFrames.frames.push(uiAtlas.getByName("btn_previous.png"));
		btnFrames.frames.push(uiAtlas.getByName("btn_previous_hover.png"));
		btnFrames.frames.push(uiAtlas.getByName("btn_previous_pressed.png"));

		for (i in 0...2) {
			// Create the button
			var btn = new FlxButton((21 + i * 2) * Constant.CELL_SIZE, 4 * Constant.CELL_SIZE);
			btn.frames = btnFrames;
			btn.onUp.callback = onPrevious.bind(i);
			btn.visible = false;
			add(btn);

			_btnsPrevious.push(btn);
		}

		// Spell Frame =================
		_spellFrame = new FlxSprite(22 * Constant.CELL_SIZE, 7 * Constant.CELL_SIZE);
		_spellFrame.frames = uiAtlas;
		_spellFrame.animation.frameName = "tower_fire.png";
		_spellFrame.updateHitbox();
		_spellFrame.visible = false;
		add(_spellFrame);

		// Current scrolls selected (none by default)
		for (i in 0...2) {
			_currentElements[i] = new ScrollSelection(21 * Constant.CELL_SIZE + i * Constant.CELL_SIZE * 2, 3 * Constant.CELL_SIZE);
			_currentElements[i].frames = uiAtlas;
			_currentElements[i].visible = false;
		}

		// Texts for recycling spell ==============
		var txt:FlxBitmapText = null;
		for (i in 0...2) {
			var bitmapFont = FlxBitmapFont.fromAngelCode(Constant.FONT_SMALL_DIGIT_BMP, Xml.parse(Assets.getText(Constant.FONT_SMALL_DIGIT_FNT)));
			txt = new FlxBitmapText(bitmapFont);
			txt.x = 21 * Constant.CELL_SIZE + i * Constant.CELL_SIZE * 2;
			txt.y = 4 * Constant.CELL_SIZE;
			txt.autoSize = false;
			txt.alignment = FlxTextAlign.CENTER;
			txt.fieldWidth = Constant.CELL_SIZE;
			txt.textColor = 0xff99E550;
			txt.useTextColor = true;
			txt.setBorderStyle(OUTLINE, FlxColor.BLACK, 1);
			txt.text = " 0 - 2";
			txt.visible = false;

			_recycleTexts[i] = txt;
		}

		// Tooltip
		_tooltip = new UISpellTooltip(20 * Constant.CELL_SIZE, 8 * Constant.CELL_SIZE);

		add(_tooltip);

		for (sel in _currentElements) {
			add(sel);
		}

		for (recycleText in _recycleTexts)
			add(recycleText);
	}

	public function selectElementForSlotWithCheckAndNoneReplace(element:Element, slot:Int) {
		if (slot < 0 || slot > 1)
			return;

		if (elementCount(element) <= 0) {
			selectElementForSlot(Element.NONE, slot);
		} else {
			selectElementForSlot(element, slot);
		}
	}

	/**
	 * Displays the given element in the given slot
	 * @param	element Element to display
	 * @param	slot starting from 0
	 */
	public function selectElementForSlot(element:Element, slot:Int) {
		if (slot < 0 || slot > 1)
			return;

		// Current selected element
		_currentElements[slot].element = element;
		_currentElements[slot].visible = false;

		if (element != Element.NONE) {
			// Change image
			_currentElements[slot].animation.frameName = "scroll_" + element + ".png";
			_currentElements[slot].visible = true;

			if (isSlotsFilled()) {
				// Level up
				if (_currentSpell != null) {
					// Display the icon
					displaySpell();

					// Display Level up button
					_levelUpBtn.visible = _currentSpell.isLevelable();
				} else {
					newSpell();
				}
			} else {
				if (_currentSpell == null)
					_spellFrame.visible = false;
				_btnCraft.visible = _levelUpBtn.visible = false;
			}
		}
	}

	/**
	 * 
	 */
	private function onClickCraftTower():Void {
		// SFX
		//DataSound.get().playSound(Constant.SFX_CREATE_SPELL);

		add(Effect.playEffectFromSpecificAtlas(_spellFrame.x + _spellFrame.width / 2, _spellFrame.y + _spellFrame.height / 2, "spell_create", 40,
			Constant.ATLAS_UI, null)
			.center());

		_currentSpell = PlayState.get().generateSpell([for (i in 0...2) _currentElements[i].element]);
		if (_currentSpell != null) {
			_spellFrame.visible = true;
			_spellFrame.animation.frameName = _currentSpell.spellLevel.iconName;
			_spellFrame.origin.set(16, 16);
			_spellFrame.scale.set(0.1, 0.1);

			Actuate.tween(_spellFrame.scale, 1.5, {x: 1, y: 1}).ease(Elastic.easeOut).delay(0.3);

			display(_currentSpell, true);
		}
	}

	private function onLevelUp():Void {
		if (_currentSpell.onLevelUp()) {
			PlayState.get().levelUpSpell(_currentSpell);

			// SFX
			//DataSound.get().playSound(Constant.SFX_UPGRADE_SPELL);

			// Hide level up btn
			_levelUpBtn.visible = false;

			display(_currentSpell, true);
		}
	}

	/**
	 * 
	 */
	private function onRecycle():Void {
		_recycleBtn.visible = false;

		// Animation for the spell and fading
		Actuate.tween(_spellFrame, 0.05, {angle: 10});
		Actuate.tween(_spellFrame, 0.02, {angle: -10}, false)
			.delay(0.05)
			.repeat(10)
			.reflect()
			.ease(Bounce.easeOut);
		Actuate.tween(_spellFrame, 0.05, {angle: 0, alpha: 0}, false).delay(0.45);

		// TODO recycle sound

		var spawn:Int = 0;
		var level = _currentSpell.level;

		// Recycle per level
		var recycleCount = 1;
		if (Math.random() <= PlayState.get().attributeController.calculateValue(AttributeType.RECYCLE_THREE, AttributeFlag.PLAYER, 0))
			recycleCount = 3;
		else if (Math.random() <= PlayState.get().attributeController.calculateValue(AttributeType.RECYCLE_TWO, AttributeFlag.PLAYER, 0))
			recycleCount = 2;

		// Do the magic, calculate the elements generated and added to the player
		switch (_currentSpell.differentElementCount()) {
			case 1:
				spawn = level * recycleCount;
				_recycleTexts[0].text = "+ " + spawn;

				PlayState.get().addElement(_currentElements[0].element, spawn);
			case 2:
				// Probability 0 - lvl for the single
				spawn = (recycleCount == 3 ? level : Math.round(Math.random() * level));
				_recycleTexts[0].text = "+ " + spawn;

				PlayState.get().addElement(_currentElements[0].element, spawn);

				// Double elements
				switch (recycleCount) {
					case 1: spawn = level - spawn;
					case 2: spawn = level * 2 - spawn;
					case 3: spawn = level * 2;
				}

				// Probability lvl - lvl * 2 for the double element
				_recycleTexts[1].text = "+ " + spawn;

				PlayState.get().addElement(_currentElements[1].element, spawn);

			default:
				// Do nothing
		}

		// Animation for the recycle texts with elements earned
		for (i in 0...2) {
			if (_recycleTexts[i].visible && _recycleTexts[i].text != "+ 0") {
				Actuate.tween(_recycleTexts[i].scale, 0.25, {x: 3, y: 3})
					.repeat(1)
					.reflect()
					.ease(Quart.easeOut);
			}
		}

		// Hide tooltip
		_tooltip.visible = false;

		// Remove the spell from the player
		PlayState.get().removeSpellSkill(_currentSpell);
	}

	/**
	 * Display the window for upgrade / recycle
	 */
	public function display(spellSkill:SpellSkill = null, levelUp:Bool = true):Void {
		// TODO display pour une tower

		// Init
		_recycling = false;
		visible = true;

		for (txt in _recycleTexts) {
			txt.visible = false;
			txt.scale.set(1, 1);
		}

		_tooltip.visible = _levelUpBtn.visible = _recycleBtn.visible = _btnCraft.visible = _spellFrame.visible = false;
		_currentSpell = spellSkill;
		for (i in 0...2) {
			_btnsNext[i].visible = _btnsPrevious[i].visible = false;
		}

		// Selected Spell, for level up or recycle
		if (spellSkill != null) {
			displaySpell();

			// Remove selected scroll
			for (sel in _currentElements) {
				sel.element = Element.NONE;
				sel.visible = false;
			}

			if (levelUp) {
				for (i in 0...2)
					selectElementForSlotWithCheckAndNoneReplace(spellSkill.elements[i], i);
			} else {
				displayForRecycle(spellSkill);
			}
		} else {
			if (isSlotsFilled()) {
				newSpell();
			}
			for (i in 0...2) {
				_btnsNext[i].visible = _btnsPrevious[i].visible = true;
			}
		}
	}

	public function onNext(index:Int):Void {
		var elements = Element.array();

		var find = elements.indexOf(_currentElements[index].element);
		if (find == -1) {
			find = 0;
		}
		for (i in 1...4) {
			if (elementCount(elements[(find + i) % 3]) > 0) {
				selectElementForSlot(elements[(find + i) % 3], index);
				break;
			}
		}
	}

	public function onPrevious(index:Int):Void {
		var elements = Element.array();
		elements.reverse();

		var find = elements.indexOf(_currentElements[index].element);
		if (find == -1) {
			find = 0;
		}
		for (i in 1...4) {
			if (elementCount(elements[(find + i) % 3]) > 0) {
				selectElementForSlot(elements[(find + i) % 3], index);
				break;
			}
		}
	}

	private function elementCount(element:Element):Int {
		var scrolls = _player.scrolls;
		var count = scrolls[element];

		for (i in 0...2) {
			if (_currentElements[i].element == element)
				count--;
		}

		return count;
	}

	private function displaySpell():Void {
		_spellFrame.visible = true;
		_spellFrame.animation.frameName = _currentSpell.spellLevel.iconName;

		// Animation from big to normal scale
		Actuate.tween(_spellFrame.scale, 0.2, {x: 1, y: 1}).ease(Linear.easeNone);

		// Display spell tooltip
		_tooltip.display(_currentSpell);
	}

	private function displayForRecycle(spellSkill:SpellSkill):Void {
		_currentSpell = spellSkill;

		// Recycle
		_recycling = true;

		var factor2:Float = PlayState.get().attributeController.calculateValue(AttributeType.RECYCLE_TWO, AttributeFlag.PLAYER, 0);
		var min:Int = 0;
		var max:Int = 0;
		switch (spellSkill.differentElementCount()) {
			case 1:
				_recycleTexts[0].visible = true;

				selectElementForSlot(_currentSpell.elements[0], 0);

				min = (factor2 < 1 ? _currentSpell.level : _currentSpell.level * 2);
				_recycleTexts[0].text = min + " - " + max;
			case 2:
				for (i in 0...2) {
					_recycleTexts[i].visible = true;

					selectElementForSlot(_currentSpell.elements[i], i);

					// All different, same probabilities
					_recycleTexts[i].text = 0 + " - " + _currentSpell.level;
				}
			default:
				// Do nothing
		}

		// Display in the spell frame
		displaySpell();

		_recycleBtn.visible = true;
	}

	public function addElement(element:Element) {
		// Tower already selected
		if (_currentSpell != null)
			return;

		for (i in 0...2) {
			if (_currentElements[i].element == Element.NONE) {
				selectElementForSlot(element, i);
				break;
			}
		}
	}

	private function newSpell() {
		if (!isSlotsFilled())
			return;

		// New spell
		var spellSkill:SpellSkill = DataSpell.get().getTSpellSkillFromElements([for (i in 0...2) _currentElements[i].element]);
		_spellFrame.animation.frameName = spellSkill.spellLevel.iconName;
		_spellFrame.visible = true;

		_btnCraft.active = _btnCraft.visible = true;

		_tooltip.display(spellSkill);
	}

	private function isSlotsFilled():Bool {
		return _currentElements[0].element != Element.NONE && _currentElements[1].element != Element.NONE;
	}
}