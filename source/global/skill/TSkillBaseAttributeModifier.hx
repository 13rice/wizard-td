package global.skill;

import global.attribute.AttributeFlag;
import global.attribute.AttributeModifier;

class TSkillBaseAttributeModifier extends TBaseAttributeModifier {
	public var x:Int = 0;
	public var y:Int = 0;
	public var name:String = "";
	public var level:Int = 0;
	public var maxLevel:Int = 1;
	public var category:String = "";
	public var stage:Int = 1;

	public function new(id:String, value:Float, flags:AttributeFlag, mod:AttributeMod, attribute:AttributeType, description:String, bonusDescription:String,
			x:Int, y:Int, name:String, level:Int, maxLevel:Int, category:String, stage:Int) {
		super(id, value, flags, mod, attribute, description, bonusDescription);

		this.x = x;
		this.y = y;
		this.name = name;
		this.level = level;
		this.maxLevel = maxLevel;
		this.category = category;
		this.stage = stage;
	}
}