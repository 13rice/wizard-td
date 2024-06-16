package global;

/**
 * ...
 * @author 
 */
class TSound 
{
	var name:String = "";
	
	var id:Int = 0;
	
	public var source:String = "";
	
	public var extension:String = "";
	
	public var volume:Float = 1.0;
	
	public var delay:Float = 0.0;
	
	public function new(name:String, id:Int, source:String, ext:String, volume:Float = 1.0, delay:Float = 0.0)
	{
		this.name = name;
		this.id = id;
		this.source = source;
		this.extension = ext;
		this.volume = volume;
		this.delay = delay;
	}
	
	
	
}