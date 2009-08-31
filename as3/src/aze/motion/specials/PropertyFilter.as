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
	private var removeWhenFinished:Boolean;
	private var isNewFilter:Boolean;
	
	public function FilterBase(target:Object, value:*, next:EazeSpecial)
	{
		super(target, value, next);
		
		var disp:DisplayObject = DisplayObject(target);
		var current:BitmapFilter = getCurrentFilter(disp, false);
		
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
				fvalue[prop] = val;
				properties.push(prop);
			}
		}
	}
	
	override public function init(reverse:Boolean):void 
	{
		var disp:DisplayObject = DisplayObject(target);
		var current:BitmapFilter = getCurrentFilter(disp);
		
		var begin:BitmapFilter;
		var end:BitmapFilter;
		if (reverse) { begin = fvalue; end = current; }
		else { begin = current; end = fvalue; }
		
		start = { };
		delta = { };
		
		for (var i:int = 0; i < properties.length; i++) 
		{
			var prop:String = properties[i];
			var val:* = fvalue[prop];
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
			start[prop] = begin[prop];
			delta[prop] = end[prop] - start[prop];
		}
		fvalue = null;
		
		addFilter(disp, begin);
	}
	
	private function addFilter(disp:DisplayObject, filter:BitmapFilter):void
	{
		var filters:Array = disp.filters || [];
		filters.push(filter);
		disp.filters = filters;
	}
	
	private function getCurrentFilter(disp:DisplayObject, remove:Boolean = true):BitmapFilter
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
		var current:BitmapFilter = getCurrentFilter(disp);
		
		for (var i:int = 0; i < properties.length; i++) 
		{
			var prop:String = properties[i];
			if (prop)
			{
				current[prop] = start[prop] + ease.calculate(k) * delta[prop];
			}
		}
		if (!removeWhenFinished || k < 1.0) addFilter(disp, current);
		else disp.filters = disp.filters;
	}
		
	override public function dispose():void
	{
		start = delta = null;
		fvalue = null;
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
