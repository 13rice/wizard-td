package worldmap;

import global.shared.Log;
import global.attribute.AttributeFlag;
import global.attribute.AttributeModifier;
import gameObject.Unit;
import gameObject.GameObject;
import gameObject.items.ItemScroll;
import gameObject.items.ItemScroll.Element;
import global.Trigger;

/**
 * ...
 * @author 13rice
 */
class Wave {
	public var unitCount(default, null):Int;

	public var scrollCount(default, null):Int;

	public var scrolls(default, null):Map<Element, Int> = new Map();

	private var currentScrollCount:Int = 0;

	private var nextSpawn:Int = 0;

	public function new(unitCount:Int, scrolls:Int) {
		this.unitCount = unitCount;
		scrollCount = scrolls;
	}

	public function addScrollType(type:Element, count:Int):Void {
		scrolls[type] = count;
	}

	public function startWave():Void {
		var scrollBonus = PlayState.get().attributeController.calculateValue(AttributeType.SCROLL_PER_WAVE, AttributeFlag.PLAYER, 0);
		scrollCount += Std.int(scrollBonus);

		if (scrollCount > 0) {
			Trigger.UNIT_KILLED.add(onUnitKilled);

			currentScrollCount = scrollCount;
			refreshNextScrollSpawn();
		}
	}

	public function endWave():Void {
		if (scrollCount > 0) {
			Trigger.UNIT_KILLED.remove(onUnitKilled);
		}
	}

	public function onUnitKilled(killed:Unit, killer:GameObject):Void {
		if (currentScrollCount > 0) {
			nextSpawn--;

			if (nextSpawn < 0) {
				// Select a random element
				var keys = [for (key in scrolls.keys()) key];
				var element:Element = keys[Math.floor(Math.random() * keys.length)];

				if (element != Element.FIRE && element != Element.METAL && element != Element.WATER)
					Log.error("UNKNOWN ELEMENT: " + element);

				// Place the item
				PlayState.get().addItem(new ItemScroll(element, killed.x - killed.width / 2, killed.y - killed.height / 2));

				// Remove the element from the pool
				scrolls[element]--;
				if (scrolls[element] == 0)
					scrolls.remove(element);

				currentScrollCount--;

				refreshNextScrollSpawn();
			}
		}
	}

	private function refreshNextScrollSpawn():Void {
		nextSpawn = Math.floor(Math.random() * (unitCount / scrollCount));
	}
}