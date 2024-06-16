package ui;
import flixel.group.FlxSpriteGroup;






/**
 * 13rice
 * @author 
 */
class UITopInterface extends FlxSpriteGroup
{
	public static inline var WIDTH:Int = 240;
	public static inline var HEIGHT:Int = 240;
	
	private var _spellFrames:Array<SpellSelectionFrame> = new Array();
	
	private var _player:Player = null;
	
	private var _background:FlxSprite = null;
	
	private var _levelUpSelection:Bool = false;
	
	private var _recycleSelection:Bool = false;
	
	private var _replaceSpell:Bool = false;
	
	public function new(?X:Float=0, ?Y:Float=0, player:Player)
	{
		super(X, Y);
		
		_player = player;
		
		_background = new FlxSprite(-10, -10);
		_background.frames = PlayState.get().getAtlas(Constant.ATLAS_UI);
		_background.animation.frameName = "spell_player_frame.png";
		
		add(_background);
		
		var frame:SpellSelectionFrame = null;
		for (i in 0...5)
		{
			frame = new SpellSelectionFrame(i * SpellSelectionFrame.WIDTH, 0, _player);
			add(frame);
			
			_spellFrames.push(frame);
		}
		
		PlayState.get().add(this);
	}
	
}