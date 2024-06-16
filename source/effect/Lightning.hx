package effect;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import gameObject.Unit;
import motion.Actuate;

using flixel.util.FlxSpriteUtil;


/**

 * @author 13rice
 */
class Lightning extends FlxSprite
{
	//Lightning Settings =====
	/**
	 * Offset of each segment from the centered line, random offset from (-lightningOffset / 2 to lightningOffset / 2)
	 */
	public var lightningOffset(get, set):Int;
	private var _lightningOffset:Int;
	/**
	 * Length of a segment
	 */
	public var lightningFrequency(get, set):Int;
	private var _lightningFrequency:Int;
	/**
	 * Line width of each branches
	 */
	private var _lightningWidth:Array<Int>;
	/**
	 * Color
	 */
	private var _lightningColor:Array<Int>;
	/**
	 * Alpha / transparency
	 */
	private var _lightningAlpha:Float;
	/**
	 * Number of branches
	 */
	private var _lightningBranches:Int;

	/**  Duration per lightning */
	public var duration(get, set):Float;
	private var _duration:Float;
	
	private var _cptDuration:Float;
	
	private var _timerLightning:Float;
	
	/** Null if the owner is the starting point */
	private var xStart(get, never):Float;
	private var _xStart:Null<Float> = null;
	/** Null if the owner is the starting point */
	private var yStart(get, never):Float;
	private var _yStart:Null<Float> = null;
	
	private var _owner:Unit = null;
	
	private var _target:Unit = null;
	
	private var xEnd(get, never):Float;
	private var _xEnd:Null<Float> = null;
	
	private var yEnd(get, never):Float;
	private var _yEnd:Null<Float> = null;
	

	/** Multiple targets 
	 *	call multipleTargetSettings method for multiple targets 
	 */
	private var _targets:Int = 1;
	/** Target range */
	private var _range:Float = 100;
	/** Damage factor per target */
	private var _damageFactor:Float = 1.0;
	/** Timer between each target, in sec */
	private var _targetTimer:Float = 0.08;
	/** Previous targets to avoid */
	private var _previousTargets:Array<Unit> = null;
	
	private var lineStyle:LineStyle = {color: FlxColor.RED, thickness: 1 };
	
	//private var _particleEmitter:ParticleEmitter = null;

	/**
	 *
	 * Fire Lightning Weapon
	 *
	 */
	public function new(?xFrom:Float, ?yFrom:Float, ?xTarget:Float, ?yTarget:Float, owner:Unit = null, target:Unit = null)
	{
		super();
		
		makeGraphic(FlxG.width, FlxG.height, FlxColor.TRANSPARENT, true);

		_lightningOffset = 60;
		_lightningFrequency = 20;
		_lightningWidth = [1, 2];
		_lightningColor = [0x33CCFF, 0xCCFFFF];
		_lightningAlpha = 0.9;
		_lightningBranches = 2;

		_duration = 0.25;
		_cptDuration = 0;
		
		_timerLightning = 0.05;
		
		_owner = owner;
		_xStart = xFrom;
		_yStart = yFrom;
		
		_target = target;
		_xEnd = xTarget;
		_yEnd = yTarget;
		
		// Fading effect
		alpha = 0;
		Actuate.tween(this, 0.1, { alpha : 0.9 });
	}
	
	override public function destroy() 
	{
		_target = null;
		_lightningWidth = null;
		_previousTargets = null;
		
		super.destroy();
	}

	/**
	 * Set specific caracteristic of the lightning
	 * @param	lightningOffset Offset of each segment from the centered line, random offset from (-lightningOffset / 2 to lightningOffset / 2)
	 * @param	lightningFrequency Length of each segment
	 * @param	lightningWidth line width per branches (for all branches if one item in the array)
	 * @param	lightningColor line color per branches (for all branches if one item in the array)
	 * @param	lightningBranches number of branches
	 * @param	duration in sec
	 */
	public function lightningSettings(lightningOffset:Int, lightningFrequency:Int, lightningWidth:Array<Int>, lightningColor:Array<Int>, lightningBranches:Int, duration:Float):Void
	{
		_lightningOffset = lightningOffset;
		_lightningFrequency = lightningFrequency;
		_lightningBranches = lightningBranches;
		_duration = duration;
		
		if (lightningWidth == null || lightningWidth.length == 0)
			_lightningWidth = [1];
		else
			_lightningWidth = lightningWidth;
		
		if (lightningColor == null || lightningColor.length == 0)
			_lightningColor = [0xffffff];
		else
			_lightningColor = lightningColor;
	}
	
