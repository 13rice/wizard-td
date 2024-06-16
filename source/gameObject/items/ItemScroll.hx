package gameObject.items;

import global.attribute.AttributeFlag;
import flixel.math.FlxPoint;
import global.shared.FlxTrailRenderer;
import global.shared.PointUtils;
import motion.Actuate;
import motion.easing.Sine;

enum abstract Element(String) {
	var FIRE = "fire";
	var METAL = "metal";
	var WATER = "water";
	var NONE = "none";

	public static function fromString(el:String):Element {
		switch (el) {
			case "fire":
				return FIRE;
			case "metal":
				return METAL;
			case "water":
				return WATER;
		}

		return NONE;
	}

	public static function fromInt(el:Int):Element {
		switch (el) {
			case 0:
				return FIRE;
			case 1:
				return METAL;
			case 2:
				return WATER;
		}

		return NONE;
	}

	public static function sort(el1:Element, el2:Element):Int {
		if (el1 == el2)
			return 0;
		else if (cast(el1, String) < cast(el2, String))
			return -1;

		return 1;
	}

	public static function array():Array<Element> {
		return [Element.FIRE, Element.METAL, Element.WATER];
	}

	public static function pickOneRandom():Element {
		var rnd = Math.floor(Math.random() * 3);
		return fromInt(rnd);
	}

	public static function toAttributeFlag(el:Element):AttributeFlag {
		switch (el) {
			case FIRE:
				return AttributeFlag.FIRE;
			case METAL:
				return AttributeFlag.METAL;
			case WATER:
				return AttributeFlag.WATER;
			case NONE:
				return AttributeFlag.NONE;
		}
		return AttributeFlag.NONE;
	}
}

/**
 * Example:
 * 	addItem(new ItemScroll(Element.FIRE, FlxG.width * Math.random(), FlxG.height * Math.random()));
 * @author 13rice
 */
class ItemScroll extends GameObject {
	public var element(get, null):Element;

	private var _element:Element = Element.FIRE;

	private var _retrieved:Bool = false;

	private var _trail:FlxTrailRenderer = null;

	public function new(element:Element, ?x:Float = 0, ?y:Float = 0) {
		super(x, y, 0, false, false);

		_element = element;

		atlasName = Constant.ATLAS_UI;
		animationPrefix = "scroll_" + element + "_idle_";
		fps = 12;
		isAnimation = true;

		launchAnimation();

		// TODO FLIXEL TWEEN
		Actuate.tween(_sprite, 1, {y: y + 15}).repeat().reflect().ease(Sine.easeInOut);
	}

	override public function destroy():Void {
		super.destroy();

		if (_trail != null) {
			_trail.remove();
			_trail = null;
		}
	}

	/**
	 * Item has been picked up
	 */
	public function retrieve():Void {
		if (!_retrieved) {
			// Item has been picked up
			_retrieved = true;

			Actuate.stop(_sprite);

			// Replace the animation by a static image
			isAnimation = false;
			frameName = "scroll_" + _element + ".png";

			_sprite.x = (_sprite.x - x);
			_sprite.y = (_sprite.y - y);

			initGraphics();

			var state:PlayState = PlayState.get();
			var pt:FlxPoint = state.uiGameScrolls.getElementPoint(_element);
			var dist = PointUtils.sqrDistance(_sprite.x, _sprite.y, pt.x, pt.y);

			// Display on top of Game scrolls UI
			state.remove(this);
			state.insert(state.members.indexOf(state.uiGameScrolls) + 1, this);

			// Move to the UI
			Actuate.tween(_sprite, dist / (500 * 500), {x: pt.x + 8, y: pt.y + 8}).ease(Sine.easeIn).onComplete(PlayState.get().addItemScroll, [this]);

			// Trail for cool effect
			_trail = new FlxTrailRenderer(6, 3, 0x99ffff, _sprite, 1, AssetPaths.trail_40_64__png);
			state.insert(state.members.indexOf(this), _trail);

			// Point recycling
			pt.put();
		}
	}

	@:noCompletion
	function get_element():Element {
		return _element;
	}
}