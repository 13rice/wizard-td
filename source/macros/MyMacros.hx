package macros;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
using Lambda;

class MyMacros
{
	/**
	 * https://code.haxe.org/category/macros/add-parameters-as-fields.html
	 * @return
	 */
   macro static public function initLocals():Expr
   {
		// Grab the variables accessible in the context the macro was called.
		var locals = Context.getLocalVars();
		var fields = Context.getLocalClass().get().fields.get();

		var exprs:Array<Expr> = [];
		for (local in locals.keys())
		{
			if (fields.exists(function(field) return field.name == local))
			{
				exprs.push(macro this.$local = $i{local});
			}
			else
			{
				throw new Error(Context.getLocalClass() + " has no field " + local, Context.currentPos());
			}
		}
		
		// Generates a block expression from the given expression array 
		return macro $b{exprs};
  }
  
  
	/**
	* Generate :
	* 	var xml = Xml.createElement("<class name>.toLower");
		var node:Xml = null;
		
		<for each field>
		node = Xml.createElement("<field name x>");
		node.addChild(Xml.createPCData(<field name x> + ""));
		xml.addChild(node);
		
		return xml;
	* @return
	*/
	macro static public function toXml():Expr
	{
		var fields = Context.getLocalClass().get().fields.get();
		var className = Context.getLocalClass().get().name.toLowerCase();
		
		var exprs:Array<Expr> = [];
		
		var fieldNode = [];
		for (field in fields)
		{
			switch (field.kind)
			{
				case FieldKind.FVar(r, w):
					fieldNode.push(macro {
							node = Xml.createElement($v{field.name});
							node.addChild(Xml.createPCData($i{field.name} + ""));
							xml.addChild(node);
						});
				default:
					
			}
		}
		
		// OK
		var ret = macro return xml;
		
		exprs.push(macro {
			var node:Xml = null;
			var xml = Xml.createElement($v{className});
			
			$b{fieldNode}
			
			${ret}
		});
		
		// NOT OK
		// exprs.push(macro { return xml; } );
		
		
		return macro $b{exprs};
	}
}