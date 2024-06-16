package gameObject;

import flixel.util.FlxDirectionFlags;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.nape.FlxNapeSprite;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets.FlxGraphicAsset;

/**
 * ...
 * @author 13rice
 */
class GameSprite extends FlxNapeSprite {
	public var parent:GameObject = null;

	public function new(parent:GameObject, ?X:Float = 0, ?Y:Float = 0, ?SimpleGraphic:FlxGraphicAsset, CreateRectangularBody:Bool = true,
			EnablePhysics:Bool = true) {
		super(X, Y, SimpleGraphic, CreateRectangularBody, EnablePhysics);

		this.parent = parent;

		allowCollisions = FlxDirectionFlags.NONE;
	}

	/**
	 * Only sensors in this game !
	 * @param	Elasticity
	 * @param	DynamicFriction
	 * @param	StaticFriction
	 * @param	Density
	 * @param	RotationFriction
	 */
	override public function setBodyMaterial(Elasticity:Float = 1, DynamicFriction:Float = 0.2, StaticFriction:Float = 0.4, Density:Float = 1,
			RotationFriction:Float = 0.001):Void {
		super.setBodyMaterial(Elasticity, DynamicFriction, StaticFriction, Density, RotationFriction);

		for (shape in body.shapes) {
			shape.sensorEnabled = true;
		}

		this.body.userData.data = this;
	}

	override public function clone():FlxSprite {
		var clone:GameSprite = new GameSprite(parent, x, y);

		// FlxSprite copy
		clone.loadGraphicFromSprite(this);

		// FlxNapeSprite copy
		clone.body = body.copy();
		clone.physicsEnabled = physicsEnabled;
		clone._linearDrag = _linearDrag;
		clone._angularDrag = _angularDrag;

		// GameSprite copy
		clone.parent = parent;

		// Keep previous Origin
		clone.origin.x = origin.x;
		clone.origin.y = origin.y;

		return clone;
	}
}
