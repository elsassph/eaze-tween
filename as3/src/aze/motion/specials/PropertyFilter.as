package aze.motion.specials 
{
	import aze.motion.easing.IEazeEasing;
	import aze.motion.Eaze;
	import flash.filters.BlurFilter;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	
	/**
	 * Filters tweening as special properties
	 * @author Philippe / http://philippe.elsass.me
	 */
	public class PropertyFilter
	{
		static public function register():void
		{
			Eaze.specialProperties["blurFilter"] = FilterBlur;
			Eaze.specialProperties["glowFilter"] = FilterGlow;
			Eaze.specialProperties["dropShadowFilter"] = FilterDropShadow;
			//Eaze.specialProperties["colorMatrixFilter "]= FilterDropShadow;
			Eaze.specialProperties[BlurFilter] = FilterBlur;
			Eaze.specialProperties[GlowFilter] = FilterGlow;
			Eaze.specialProperties[DropShadowFilter] = FilterDropShadow;
			//Eaze.specialProperties[ColorMatrixFilter] = FilterDropShadow;
		}
		
	}

}

import aze.motion.easing.IEazeEasing;
import aze.motion.specials.EazeSpecial;
import flash.display.DisplayObject;
import flash.filters.BevelFilter;
import flash.filters.BitmapFilter;
import flash.filters.BlurFilter;
import flash.filters.ColorMatrixFilter;
import flash.filters.DropShadowFilter;
import flash.filters.GlowFilter;

class FilterBase extends EazeSpecial
{
	static public var fixedProp:Object = { quality:true, color:true };
	
	private var properties:Array;
	private var fvalue:BitmapFilter;
	private var start:Object;
	private var delta:Object;
	private var fColor:Object;
	private var startColor:Object;
	private var deltaColor:Object;
	private var removeWhenFinished:Boolean;
	private var isNewFilter:Boolean;
	
	public function FilterBase(target:Object, value:*, next:EazeSpecial)
	{
		super(target, value, next);
		
		var disp:DisplayObject = DisplayObject(target);
		var current:BitmapFilter = getCurrentFilter(disp, false); // read filter only
		
		properties = [];
		fvalue = current.clone();
		for (var prop:String in value) 
		{
			var val:* = value[prop];
			if (prop == "remove") 
			{
				// special: remove filter when tween ends
				removeWhenFinished = val;
			}
			else
			{
				if (prop == "color" && !isNewFilter)
					fColor = { r:(val >> 16) & 0xff, g:(val >> 8) & 0xff, b:val & 0xff };
				fvalue[prop] = val;
				properties.push(prop);
			}
		}
	}
	
	override public function init(reverse:Boolean):void 
	{
		var disp:DisplayObject = DisplayObject(target);
		var current:BitmapFilter = getCurrentFilter(disp, true); // get and remove
		
		var begin:BitmapFilter;
		var end:BitmapFilter;
		var curColor:Object;
		var endColor:Object;
		var val:*;
		if (fColor) 
		{
			val = current["color"];
			curColor = { r:(val >> 16) & 0xff, g:(val >> 8) & 0xff, b:val & 0xff };
		}
		if (reverse) { begin = fvalue; end = current; startColor = fColor; endColor = curColor; }
		else { begin = current; end = fvalue; startColor = curColor; endColor = fColor; }
		
		start = { };
		delta = { };
		
		for (var i:int = 0; i < properties.length; i++) 
		{
			var prop:String = properties[i];
			val = fvalue[prop];
			if (val is Boolean)
			{
				// filter options set immediately
				current[prop] = val;
				properties[i] = null;
				continue;
			}
			else if (isNewFilter) 
			{
				// object did not have the filter, initialize it
				if (prop in fixedProp) 
				{
					// set property and do not tween it
					current[prop] = val;
					properties[i] = null;
					continue;
				}
				else 
				{
					// set to 0
					current[prop] = 0;
				}
			}
			else if (prop == "color" && fColor)
			{
				// decompose color for tweening
				deltaColor = { 
					r:endColor.r - startColor.r, 
					g:endColor.g - startColor.g, 
					b:endColor.b - startColor.b 
				};
				properties[i] = null; // not tweened
				continue;
			}
			start[prop] = begin[prop];
			delta[prop] = end[prop] - start[prop];
		}
		fvalue = null;
		fColor = null;
		
		addFilter(disp, begin);
	}
	
	private function addFilter(disp:DisplayObject, filter:BitmapFilter):void
	{
		var filters:Array = disp.filters || [];
		filters.push(filter);
		disp.filters = filters;
	}
	
	/**
	 * Get existing matching filer or create new one.
	 * If that's a new filter, set "isNewFilter" to true.
	 */
	private function getCurrentFilter(disp:DisplayObject, remove:Boolean):BitmapFilter
	{
		var model:Class = filterClass;
		if (disp.filters)
		{
			var index:int;
			var filters:Array = disp.filters;
			for (index = 0; index < filters.length; index++)
				if (filters[index] is model) 
				{
					if (remove) 
					{
						var filter:BitmapFilter = filters.splice(index, 1)[0];
						disp.filters = filters;
						return filter;
					}
					else return filters[index];
				}
		}
		isNewFilter = true;
		return new model();
	}
	
	override public function update(ease:IEazeEasing, k:Number):void
	{
		var disp:DisplayObject = DisplayObject(target);
		var current:BitmapFilter = getCurrentFilter(disp, true); // and remove
		
		var ek:Number = ease.calculate(k);
		for (var i:int = 0; i < properties.length; i++) 
		{
			var prop:String = properties[i];
			if (prop)
			{
				current[prop] = start[prop] + ek * delta[prop];
			}
		}
		if (startColor)
		{
			current["color"] = 
				((startColor.r + ek * deltaColor.r) << 16)
				| ((startColor.g + ek * deltaColor.g) << 8)
				| (startColor.b + ek * deltaColor.b);
		}
		
		if (!removeWhenFinished || k < 1.0) addFilter(disp, current);
		else disp.filters = disp.filters;
	}
		
	override public function dispose():void
	{
		start = delta = null;
		startColor = deltaColor = null;
		fvalue = null; fColor = null;
		properties = null;
		super.dispose();
	}
	
	public function get filterClass():Class { return null; }
}

/*class FilterColorMatrix extends FilterBase
{
	public function FilterColorMatrix(target:Object, value:*, next:EazeSpecial)
	{
		super(target, value, next);
	}
	
	override public function get filterClass():Class { return ColorMatrixFilter; }
}*/

class FilterBlur extends FilterBase
{
	public function FilterBlur(target:Object, value:*, next:EazeSpecial)
	{
		super(target, value, next);
	}
	
	override public function get filterClass():Class { return BlurFilter; }
}

class FilterGlow extends FilterBase
{
	public function FilterGlow(target:Object, value:*, next:EazeSpecial)
	{
		super(target, value, next);
	}
	
	override public function get filterClass():Class { return GlowFilter; }
}

class FilterDropShadow extends FilterBase
{
	public function FilterDropShadow(target:Object, value:*, next:EazeSpecial)
	{
		super(target, value, next);
	}
	
	override public function get filterClass():Class { return DropShadowFilter; }
}
