package gameObject;

import gameObject.GameObject;
//import gameObject.missile.Missile;
import openfl.events.Event;

/**
 * Specific GameObjectEvent
 * @author 13rice
 */
class GameObjectEvent extends Event
{
	/** The GameObject has fired a missile */
	//public static inline var MISSILE_FIRED = "missile_fired";
	
	/** A game object has dealt damage to another game object */
	/*public static inline var DAMAGE_DEALT = "damage_dealt";
	
	public var missile(get, set):Missile;
	private var _missile:Missile = null;
	
	public var targetObject(get, set):GameObject;
	private var _targetObject:GameObject = null;

	public function new(type:String, missile:Missile = null, target:GameObject = null, bubbles:Bool=false, cancelable:Bool=false) 
	{
		super(type, bubbles, cancelable);
		
		_missile = missile;
		_targetObject = target;
	}
	
	override public function clone():Event 
	{
		return new GameObjectEvent(type, _missile, _targetObject, bubbles, cancelable);
	}
	
	function get_missile():Missile 
	{
		return _missile;
	}
	
	function set_missile(value:Missile):Missile 
	{
		return _missile = value;
	}
	
	function get_targetObject():GameObject 
	{
		return _targetObject;
	}
	
	function set_targetObject(value:GameObject):GameObject 
	{
		return _targetObject = value;
	}*/
	
	
	
}