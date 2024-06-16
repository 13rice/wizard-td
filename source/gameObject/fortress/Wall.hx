package gameObject.fortress;

import effect.Effect;
import global.attribute.AttributeFlag;
import global.attribute.AttributeModifier.AttributeType;
import global.attribute.AttributeController;
import gameObject.attacks.DamageFlag;
import flash.geom.Point;
import flixel.math.FlxPoint;
import flixel.tweens.FlxTween;
import gameObject.GameObject;
import global.shared.Hitbox;
import motion.Actuate;
import nape.callbacks.CbType;
import nape.dynamics.InteractionFilter;
import nape.phys.BodyType;

enum WallType {
	TOWER;
	WALL;
}

/**
 * ...
 * @author 13rice
 */
class Wall extends GameObject {
	public static var CB_WALL = new CbType();
	public static var INTERACTION_FILTER = new InteractionFilter(GameObject.FRIENDLY_UNIT, ~GameObject.FRIENDLY_UNIT, GameObject.FRIENDLY_UNIT,
		~GameObject.FRIENDLY_UNIT);

	private var _wallType:WallType = WALL;

	public function new(wallType:WallType, ?x:Float = 0, ?y:Float = 0, ?hitPoints:Float = 0) {
		super(x, y, hitPoints, false, true);

		_atlasName = Constant.ATLAS_DOODADS;

		_wallType = wallType;
		switch (_wallType) {
			case TOWER:
				_hitbox = new Hitbox(Hitbox.BOX, 70, 50, 0, [new Point(-18, 35)]);

				// Display
				isAnimation = true;
				animationPrefix = "tower-wall-";
				launchAnimation();

			case WALL:
				_hitbox = new Hitbox(Hitbox.BOX, 68, 94, 0, [new Point(-13, 31)]);

				// Display
				isAnimation = true;
				animationPrefix = "wall-";
				launchAnimation();
		}

		// Physics
		_bodyType = BodyType.STATIC;
		createHitbox(Wall.CB_WALL, Wall.INTERACTION_FILTER);

		visible = false;
	}

	/**
	 * Damage from any source to the gameObject
	 * @param	damange amount
	 * @return true if dead (hp <= 0), false otherwise
	 */
	override function dealDamage(damage:Float, source:GameObject, flag:DamageFlag, sourceFlag:AttributeFlag, mask:Bool = true):Bool {
		if (mask)
			enableWhiteMask();

		PlayState.get().dealDamageToWall(damage);

		return false;
	}

	override public function kill():Void {
		if (hasAnim(GameObject.DEATH_ANIM)) {
			fps = 40;
			Actuate.timer(Math.random() * 0.5).onComplete(function() {
				playAnimation(GameObject.DEATH_ANIM, false, true, true);
			});
		}

		super.kill();

		_sprite.destroyPhysObjects();

		exists = true;
	}
}