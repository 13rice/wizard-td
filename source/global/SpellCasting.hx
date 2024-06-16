package global;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import gameObject.spells.SpellSkill;

/**
 * ...
 * @author 13rice
 */
class SpellCasting {
	public var leftClick(default, null):Bool = true;

	public var spellSelector(default, null):FlxSprite = null;

	/** Current selected spell */
	public var spellSkill(default, null):SpellSkill = null;

	public function new(leftClick:Bool, atlas:FlxAtlasFrames) {
		this.leftClick = leftClick;

		spellSelector = new FlxSprite();
		spellSelector.frames = atlas;

		if (leftClick)
			spellSelector.animation.frameName = "spell_selection.png";
		else
			spellSelector.animation.frameName = "spell_selection.png";

		spellSelector.resetSizeFromFrame();
	}

	public function selectSpellSkill(spell:SpellSkill):Bool {
		if (spell != null && spell != spellSkill) {
			spellSkill = spell;

			return true;
		}

		return false;
	}

	public function updateFramePosition() {
		spellSelector.x = spellSkill.spellIcon.x;
		spellSelector.y = spellSkill.spellIcon.y;
	}
}