	public function multipleTargetsSettings(targetCount:Int, range:Float, damageFactor:Float, previousTargets:Array<Unit>):Void
	{
		_targets = targetCount;
		_range = range;
		_damageFactor = damageFactor;
		_previousTargets = previousTargets;
		
		if (_targets > 1)
		{
			if (_previousTargets == null)
				_previousTargets = new Array();
			
			if (_target != null)
				_previousTargets.push(_target);
		}
	}
	
	/**
	 * Game Engine - Lightning Gun Effect
	 * Version: 1.0
	 * Author: Philip Radvan
	 * URL: http://www.freeactionscript.com
	 * 
	 * @param	elapsedTime
	 */
	override public function update(elapsedTime:Float):Void
	{
		_timerLightning -= elapsedTime;
		_cptDuration += elapsedTime;
		
		// Target dead, set position
		if (_target != null && !_target.enable)
		{
			_xEnd = _target.x;
			_yEnd = _target.y;
		}
		
		var x:Float = xStart;
		var y:Float = yStart;
		
		if (_cptDuration > _duration)
		{
			PlayState.get().remove(this);
			destroy();
			return;
		}
		else if (_timerLightning < 0)
		{
			
			_timerLightning += 0.04;
			
			//clear holder - clears anything drawn in the holder clip
			this.fill(FlxColor.TRANSPARENT);
			
			//set the line style
			//graphics.lineStyle(_lightningWidth, _lightningColor, _lightningAlpha, true);
			
			//calculate the distance between our fire point and target point
			var distanceX:Float = x - xEnd;
			var distanceY:Float = y - yEnd;
			var distanceTotal:Float = Math.sqrt(distanceX * distanceX + distanceY * distanceY);
			
			//calculate the number of steps the lightning bolt will make
			var numberOfSteps:Int = Std.int(distanceTotal / _lightningFrequency);
			
			//calculate the angle in radians
			var angle:Float = Math.atan2(y - yEnd, x - xEnd);
			
			//calculate the distance of each step in pixels
			var stepInPixels:Float = distanceTotal / numberOfSteps;
			
			var xPrev:Float = x;
			var yPrev:Float = y;
			
			var color:Int = 0;
			
			lineStyle.pixelHinting = true;
			
			//run a loop to create lightning bolts based on lightningBranches
			for (j in 0..._lightningBranches)
			{
				xPrev = x;
				yPrev = y;
			
				//set the line style
				color = (j < _lightningColor.length ? _lightningColor[j] : _lightningColor[_lightningColor.length - 1]);
				lineStyle.color.setRGB((color >> 16) & 0xFF,
					(color >> 8) & 0xFF,
					color & 0xFF,
					Math.round(_lightningAlpha * 255));
				
				lineStyle.thickness = (j < _lightningWidth.length ? _lightningWidth[j] : _lightningWidth[_lightningWidth.length - 1]);
				
				//run a loop to repeat line drawing based on numberOfSteps needed
				for (i in 1...numberOfSteps)
				{
					//calculate the current step position based on number of steps taken
					var currentStepPosition:Float = stepInPixels * i;
					
					//calculate Math.random offset number
					var randomOffset:Float = Math.random() * (_lightningOffset / 2) - _lightningOffset / 4;
					
					//calculate x & y positions of where to draw the line for this step
					var xStepPosition:Float = x - Math.cos(angle) * currentStepPosition + Math.cos(angle + 1.55) * randomOffset;
					var yStepPosition:Float = y - Math.sin(angle) * currentStepPosition + Math.sin(angle + 1.55) * randomOffset;
					
					//draw line to this position
					this.drawLine(xPrev, yPrev, xStepPosition, yStepPosition, lineStyle);
					
					xPrev = xStepPosition;
					yPrev = yStepPosition;
				}
				
				//draw line to final position
				this.drawLine(xPrev, yPrev, xEnd, yEnd, lineStyle);
			}
		}

		super.update(elapsedTime);
	}
	
	function get_xEnd():Float 
	{
		return (_xEnd != null ? _xEnd : _target.x);
	}
	
	function get_yEnd():Float 
	{
		return (_yEnd != null ? _yEnd : _target.y);
	}
	
	function get_xStart():Float 
	{
		return (_xStart != null ? _xStart : _owner.x);
	}
	
	function get_yStart():Float 
	{
		return (_yStart != null ? _yStart : _owner.y);
	}
	
	function get_duration():Float 
	{
		return _duration;
	}
	
	function set_duration(value:Float):Float 
	{
		return _duration = value;
	}
	
	function get_lightningFrequency():Int 
	{
		return _lightningFrequency;
	}
	
	function set_lightningFrequency(value:Int):Int 
	{
		return _lightningFrequency = value;
	}
	
	function get_lightningOffset():Int 
	{
		return _lightningOffset;
	}
	
	function set_lightningOffset(value:Int):Int 
	{
		return _lightningOffset = value;
	}
}



