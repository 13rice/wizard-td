package;

import flixel.util.FlxAxes;
import flixel.ui.FlxButton;
import motion.Actuate;
import global.attribute.AttributeFlag;
import global.attribute.AttributeModifier.AttributeType;
import data.DataSkill;
import global.shared.MathUtils;
import gameObject.spells.Caster;
import gameObject.spells.CasterController;
import Constant;
import data.DataManager;
import data.DataSound;
import data.DataSpell;
import data.DataUnit;
import effect.Lightning;
import effect.Effect;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.nape.FlxNapeSpace;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;
import flixel.system.scaleModes.FillScaleMode;
import flixel.system.scaleModes.FixedScaleMode;
import flixel.system.scaleModes.RatioScaleMode;
import flixel.system.scaleModes.RelativeScaleMode;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxHorizontalAlign;
import flixel.util.FlxSignal.FlxTypedSignal;
import flixel.util.FlxSort;
import gameObject.GameObject;
import gameObject.GameSprite;
import gameObject.Unit;
import gameObject.fortress.Fortress;
import gameObject.fortress.Wall;
import gameObject.items.ItemScroll;
import gameObject.spells.Spell;
import gameObject.spells.SpellCML;
import gameObject.spells.SpellSkill;
import global.DamageText;
import global.SpellCasting;
import global.Trigger;
import global.buff.BuffManager;
import global.shared.Log;
import global.attribute.AttributeController;
import global.skill.SkillController;
import haxe.xml.Access;
import nape.callbacks.CbEvent;
import nape.callbacks.InteractionCallback;
import nape.callbacks.InteractionListener;
import nape.callbacks.InteractionType;
import nape.dynamics.InteractionFilter;
import nape.geom.Vec2;
import nape.phys.Body;
import openfl.display.BitmapData;
import openfl.events.Event;
import openfl.net.URLLoader;
import openfl.net.URLRequest;
import org.si.cml.CMLFiber;
import org.si.cml.CMLObject;
import org.si.cml.CMLSequence;
import org.si.cml.core.CMLState;
import save.PlayerAccount;
import ui.UIAutel;
import ui.UIGameScrolls;
import ui.UILifeProgressBar;
import ui.UILevelProgress;
import ui.UINextWave;
import ui.UISpellSelection;
import ui.UIAssaultCompleted;
import worldmap.Assault;
import worldmap.Wave;

enum DbgCommand {
	AddUnits;
	Spells;
}

@:enum
abstract ScaleMode(String) to String {
	var RATIO_DEFAULT = "ratio";
	var RATIO_FILL_SCREEN = "ratio (screenfill)";
	var FIXED = "fixed";
	var RELATIVE = "relative 75%";
	var FILL = "fill";
}

class PlayState extends FlxState {
	private var scaleModeIndex:Int = 0;
	private var currentPolicy:FlxText;
	private var scaleModes:Array<ScaleMode> = [RATIO_DEFAULT, RATIO_FILL_SCREEN, FIXED, RELATIVE, FILL];

	public var X_NO_CAST_ZONE(get, null):Int;
	public var Y_NO_CAST_ZONE(get, null):Int;

	private var _aka:PlayerAccount = null;

	/** Real game time, including pause etc */
	public var currentTime(get, null):Float;

	private var _currentTime:Float = 0;

	/** Playing time only */
	private var _assaultTime:Float = 0;

	private var _grpTowers:FlxSpriteGroup = null;
	private var _grpEnemies:FlxTypedGroup<Unit> = null;
	private var _grpSpells:FlxTypedGroup<Spell> = null;
	private var _grpItems:FlxTypedGroup<ItemScroll> = null;
	private var _grpCasters:FlxTypedGroup<Caster> = null;

	private var _spells:Array<Spell> = new Array();

	private var _background:FlxSprite = null;

