package effect;

import haxe.ds.BalancedTree.TreeNode;
import js.html.rtc.IdentityAssertion;
import flixel.util.FlxDirectionFlags;
import flixel.FlxSprite;

enum EffectState {
	BIRTH;
	IDLE;
	DEATH;
}

class Effect extends FlxSprite {
	private static inline var BIRTH_ANIM = "birth_";
	private static inline var IDLE_ANIM = "idle_";
	private static inline var DEATH_ANIM = "death_";

	// Birth => Idle => Death
	private var animationList:Array<String> = new Array();

	private var currentIndex:Int = 0;

	private var timer:Float = 0;

	private var oneShot:Bool = false;

	private function new(x:Float, y:Float, atlas:String, animPrefix:String, fps:Int, insertBefore:FlxSprite = null, oneShot:Bool = false) {
		super(x, y);
		var playState:PlayState = PlayState.get();
		frames = playState.getAtlas(atlas);
		allowCollisions = FlxDirectionFlags.NONE;
		this.oneShot = oneShot;

		insertEffect(playState, insertBefore);

		var noBirthIdleDeath:Bool = true;

		// Birth => Idle => Death
		if (hasAnim(animPrefix + BIRTH_ANIM)) {
			animation.addByPrefix(BIRTH_ANIM, animPrefix + BIRTH_ANIM, fps, false);
			animationList.push(BIRTH_ANIM);
			noBirthIdleDeath = false;
		}
		if (hasAnim(animPrefix + IDLE_ANIM)) {
			animation.addByPrefix(IDLE_ANIM, animPrefix + IDLE_ANIM, fps, !oneShot);
			animationList.push(IDLE_ANIM);
			noBirthIdleDeath = false;
		}
		if (hasAnim(animPrefix + DEATH_ANIM)) {
			animation.addByPrefix(DEATH_ANIM, animPrefix + DEATH_ANIM, fps, false);
			animationList.push(DEATH_ANIM);
			noBirthIdleDeath = false;
		}

		if (noBirthIdleDeath) {
			animation.addByPrefix(IDLE_ANIM, animPrefix, fps, !oneShot);
			animationList.push(IDLE_ANIM);
		}
	}

	private function play():Void {
		if (animationList.length == 0 || currentIndex >= animationList.length)
			return;

		animation.play(animationList[currentIndex]);
		if (oneShot || animationList[currentIndex] != IDLE_ANIM)
			animation.finishCallback = playNextAnimation;
	}

	private function playNextAnimation(currentAnim:String) {
		currentIndex++;

		if (currentIndex < animationList.length)
			play();
		else {
			PlayState.get().remove(this);
			this.destroy();
		}
	}

	/**
		Play death animation then stop the effect
		If there's no death animation directly stop the effect
	**/
	private function playDeathAnimation():Void {
		if (animationList[animationList.length - 1] == DEATH_ANIM && currentIndex < animationList.length - 1) {
			currentIndex = animationList.length - 1;
			play();
		} else {
			PlayState.get().remove(this);
			this.destroy();
		}
	}

	private function insertEffect(state:PlayState, insertBefore:FlxSprite = null) {
		if (state == null)
			return;

		if (insertBefore != null)
			state.insert(state.members.indexOf(insertBefore), this);
		else
			state.add(this);
	}

	public function center():Effect {
		updateHitbox();
		offset.set(Math.floor(width / 2), Math.floor(height / 2));
		return this;
	}

	private function hasAnim(anim:String):Bool {
		if (frames != null) {
			for (frame in frames.frames) {
				if (frame.name != null && StringTools.startsWith(frame.name, anim))
					return true;
			}
		}

		return false;
	}

	override function update(elapsed:Float) {
		if (!oneShot) {
			if (timer > 0) {
				timer -= elapsed;
				if (timer <= 0)
					playDeathAnimation();
			}
		}
		super.update(elapsed);
	}

	/**
		Loop the idle animation for duration seconds
		@param duration in seconds
	**/
	public function addDuration(duration:Float):Effect {
		if (oneShot)
			return this;

		timer += duration;
		return this;
	}

	public static function playEffect(x:Float, y:Float, animPrefix:String, fps:Int, insertBefore:FlxSprite = null, center:Bool = false):Effect {
		return playEffectFromSpecificAtlas(x, y, animPrefix, fps, Constant.ATLAS_FX, insertBefore);
	}

	/**
	 * Play a single animation and destroy it when the animation is finished
	 * @param	x
	 * @param	y
	 * @param	atlas
	 * @param	animPrefix
	 * @param	fps
	 * @return
	 */
	public static function playEffectFromSpecificAtlas(x:Float, y:Float, animPrefix:String, fps:Int, atlas:String, insertBefore:FlxSprite = null):Effect {
		var effect:Effect = new Effect(x, y, atlas, animPrefix, fps, insertBefore, true);
		effect.play();
		return effect;
	}

	/**
		Add an effect with the idle animation in loop, use destroyEffect to stop and destroy the effect
	**/
	public static function addEffect(x:Float, y:Float, animPrefix:String, fps:Int, insertBefore:FlxSprite = null, atlas:String = Constant.ATLAS_FX):Effect {
		var effect:Effect = new Effect(x, y, atlas, animPrefix, fps, insertBefore, false);
		effect.play();
		return effect;
	}

	/**
		Launch death animation and destroy the effect
	**/
	public static function destroyEffect(effect:Effect):Void {
		effect.timer = 0;
		effect.oneShot = true;
		effect.playDeathAnimation();
	}
}