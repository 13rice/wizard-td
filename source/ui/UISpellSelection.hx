package ui;

import gameObject.spells.CasterController;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.input.mouse.FlxMouse;
import flixel.math.FlxPoint;
import flixel.util.FlxDestroyUtil;
import gameObject.spells.SpellSkill;

class SpellSelectionFrame extends FlxSpriteGroup {
	public static inline var WIDTH:Int = 55;
	public static inline var HEIGHT:Int = 45;

	/** Player reference */
	private var _player:Player = null;

	/** Current SpellSkill associated */
	public var spellSkill:SpellSkill = null;

	public var levelUpArrowNotif:FlxSprite = null;

	public function new(?X:Float = 0, ?Y:Float = 0, player:Player) {
		super(X, Y);

		_player = player;

		levelUpArrowNotif = new FlxSprite(-36, 13);
		levelUpArrowNotif.frames = PlayState.get().getAtlas(Constant.ATLAS_UI);
		levelUpArrowNotif.animation.addByPrefix("idle", "arrow_notif_level_up", 30);
		levelUpArrowNotif.animation.play("idle");
		levelUpArrowNotif.visible = false;
		levelUpArrowNotif.updateHitbox();
		levelUpArrowNotif.origin.set(Math.floor(levelUpArrowNotif.width / 2), Math.floor(levelUpArrowNotif.height / 2));
		levelUpArrowNotif.scale.set(2, 2);

		add(levelUpArrowNotif);
	}

	override public function destroy():Void {
		levelUpArrowNotif = FlxDestroyUtil.destroy(levelUpArrowNotif);
		super.destroy();
	}
}

/**
 * ...
 * @author 13rice
 */
class UISpellSelection extends FlxSpriteGroup {
	private var _spellFrames:Array<SpellSelectionFrame> = new Array();

	private var _player:Player = null;

	private var _levelUpSelection:Bool = false;

	private var _recycleSelection:Bool = false;

	private var _replaceSpell:Bool = false;

	public function new(?X:Float = 0, ?Y:Float = 0, player:Player) {
		super(X, Y);

		_player = player;

		var frame:SpellSelectionFrame = null;
		for (pos in CasterController.SPELLFRAME_POSITION) {
			frame = new SpellSelectionFrame(pos.x, pos.y, _player);
			add(frame);

			_spellFrames.push(frame);
		}

		PlayState.get().add(this);
	}

	/**
	 * Add the spell Skill in a empty slot
	 * @param	spellSkill
	 * @return
	 */
	public function addSpell(spellSkill:SpellSkill, position:Int):Bool {
		var spellFrame = null;

		if (position >= 0 && position < _spellFrames.length && _spellFrames[position].spellSkill == null) {
			spellFrame = _spellFrames[position];
		} else {
			for (frame in _spellFrames) {
				if (frame.spellSkill == null) {
					spellFrame = frame;
					break;
				}
			}
		}

		if (spellFrame != null) {
			spellFrame.spellSkill = spellSkill;
			spellSkill.moveIcon(spellFrame.x, spellFrame.y);
			return true;
		}

		return false;
	}

	public function showLevelUpArrow(spell:SpellSkill):Bool {
		// Currently recycling => cancel
		if (_recycleSelection)
			hideArrows();

		var done:Bool = false;

		for (spellFrame in _spellFrames) {
			if (spellFrame.spellSkill == spell) {
				spellFrame.levelUpArrowNotif.visible = true;
				done = true;
			}
		}

		_levelUpSelection = true;

		return done;
	}

	public function removeSpell(spellSkill:SpellSkill):Bool {
		var result:Bool = false;

		for (frame in _spellFrames) {
			if (frame.spellSkill == spellSkill) {
				frame.spellSkill = null;

				result = true;
				break;
			}
		}

		return result;
	}

	public function hideArrows():Void {
		_levelUpSelection = false;
		_recycleSelection = false;
		_replaceSpell = false;

		for (frame in _spellFrames) {
			frame.levelUpArrowNotif.visible = false;
		}
	}

	/**
	 * Index of the given spellSkill
	 * @param	spellSkill -1 if not found
	 */
	public function getSpellIndex(spellSkill:SpellSkill) {
		var index:Int = 0;
		for (frame in _spellFrames) {
			if (frame.spellSkill == spellSkill) {
				return index;
			}

			index++;
		}

		return -1;
	}
}
