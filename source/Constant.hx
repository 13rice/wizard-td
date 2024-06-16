package;

/**
 * ...
 * @author 13rice
 */
class Constant {
	public static inline var CELL_SIZE:Int = 32;
	public static inline var GRID_WIDTH:Int = 16;
	public static inline var GRID_HEIGHT:Int = 12;
	public static inline var BASE_GRID_X:Int = Constant.CELL_SIZE;
	public static inline var BASE_GRID_Y:Int = 2 * Constant.CELL_SIZE;

	// Spritesheets
	public static inline var ATLAS_SPRITESHEET = "sprite_sheet.png";
	public static inline var ATLAS_FX = "fx.png";
	public static inline var ATLAS_DOODADS = "doodads.png";
	public static inline var ATLAS_UI = "ui.png";
	public static inline var ATLAS_FADING = "rect_fading.png";

	// AOE GRAPHICS ========================
	static public inline var DEFAULT_ANIM_FPS:Int = 16;

	static public inline var BLOOD_KILL_FACTOR:Float = 0.75;
	static public inline var BLOOD_DAMAGE_FACTOR:Float = 0.33;

	// PLAYER ======================================================
	public static inline var DEFAULT_CRITICAL_DAMAGE:Int = 2; // factor
	#if debug
	public static inline var DEFAULT_SCROLLS:Int = 100;
	#else
	public static inline var DEFAULT_SCROLLS:Int = 1;
	#end
	public static inline var FIRST_POSITION:Int = 68;

	// SPELL ======================================================
	public static inline var SPELL_BASE_FIRE_ID:Int = 2000012;
	public static inline var SPELL_BASE_METAL_ID:Int = 2000015;
	public static inline var SPELL_BASE_WATER_ID:Int = 2000021;

	public static inline var SPELL_AREA_DAMAGE_ID:Int = 2000041;

	// Some specific skills
	static public inline var SKILL_PLAYER_RECYCLE_TWO:String = "PLAYER_RECYCLE_TWO";

	// AFFINITY_[Element]
	static public inline var AFFINITY_PREFIX:String = "AFFINITY_";
	static public inline var BURN_DOT_NAME:String = "BURN";
	static public inline var BURN_DOT_DURATION:Float = 5;
	static public inline var BURN_DOT_DAMAGE:Float = 0.5;
	static public inline var BURN_DOT_IMAGE:String = "flame_burn_";

	// SFX ============================
	static public inline var SFX_CLICK_SCROLL:Int = 1000;
	static public inline var SFX_CREATE_SPELL:Int = 1001;
	static public inline var SFX_UPGRADE_SPELL:Int = 1002;
	static public inline var SFX_BOOK_CLOSED:Int = 1003;
	static public inline var SFX_BOOK_OPEN:Int = 1004;

	static public inline var SFX_PICKUP_SCROLL:Int = 1020;
	static public inline var SFX_BURN_SCROLL:Int = 1021;

	static public inline var SFX_FREEZE_1:Int = 3030;
	static public inline var SFX_FREEZE_2:Int = 3031;

	// UI ==========================================================
	public static inline var BLACK_MASK = 0x77000000;
	public static inline var PRE_WAIT_ASSAULT_COMPLETED = 0.7;

	// Ideal size : 10
	public static inline var FONT_SMALL_DIGIT_BMP = "assets/fonts/retroville_nc_10.png";
	public static inline var FONT_SMALL_DIGIT_FNT = "assets/fonts/retroville_nc_10.fnt";
	public static inline var FONT_SMALL_DIGIT = "Retroville NC";
	public static inline var FONT_SMALL_DIGIT_SIZE = 10;
	// Ideal size : 10
	public static inline var FONT_SMALL_TEXT_BMP = "assets/fonts/retroville_nc_10.png";
	public static inline var FONT_SMALL_TEXT_FNT = "assets/fonts/retroville_nc_10.fnt";
	public static inline var FONT_SMALL_TEXT = "Retroville NC";
	public static inline var FONT_SMALL_TEXT_SIZE = 10;
	// Ideal size : 16
	public static inline var FONT_MEDIUM_DIGIT_BMP = "assets/fonts/MisterPixel16Regular_16.png";
	public static inline var FONT_MEDIUM_DIGIT_FNT = "assets/fonts/MisterPixel16Regular_16.fnt";
	public static inline var FONT_MEDIUM_DIGIT = "MP16REG";
	public static inline var FONT_MEDIUM_DIGIT_SIZE = 16;
	// Ideal size : 19
	public static inline var FONT_FANTASTIC_BMP = "assets/fonts/VeniceClassic_white_19_0.png";
	public static inline var FONT_FANTASTIC_FNT = "assets/fonts/VeniceClassic_white_19.fnt";
	public static inline var FONT_FANTASTIC = "Venice Classic";
	public static inline var FONT_FANTASTIC_SIZE = 19;
}