	private var _gridSpells:Array<Array<Int>> = [
		[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
		[1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 1],
		[1, 0, 1, 1, 1, 0, 1, 0, 1, 1, 0, 1, 0, 1, 0, 1],
		[1, 0, 1, 1, 1, 0, 1, 0, 1, 1, 0, 1, 0, 1, 0, 1],
		[1, 0, 0, 0, 1, 0, 1, 0, 1, 1, 0, 1, 0, 1, 0, 1],
		[1, 1, 1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 1],
		[0, 0, 0, 0, 1, 0, 1, 1, 1, 1, 0, 1, 1, 1, 0, 1],
		[1, 1, 1, 1, 1, 0, 1, 0, 0, 1, 0, 1, 0, 1, 0, 1],
		[0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0],
		[0, 1, 0, 1, 1, 1, 1, 0, 1, 1, 0, 1, 0, 0, 0, 0],
		[0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0],
		[0, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 0, 0, 0, 0]];

	private var _grids:Array<Array<FlxButton>> = [];

	private var _cursorSelection:FlxSprite = null;

	private var _cursorSelected:FlxSprite = null;

	private var _aoe:FlxSprite = null;

	private var _lastOverPt:FlxPoint = FlxPoint.get();

	private var _lastSelectedIndex:Int = 0;
	
	/** Spawn of a wave complete */
	private var _assaultComplete:Bool = false;

	/** Action to go on next wave */
	public var _goNextWave:Bool = false;

	/** End of the Assault, congrats ! */
	private var _waveComplete:Bool = false;

	/** Atlas dictionnary */
	private var _atlases:Map<String, FlxAtlasFrames> = null;

	private var _currentCommand:DbgCommand = AddUnits;

	/** Button clicked for this frame ? */
	public var buttonClicked(get, set):Bool;

	private var _buttonClicked:Bool = false;

	private var _spellSkills:Array<SpellSkill> = new Array();

	private var _spellSelecter:FlxSprite = null;

	private var _sortSpell:Bool = false;

	private var _casterController:CasterController = null;

	public var casterController(get, null):CasterController;

	private var _items:Array<ItemScroll> = new Array();

	// UI ================
	public var uiGameScrolls(get, null):UIGameScrolls;

	private var _uiGameScrolls:UIGameScrolls = null;

	public var uiAutel(get, null):UIAutel;

	private var _uiAutel:UIAutel = null;

	private var _uiSpellSelection:UISpellSelection = null;

	private var _uiLifeProgressBar:UILifeProgressBar = null;
	private var _uiLevelProgress:UILevelProgress = null;
	

	private var _uiNextWave:UINextWave = null;
	private var _uiAssaultCompleted:UIAssaultCompleted = null;

	// CannonML
	public var cmlScript(get, never):CMLSequence;

	private var _cmlScript:CMLSequence;

	public var targetForPlayer(get, null):CMLObject;

	private var _targetForPlayer:CMLObject;

	// CML Format
	private var _currentUnitWave:Unit = null;

	private var _outOfGameCamera:FlxCamera = null;

	public var fortress(get, null):Fortress;

	private var _fortress:Fortress = null;

	/** Current Assault */
	public var assault:Assault = null;

	public var currentWave:Wave = null;

	private var _killSignals:FlxTypedSignal<String->Void> = new FlxTypedSignal<String->Void>();

	private var _player:Player = null;

	private var _paused:Bool = false;

	#if android
	private var _currentTouch:FlxTouch = null;
	#end

	/** Buff management */
	private var _buffManager:BuffManager;

	/** Attribute management **/
	public var attributeController(get, null):AttributeController;

	private var _attributeController:AttributeController;

	/** Skill management **/
	public var skillController(get, null):SkillController;
	private var _skillController:SkillController;

	private static var _thisState:PlayState = null;

	var leftSpellCasting(default, null):SpellCasting = null;

	// TEST COMMAND
	private var _grid:FlxSprite = null;

	private var _spellcasting:Bool = true;

	private var _defeat:Bool = false;

	private var _i:Int = 0;

	public static function get():PlayState {
		return _thisState;
	}

	override public function create():Void {
		super.create();
		destroySubStates = false;

		_aka = PlayerAccount.get();

		FlxG.scaleMode = new RatioScaleMode();

		#if html5
		// Disable context menu on right click for html5
		FlxG.stage.showDefaultContextMenu = false;
		#end

		_thisState = cast(FlxG.state, PlayState);

		// For testing purpose
		if (assault == null) {
			var waves:Array<Wave> = [];

			for (i in 0...48) {
				var wave = new Wave(20, 6);
				wave.addScrollType(Element.FIRE, 4);
				wave.addScrollType(Element.METAL, 4);
				wave.addScrollType(Element.WATER, 4);
				waves.push(wave);
			}

			assault = new Assault(5900101, waves);
		}

		_currentTime = 0;
		_assaultTime = 0;

		_player = Player.get();

		_background = new FlxSprite(0, 0);
		_background.loadGraphic(AssetPaths.background__png);
		_background.screenCenter();
		// _background.origin.x = _background.origin.y = 0;
		add(_background);

		// Load all graphics
		loadAtlases();

		// Nape Physics
		initNapePhysics();
		
		// Init grids
		initGrids();

		// Init Fortress
		_fortress = new Fortress();
		add(_fortress);

		// Init displayed layers
		_grpTowers = new FlxSpriteGroup();
		_grpEnemies = new FlxTypedGroup();
		_grpSpells = new FlxTypedGroup();
		_grpItems = new FlxTypedGroup();
		_grpCasters = new FlxTypedGroup();

		add(_grpTowers);
		add(_grpCasters);
		add(_grpEnemies);
		add(_grpSpells);
		add(_grpItems);

		_assaultComplete = false;
		_waveComplete = false;
		_goNextWave = false;
		_defeat = false;
		_spellcasting = true;

		DataManager.loadData();

		// Casters
		_casterController = new CasterController(_grpCasters);

		// Leveling / Abilities
		_attributeController = new AttributeController();

		// Skills
		_skillController = new SkillController(DataSkill.get().getAllTSkillsTree(), _attributeController);

		// Player
		_player.onNewLevel(_casterController);

		// CannonML
		initCannonML();

		// Game border
		_outOfGameCamera = new FlxCamera(0, 0, FlxG.width, FlxG.height, 1);
		_outOfGameCamera.setScale(0.5, 0.5);

		// UI
		var xMiddle = FlxG.width / 2;

		_uiGameScrolls = new UIGameScrolls(672, 32, _player);
		_uiSpellSelection = new UISpellSelection(0, 0, _player);
		_uiAutel = new UIAutel(0, 0, _player, _uiSpellSelection);
		_uiLifeProgressBar = new UILifeProgressBar(xMiddle - 100, 8, _player);
		_uiLevelProgress = new UILevelProgress(100, 8, assault);
		_uiNextWave = new UINextWave(FlxG.width / 2 - UINextWave.WIDTH / 2, 10);

		insert(members.indexOf(_uiGameScrolls), _uiAutel);

		_buffManager = BuffManager.get();

		leftSpellCasting = new SpellCasting(true, _atlases[Constant.ATLAS_UI]);

		_casterController.init(_uiSpellSelection);

		// Init wave
		if (assault.waves == null || assault.waves.length == 0)
			FlxG.log.error("Incorrect assault");
		else {
			currentWave = assault.waves[0];
			currentWave.startWave();
		}

		// Initial Items
		initItems();

		initializePlayer(Element.FIRE);

		_cursorSelection = new FlxSprite();
		_cursorSelection.frames = _atlases[Constant.ATLAS_UI];
		_cursorSelection.animation.addByPrefix("idle", "cursor_selection_", 8);
		_cursorSelection.animation.play("idle");
		add(_cursorSelection);

		_cursorSelected = new FlxSprite();
		_cursorSelected.frames = _atlases[Constant.ATLAS_UI];
		_cursorSelected.animation.addByPrefix("idle", "cursor_selected_", 20);
		_cursorSelected.animation.play("idle");
		_cursorSelected.visible = true;
		add(_cursorSelected);
		_aoe = new FlxSprite();
		_aoe.frames = _atlases[Constant.ATLAS_UI];
		_aoe.animation.frameName = "aoe_mask.png";
		_aoe.updateHitbox();
		_aoe.offset.set(100, 100);
		_aoe.visible = false;
		add(_aoe);
		
		_uiAssaultCompleted = new UIAssaultCompleted();

		FlxG.debugger.addButton(FlxHorizontalAlign.LEFT, new BitmapData(10, 10, true, 0xff00ff00), refreshUnit);

		////////////// TEST ///////////////

		// TEST ==== LAUNCH THE FIRST WAVE DIRECTLY
		_currentUnitWave = DataUnit.get().getTWave(assault.assaultId);
		_currentUnitWave.start();
	}

	override public function destroy():Void {
		Trigger.destroy();
		_buffManager.reset();

		super.destroy();
	}

	private function initNapePhysics():Void {
		FlxNapeSpace.init();

		FlxNapeSpace.space.listeners.add(new InteractionListener(CbEvent.BEGIN, InteractionType.SENSOR, Spell.CB_SPELL, GameObject.CB_ENEMY,
			collideSpellEnemyNape));

		var listener = new InteractionListener(CbEvent.ONGOING, InteractionType.SENSOR, Spell.CB_SPELL, GameObject.CB_ENEMY, collideOngoingSpellEnemyNape);
		listener.allowSleepingCallbacks = true;

		FlxNapeSpace.space.listeners.add(listener);

		FlxNapeSpace.space.listeners.add(new InteractionListener(CbEvent.BEGIN, InteractionType.SENSOR, GameObject.CB_ENEMY, Wall.CB_WALL, collideEnemyWall));
	}

	private function initGrids():Void {
		for (j in 0...Constant.GRID_HEIGHT) {
			_grids.push([]);
			for (i in 0...Constant.GRID_WIDTH) {
				if (_gridSpells[j][i] > 0 ) {
					var btn = new FlxButton((i + 1) * Constant.CELL_SIZE, (j + 2) * Constant.CELL_SIZE);
					btn.makeGraphic(32, 32, FlxColor.TRANSPARENT);
					add(btn);

					var index = i + j * Constant.GRID_WIDTH;
					btn.onOver.callback = onGridCellOver.bind(index);
					//btn.onUp.callback = onGridCellUp.bind(index);

					_grids[j][i] = btn;
				}
				else {
					_grids[j][i] = null;
				}
			}
		}
	}

	private function loadAtlases():Void {
		// Already loaded ?
		if (_atlases != null)
			return;

		_atlases = new Map();

		_atlases[Constant.ATLAS_FX] = FlxAtlasFrames.fromTexturePackerJson(AssetPaths.fx__png, AssetPaths.fx__json);
		_atlases[Constant.ATLAS_DOODADS] = FlxAtlasFrames.fromTexturePackerJson(AssetPaths.doodads__png, AssetPaths.doodads__json);
		_atlases[Constant.ATLAS_UI] = FlxAtlasFrames.fromTexturePackerJson(AssetPaths.ui__png, AssetPaths.ui__json);
		_atlases[Constant.ATLAS_FADING] = FlxAtlasFrames.fromTexturePackerJson(AssetPaths.rect_fading__png, AssetPaths.rect_fading__json);

		// Keep the bitmap source
		for (atlas in _atlases) {
			atlas.parent.destroyOnNoUse = false;
		}
	}

	public function getAtlas(atlasName:String):FlxAtlasFrames {
		if (!_atlases.exists(atlasName)) {
			Log.error("Atlas : " + atlasName + " not found !");
			return null;
		}

		return _atlases[atlasName];
	}

	/**
	 * Main loop
	 * @param	elapsed
	 */
	override public function update(elapsed:Float):Void {
		var u:Unit = null;
		var s:Spell = null;

		_currentTime += elapsed;

		if (!_uiNextWave.visible) {
			_assaultTime += elapsed;
		}

		_sortSpell = false;

		// Key Events
		keyEvents();

		// Mouse Events
		mouseEvents();

		if (!_paused) {
			// Buff
			_buffManager.frameMove(elapsed);

			var x = 0;
			var y = 0;

			#if !android
			x = FlxG.mouse.x;
			y = FlxG.mouse.y;
			#else
			if (getCurrentTouch() != null) {
				x = _currentTouch.x;
				y = _currentTouch.y;
			}
			#end

			// CannonML
			CMLObject.frameUpdate(CMLState.timeRatio);

			// Cleaning
			for (object in _grpSpells) {
				var sprite = object._sprite;
				if (!sprite.isOnScreen(_outOfGameCamera)) {
					removeSpell(object);
				}
			}

			// Sorting spell effect
			if (_sortSpell) {
				_grpSpells.sort(FlxSort.byY, FlxSort.ASCENDING);
			}

			super.update(elapsed);
		}

		_buttonClicked = false;
	}

	private function keyEvents():Void {
		#if (debug && !android)
		/** Debug Commands */
		/**
		 * A : Display Affinity
		 * B : Test Damage text
		 * H : hold spellcasting
		 * D : Instant defeat
		 * E : AddEffect
		 * G : show / hide grid
		 * ESCAPE : hide AUTEL
		 * L : Lightning testing
		 * S : save Lightning
		 * M : Switch to worldmap
		 * N : go to next wave
		 * P : show Nape Space debug
		 * R : refreshUnit
		 * T : Display Skill tree
		 * V : Instant victory
		 * Ctrl + X : clear cache
		 * Ctrl + A : display Assault
		 * Ctrl + L : display level
		 */

		// Show nape debugging
		if (FlxG.keys.justPressed.P) {
			FlxNapeSpace.drawDebug = !FlxNapeSpace.drawDebug;
		} else if (FlxG.keys.justPressed.B) {
			add(DamageText.create(FlxG.width / 2 - 20, FlxG.height / 2, 4, false));
			add(DamageText.create(FlxG.width / 2 + 20, FlxG.height / 2, 12, true));
		} else if (FlxG.keys.justPressed.H) {
			_spellcasting = !_spellcasting;
		} else if (FlxG.keys.justPressed.D) {
			dealDamageToWall(999999);
		} else if (FlxG.keys.justPressed.E) {
			// No Birth / Idle / Death
			Effect.playEffect(150, FlxG.height / 2, "Poison_Effect_cloud_", 30, null).center();
			// Birth Idle Death one shot
			Effect.playEffect(250, FlxG.height / 2, "golem-lava-little-", 10, null).center();
			// Create > Destroy
			var e = Effect.addEffect(300, FlxG.height / 2, "golem-lava-little-", 10, null).center();
			Actuate.timer(2).onComplete(Effect.destroyEffect, [e]);
			// Create for x seconds
			Effect.addEffect(350, FlxG.height / 2, "golem-lava-little-", 10, null).center().addDuration(3);
		} else if (FlxG.keys.justPressed.ESCAPE) {
		} else if (FlxG.keys.justPressed.N) {
			_goNextWave = true;
		} else if (FlxG.keys.justPressed.R) {
			refreshUnit();
		} else if (FlxG.keys.justPressed.SPACE) {
			switch (_currentCommand) {
				case DbgCommand.AddUnits:
					/*var nbUnits = 100;

						for (i in 0...nbUnits)
						{
							u = new Unit(Math.floor(FlxG.mouse.x + Math.random() * nbUnits), Math.floor(FlxG.mouse.y + Math.random() * nbUnits));
							
							addUnit(u);
					}*/

					// group.sort(FlxSort.byY);

					_currentUnitWave = DataUnit.get().getTWave(assault.assaultId);
					_currentUnitWave.start();
				case DbgCommand.Spells:
					var light = new Lightning(100, 200, FlxG.mouse.x, FlxG.mouse.y);
					add(light);
			}

			// _uiAssaultCompleted.display(true, 65, 124);
		} else if (FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.X) {
			_aka.deleteAll();
		}
		#end
	}

	#if android
	private function getCurrentTouch():FlxTouch {
		if (_currentTouch == null) {
			_currentTouch = FlxG.touches.getFirst();
		} else {
			// Previous touch completely released since last frame
			if (!_currentTouch.pressed && !_currentTouch.justReleased) {
				_currentTouch = FlxG.touches.getFirst();
			}
		}

		return _currentTouch;
	}
	#end

	private function mouseEvents():Void {
		var pt:FlxPoint = FlxPoint.get();
		var x:Int = 0;
		var y:Int = 0;

		var justReleased = false;
		var justReleasedRight = false;

		var justPressed = false;
		var justPressedRight = false;

		var pressed = false;
		var pressedRight = false;

		#if !android
		pt.x = FlxG.mouse.x;
		pt.y = FlxG.mouse.y;
		x = FlxG.mouse.x;
		y = FlxG.mouse.y;

		justReleased = FlxG.mouse.justReleased;
		justReleasedRight = FlxG.mouse.justReleasedRight;

		justPressed = FlxG.mouse.justPressed;
		justPressedRight = FlxG.mouse.justPressedRight;

		pressed = FlxG.mouse.pressed;
		pressedRight = FlxG.mouse.pressedRight;
		#else
		var touch = getCurrentTouch();

		if (touch != null) {
			pt.x = _currentTouch.x;
			pt.y = _currentTouch.y;

			x = _currentTouch.x;
			y = _currentTouch.y;

			justReleased = touch.justReleased;

			justPressed = touch.justPressed;

			pressed = touch.pressed;
		}
		#end

		// Spell casting  //============
		if (_spellcasting)
			_casterController.spellCasting(_grpEnemies);

		// ============
		// Items
		for (item in _items) {
			if (item.overlapsPoint(pt)) {
				item.retrieve();
			}
		}

		// UI
		// Selection
		if (!buttonClicked && justReleased) {
			if (pt.x < X_NO_CAST_ZONE) {
				_cursorSelected.x = _lastOverPt.x;
				_cursorSelected.y = _lastOverPt.y;
				_cursorSelected.visible = true;

				_lastSelectedIndex = PlayState.PointToIndex(_cursorSelected.x, _cursorSelected.y);

				var selectedSpellSkill =_casterController.selectIndex(_lastSelectedIndex);
				displayAutelForSpellSkill(selectedSpellSkill, true);

				if (selectedSpellSkill != null) {
					refreshAOE(selectedSpellSkill);
				} else {
					_aoe.visible = false;
				}
			}
		}

		if (!_buttonClicked && !_uiNextWave.visible) {
			if (justReleased) {
				// TEST ================
				FlxG.log.add("justReleased :" + pt.x + " " + pt.y);
				// =============
				// Spell casting
				spellCastingClick(pt.x, pt.y);
			} else if (pressed) {
				// Spell casting
				spellCastingClick(pt.x, pt.y);
			}
		}
		pt.put();
	}

	private function spellCastingClick(x:Float, y:Float) {
		spellCasting(x, y, leftSpellCasting.spellSkill, _casterController.playerCaster);
	}

	static public function PointToIndex(x:Float, y:Float):Int {
		return Math.floor((x - Constant.BASE_GRID_X) / Constant.CELL_SIZE + (y - Constant.BASE_GRID_Y) / Constant.CELL_SIZE * Constant.GRID_WIDTH);
	}
	/**
	 * Cast a spell targeting x,y position
	 * @param x 
	 * @param y 
	 * @param left if true spell from left click, right click otherwise
	 * @param spellSkill if null the current selected spell for left or right click
	 */
	public function spellCasting(x:Float, y:Float, spellSkill:SpellSkill, caster:Caster):Void {
		if (caster == null || spellSkill == null || !spellSkill.canCastSpell())
			return;

		var castSpell:Bool = false;
		var xCast:Float = 0;
		var yCast:Float = 0;
		// Angle from caster to target by default
		var angleCast:Float = Math.atan2(caster.y - y, caster.x - x) * MathUtils.RAD_TO_DEG;

		if (x <= X_NO_CAST_ZONE && y <= Y_NO_CAST_ZONE) {
			castSpell = true;

			xCast = x;
			yCast = y;
		}

		if (castSpell)
			spellSkill.start(xCast, yCast, angleCast, caster);
	}

	public function selectSpellSkill(spellSkill:SpellSkill):Void {
		if (leftSpellCasting.selectSpellSkill(spellSkill)) {
			_casterController.selectSpellSkill(spellSkill);
			updateManualSpellFramePosition();
		}
	}

	public function updateManualSpellFramePosition() {
		leftSpellCasting.updateFramePosition();
	}

	public function addUnit(unit:Unit):Unit {
		var result = _grpEnemies.add(unit);
		_grpEnemies.sort(FlxSort.byY);

		return result;
	}

	public function removeUnit(unit:Unit):Void {
		_grpEnemies.remove(unit, true);
		unit.destroy();

		if (_grpEnemies.length == 0) {
			if (_assaultComplete)
				endAssault(true);
			else if (_waveComplete)
				endWave();
		}
	}

	public function onUnitKilled(unit:Unit, killer:GameObject):Void {
		Trigger.UNIT_KILLED.dispatch(unit, killer);
	}

	public function castSpellFromSpellSkillId(spellId:Int, x:Float, y:Float, angle:Float, caster:Caster):Spell {
		var spellSkill = DataSpell.get().getTSpellSkill(spellId);
		return spellSkill.start(x, y, angle, caster);
	}

	public function addSpell(spell:Spell):Spell {
		_sortSpell = true;

		_grpSpells.add(spell);
		_spells.push(spell);

		return spell;
	}

	public function removeSpell(spell:Spell):Void {
		_grpSpells.remove(spell, true);
		spell.destroy();
	}

	/**
	 * Adds an item on the battlefield
	 * @param	item
	 * @return
	 */
	public function addItem(item:ItemScroll):ItemScroll {
		_items.push(item);
		_grpItems.add(item);

		return item;
	}

	/**
	 * Gives an item scroll to the player
	 * @param	itemScroll
	 */
	public function addItemScroll(itemScroll:ItemScroll) {
		addElement(itemScroll.element, 1);

		// SFX
		//DataSound.get().playSound(Constant.SFX_PICKUP_SCROLL);

		// Remove from the game
		_items.remove(itemScroll);
		_grpItems.remove(itemScroll, true);
		itemScroll.destroy();
	}

	/**
	 * Adds a scroll element to the player
	 * @param	element
	 * @param	count
	 */
	public function addElement(element:Element, count:Int):Void {
		if (count > 0) {
			for (i in 0...count) {
				_player.onAddElement(element);

				// +1 for the element picked up
				_uiGameScrolls.addElement(element);

				_uiAutel.addElement(element);
			}
		}
	}

	public function generateSpell(elements:Array<Element>):SpellSkill {
		elements.sort(Element.sort);

		var spellSkill:SpellSkill = DataSpell.get().getTSpellSkillFromElements(elements);

		if (spellSkill != null) {
			if (_player.onAddSpell(spellSkill)) {
				addSpellSkill(spellSkill, -1);
			} else {
				// Spell buffered, require a remove first
			}

			refreshAOE(spellSkill);
			_spellSkills.push(spellSkill);

			onElementRemoved();
		} else {
			Log.trace("Spell not found ! with elements : " + elements);
		}

		return spellSkill;
	}

	public function addSpellSkill(spellSkill:SpellSkill, position:Int):Void {
		_grpTowers.add(spellSkill.generateIcon());

		if (position == -1)
			position = _lastSelectedIndex;
		
		_uiSpellSelection.addSpell(spellSkill, position);

		_casterController.addSpellAtPosition(spellSkill, position);

		_player.flushBufferedSpell();
	}

	/**
	 * Remove the given spell from the player
	 * @param	spellSkill current spell to be removed or replaced
	 */
	public function removeSpellSkill(spellSkill:SpellSkill) {
		_player.onRemoveSpell(spellSkill);

		// Remove from the Ui
		_uiSpellSelection.removeSpell(spellSkill);

		// Remove from Caster Controller
		_casterController.removeSpellAndCaster(spellSkill);

		// Select an other spell
		for (spell in _player.spells) {
			// FIX SPELLCASTING, selectionner selon le retrait
			selectSpellSkill(spell);
			break;
		}

		// Remove from the game
		spellSkill.destroy();
	}

	public function selectElement(element:Element):Void {
		// Ok if no spell selected
		if (_casterController.selectedSpellSkill == null)
			_uiAutel.selectElementForSlot(element, 0);
	}

	public function levelUpSpell(spellSkill:SpellSkill):Void {
		if (leftSpellCasting.spellSkill == spellSkill) {
			// Do some refresh
		}
		refreshAOE(spellSkill);
		_player.onLevelUpSpell(spellSkill);

		onElementRemoved();
	}

	public function displayAutelForSpellSkill(spellSkill:SpellSkill, levelUp:Bool) {
		_uiAutel.display(spellSkill, levelUp);
	}

	public function onLevelUpClick():Bool {
		return !buttonClicked;
	}

	public function onRecycleClick():Bool {
		return !buttonClicked;
	}

	private function refreshAOE(spellSkill:SpellSkill) {
		// Recresh aoe
		_aoe.scale.x = spellSkill.spellLevel.areaWidth * 2 / 200;
		_aoe.scale.y = spellSkill.spellLevel.areaWidth * 2 / 200;
		_aoe.x = _cursorSelected.x + Constant.CELL_SIZE / 2;
		_aoe.y = _cursorSelected.y + Constant.CELL_SIZE / 2;
		_aoe.visible = true;
	}

	private function onGridCellOver(index:Int):Void {
		var i = index % Constant.GRID_WIDTH;
		var j = Math.floor(index / Constant.GRID_WIDTH);

		_cursorSelection.x = _lastOverPt.x = i * Constant.CELL_SIZE + Constant.BASE_GRID_X;
		_cursorSelection.y =_lastOverPt.y = j * Constant.CELL_SIZE + Constant.BASE_GRID_Y;
	}

	public function initializePlayer(element:Element) {
		var spellSkill = _player.initializeFirstSpell(element);

		// First spell
		_spellSkills.push(spellSkill);

		add(spellSkill.generateIcon());

		_uiSpellSelection.addSpell(spellSkill, Constant.FIRST_POSITION);

		//selectSpellSkill(_spellSkills[0]);
		//add(leftSpellCasting.spellSelector);
	}

	public function dealDamageToWall(damage:Float) {
		FlxG.camera.shake(0.01, 0.1, null, true, FlxAxes.XY);

		if (_player.dealDamage(damage)) {
			// Defeat
			endAssault(false);
		}
	}

	public function retryAssault() {
		var play = new PlayState();
		play.assault = null;
		FlxG.switchState(play);
	}

	public function resume() {
		_paused = false;
	}

	////////////////////////////////////////////////////////////////
	// PRIVATE
	////////////////////////////////////////////////////////////////

	private function initItems() {
		var initialScrolls = Std.int(_attributeController.calculateValue(AttributeType.INITIAL_SCROLLS, AttributeFlag.ANY, 4));
		for (i in 0...initialScrolls)
			addItem(new ItemScroll(Element.pickOneRandom(), FlxG.width / 2 - initialScrolls * Constant.CELL_SIZE + i * Constant.CELL_SIZE * 2, FlxG.height / 2));
	}

	private function endAssault(victory:Bool):Void {
		// Remove scrolls
		for (item in _items) {
			item.destroy();
			remove(item);
		}
		_items = [];

		// Defeat
		if (!victory) {
			// Remove all units)
			for (unit in _grpEnemies) {
				// Small animation for all units
				unit.danceVictory();
			}

			// Destroy the walls
			_fortress.kill();

			// Stop the spawning of units
			CMLFiber._destroyAll();

			_defeat = true;
			_spellcasting = false;
			_uiAssaultCompleted.display(Std.int(_assaultTime), assault.currentWaveId + 1, assault.waveCount);
		}
	}

	private function endWave():Void {
		_uiNextWave.visible = true;
		// Auto pickup scrolls
		for (item in _items) {
			item.retrieve();
		}
		_player.onEndWave();
	}

	private function goNextWave():Void {
		_goNextWave = false;
		_waveComplete = false;
		_assaultComplete = false;
		_uiNextWave.visible = false;

		if (currentWave != null)
			currentWave.endWave();

		currentWave = assault.nextWave();
		if (currentWave != null)
			currentWave.startWave();
	}

	private function onElementRemoved():Void {
		// Refresh scrolls count in the UI
		_uiGameScrolls.refreshScrollsCount();
	}

	private function debugAddUnits():Void {
		_buttonClicked = true;
		if (_currentCommand != AddUnits) {
			_currentCommand = AddUnits;
		}
	}

	private function debugSpells():Void {
		_buttonClicked = true;
		if (_currentCommand != Spells) {
			_currentCommand = Spells;
		}
	}

	private function collideSpellEnemy(spell:Spell, unit:Unit):Void {
		if (!unit.exists || !spell.applyDamage(unit))
			return;

		if (!unit.invulnerable) {
			// Apply damage
			unit.dealDamageFromSpell(spell, spell.caster);

			// To apply buffs
			spell.onDamageUnit(unit);
		}

		if (spell.collide) {
			spell.spellCML.destroy(SpellCML.DEST_STATUS_FROM_CML);
		}
	}

	private function collideSpellEnemyFlx(obj1:GameSprite, obj2:GameSprite):Void {
		collideSpellEnemy(cast(obj1.parent, Spell), cast(obj2.parent, Unit));
	}

	private function collideSpellEnemyNape(i:InteractionCallback):Void {
		var s:GameSprite = cast(i.int1, Body).userData.data;
		var e:GameSprite = cast(i.int2, Body).userData.data;

		var spell = cast(s.parent, Spell);

		if (!spell.dot)
			collideSpellEnemy(spell, cast(e.parent, Unit));
	}

	private function collideOngoingSpellEnemyNape(i:InteractionCallback):Void {
		var s:GameSprite = cast(i.int1, Body).userData.data;
		var e:GameSprite = cast(i.int2, Body).userData.data;

		var spell = cast(s.parent, Spell);

		if (spell.dot)
			collideSpellEnemy(spell, cast(e.parent, Unit));
	}

	private function collideEnemyWall(i:InteractionCallback):Void {
		var e:GameSprite = cast(i.int1, Body).userData.data;
		var w:GameSprite = cast(i.int2, Body).userData.data;

		var unit:Unit = cast(e.parent, Unit);

		unit.attackWall(cast(w.parent, Wall));
	}

	private function refreshUnit() {
		var urlLoader = new URLLoader();
		urlLoader.addEventListener(Event.COMPLETE, function(_) {
			Log.trace("Refresh Unit, tunits file loaded !");

			DataUnit.get().reset();

			CMLFiber._destroyAll();

			// Stop the units and remove them
			for (unit in _grpEnemies.members) {
				unit.kill();
			}

			_grpEnemies.clear();

			// Stop the spells
			for (spell in _grpSpells.members) {
				spell.destroy();
			}

			_grpSpells.clear();

			var xml = new Access(Xml.parse(urlLoader.data)).node.data;
			DataUnit.get().loadFromXML(xml.node.unitdatas);

			resetMainCMLSequence();
		});
		urlLoader.load(new URLRequest("assets/data/tunits3.xml"));
	}

	////////////////////////////////////////////////////////////////
	// CANNON ML
	////////////////////////////////////////////////////////////////

	/**
	 * Call AFTER data loading
	 */
	private function initCannonML():Void {
		// CannonML - Horizontal
		CMLObject.initialize(false);

		// To avoid bug, require at least one user command
		CMLSequence.registerUserCommand("bugCannonML", bugCannonML);

		// Custom function ===================================
		// Global
		CMLSequence.registerUserCommand("zzlog", logML);
		CMLSequence.registerUserCommand("zzrdmtarget", randomTargetInRange, 3);
		CMLSequence.registerUserCommand("zzlightning", lightningCML, 4);
		CMLSequence.registerUserCommand("zzendassault", endAssaultCML);
		CMLSequence.registerUserCommand("zzendwave", endWaveCML);
		CMLSequence.registerUserCommand("zzsound", soundCML, 1);

		// Spell related
		CMLSequence.registerUserCommand("zzscale", SpellCML.scaleCML, 2);
		CMLSequence.registerUserCommand("zzhbradius", SpellCML.hitboxRadiusCML, 1);

		// Custom User variable ===================================
		// Global
		CMLSequence.registerUserValiable("zzwidth", widthCML);
		CMLSequence.registerUserValiable("zzheight", heightCML);
		CMLSequence.registerUserValiable("zzplayerx", playerXCML);
		CMLSequence.registerUserValiable("zzplayery", playerYCML);
		CMLSequence.registerUserValiable("zznextwave", nextWaveCML);

		// Spell related
		CMLSequence.registerUserValiable("zzdur", SpellCML.durationCML);
		CMLSequence.registerUserValiable("zzrange", SpellCML.rangeCML);
		CMLSequence.registerUserValiable("zzheightrange", SpellCML.heightRangeCML);
		CMLSequence.registerUserValiable("zzangle", SpellCML.angleCML);
		CMLSequence.registerUserValiable("zzlvl", SpellCML.levelCML);
		CMLSequence.registerUserValiable("zzcasterx", SpellCML.casterXCML);
		CMLSequence.registerUserValiable("zzcastery", SpellCML.casterYCML);

		resetMainCMLSequence();

		/*
			_player.cmlPlayer.create(_player.x, _player.y);
			_player.cmlPlayer.setAsDefaultTarget();
		 */

		_targetForPlayer = new CMLObject();
		_targetForPlayer.create(100, 100);
	}

	private function resetMainCMLSequence() {
		var cmlScript = "#TEST {[bm10,360 f3 w60]}; ";

		// Useful functions
		var cmlFunctions:String = "#RANDOMPOS {p $i(" + FlxG.width + "), $i(" + FlxG.height + ")}; ";
		cmlFunctions += "#SPEED1{v0.4, 0};";
		cmlFunctions += "#SPEED2{v0.6, 0};";
		cmlFunctions += "#SPEED3{v0.8, 0};";
		cmlFunctions += "#SPEED4{v1.0, 0};";
		cmlFunctions += "#SPEED5{v1.2, 0};";
		cmlFunctions += "#SPEED6{v1.4, 0};";
		cmlFunctions += "#SPEED7{v1.6, 0};";
		cmlFunctions += "#SPEED8{v1.8, 0};";
		cmlFunctions += "#SPEED9{v2.0, 0};";

		/** 
			Set the object creation point at the player position
			$x, $y : x,y target
		**/
		cmlFunctions += "#TARGET_POS{q $zzcasterx - $x, $zzcastery - $y};";

		cmlScript += cmlFunctions;
		cmlScript += DataSpell.get().spellScript;
		cmlScript += DataUnit.get().unitScript;

		if (_cmlScript != null) {
			_cmlScript.clear();
		}

		_cmlScript = new CMLSequence(cmlScript);
	}

	/**
	 * Cannon ML must have at least one custom function
	 * @param	fbr
	 * @param	args
	 */
	private function bugCannonML(fbr:CMLFiber, args:Array<Dynamic>):Void {}

	private function randomTargetInRange(fbr:CMLFiber, args:Array<Dynamic>):Void {
		var x:Float = args[0];
		var y:Float = args[1];
		var radius:Float = args[2];

		var targets = FlxNapeSpace.space.bodiesInCircle(Vec2.weak(x, y), radius, false,
			new InteractionFilter(GameObject.FRIENDLY_MISSILE | GameObject.FRIENDLY_UNIT, ~GameObject.FRIENDLY_MISSILE & ~GameObject.FRIENDLY_UNIT,
				GameObject.FRIENDLY_MISSILE | GameObject.FRIENDLY_UNIT, ~GameObject.FRIENDLY_MISSILE & ~GameObject.FRIENDLY_UNIT));

		if (targets.length > 0) {
			var target = targets.at(Math.floor(Math.random() * targets.length));

			_targetForPlayer.x = target.position.x;
			_targetForPlayer.y = target.position.y;
		} else {
			// Keep same point by default
			_targetForPlayer.x = x;
			_targetForPlayer.y = y;
		}
	}

	/**
	 * 
	 * @param	fbr
	 * @param	args 4, start x, start y, end x, end y
	 */
	private function lightningCML(fbr:CMLFiber, args:Array<Dynamic>):Void {
		var light = new Lightning(args[0], args[1], args[2], args[3]);

		if (args.length > 4) {
			light.lightningOffset = args[4];
			light.lightningFrequency = args[5];
		}

		add(light);
	}

	/**
	 * 
	 * @param	fbr
	 * @param	args 0
	 */
	private function endAssaultCML(fbr:CMLFiber, args:Array<Dynamic>):Void {
		_waveComplete = true;
		_assaultComplete = true;
	}

	/**
	 * 
	 * @param	fbr
	 * @param	args 0
	 */
	private function endWaveCML(fbr:CMLFiber, args:Array<Dynamic>):Void {
		_waveComplete = true;
	}

	private function soundCML(fbr:CMLFiber, args:Array<Dynamic>):Void {
		// Assets.getSound(AssetPaths.fireball_impact_burn_02__wav).play();

		if (args.length > 0) {
			var id = args[0];
			var volume:Float = 1;

			if (args.length > 1) {
				volume = args[1];
			}

			//DataSound.get().playSound(id, volume);
		}
	}

	/**
	 * Returns width of game area
	 * @param	fbr
	 * @return
	 */
	private function widthCML(fbr:CMLFiber):Float {
		return FlxG.width - 80;
	}

	/**
	 * Returns height of game area
	 * @param	fbr
	 * @return
	 */
	private function heightCML(fbr:CMLFiber):Float {
		return FlxG.height;
	}

	/**
	 * Simply returns the X position of the player
	 * @param	fbr
	 * @return
	 */
	private function playerXCML(fbr:CMLFiber):Float {
		return _casterController.playerCaster.x + 4;
	}

	/**
	 * Simply returns the Y position of the player
	 * @param	fbr
	 * @return
	 */
	private function playerYCML(fbr:CMLFiber):Float {
		return _casterController.playerCaster.y + 20;
	}

	/**
	 		 * Returns the flag to go to next wave
	 * @param	fbr
	 * @return
	 */
	private function nextWaveCML(fbr:CMLFiber):Float {
		if (_goNextWave) {
			goNextWave();
			return 1;
		}

		return 0;
	}

	/**
	 * Trace the given parameters
	 * @param	fbr
	 * @param	args
	 */
	private function logML(fbr:CMLFiber, args:Array<Dynamic>):Void {
		var log:String = "";
		for (arg in args) {
			log += arg + " ";
		}
		Log.trace(log);
	}

	function setScaleMode(scaleMode:ScaleMode) {
		currentPolicy.text = scaleMode;

		FlxG.scaleMode = switch (scaleMode) {
			case ScaleMode.RATIO_DEFAULT:
				new RatioScaleMode();

			case ScaleMode.RATIO_FILL_SCREEN:
				new RatioScaleMode(true);

			case ScaleMode.FIXED:
				new FixedScaleMode();

			case ScaleMode.RELATIVE:
				new RelativeScaleMode(0.75, 0.75);

			case ScaleMode.FILL:
				new FillScaleMode();
		}

		// FlxG.resizeGame(640, 480);
	}

	////////////////////////////////////////////////////////////////
	// GETTERS / SETTERS
	////////////////////////////////////////////////////////////////

	public function getPlayerSpellSkill():SpellSkill {
		return leftSpellCasting.spellSkill;
	}

	@:noCompletion
	function get_cmlScript():CMLSequence {
		return _cmlScript;
	}

	@:noCompletion
	function get_targetForPlayer():CMLObject {
		return _targetForPlayer;
	}

	@:noCompletion
	function get_fortress():Fortress {
		return _fortress;
	}

	@:noCompletion
	function get_uiGameScrolls():UIGameScrolls {
		return _uiGameScrolls;
	}

	@:noCompletion
	function get_attributeController():AttributeController {
		return _attributeController;
	}

	@:noCompletion
	function get_skillController():SkillController {
		return _skillController;
	}

	@:noCompletion
	function get_buttonClicked():Bool {
		return _buttonClicked;
	}

	@:noCompletion
	function get_currentTime():Float {
		return _currentTime;
	}

	@:noCompletion
	function get_uiAutel():UIAutel {
		return _uiAutel;
	}

	function set_buttonClicked(value:Bool):Bool {
		return _buttonClicked = value;
	}

	@:noCompletion
	function get_X_NO_CAST_ZONE():Int {
		return (FlxG.width - 7 * Constant.CELL_SIZE);
	}

	@:noCompletion
	function get_Y_NO_CAST_ZONE():Int {
		return (FlxG.height);
	}
	@:noCompletion
	function get_casterController():CasterController {
		return _casterController;
	}
}
