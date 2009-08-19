package aze.motion.specials 
{
	import aze.motion.easing.IEazeEasing;
	import aze.motion.Eaze;
	import flash.filters.BlurFilter;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	
	/**
	 * ...
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
	private var start:Object;
	private var delta:Object;
	private var properties:Array;
	private var removeWhenFinished:Boolean;
	
	public function FilterBase(target:Object, value:*, reverse:Boolean, next:EazeSpecial)
	{
		super(target, value, reverse, next);
		
		var disp:DisplayObject = DisplayObject(target);
		var current:BitmapFilter = getCurrentFilter(disp, true);
		var filter:BitmapFilter = current.clone();
		
		properties = [];
		for (var prop:String in value) 
		{
			if (prop == "remove") removeWhenFinished = value.remove;
			else
			{
				properties.push(prop);
				filter[prop] = value[prop];
			}
		}
		
		var begin:BitmapFilter;
		var end:BitmapFilter;
		if (reverse) { begin = filter; end = current; }
		else { begin = current.clone(); end = filter; }
		addFilter(disp, begin); 
		
		start = { };
		delta = { };
		var v:Number;
		for each(prop in properties) 
		{
			start[prop] = begin[prop];
			delta[prop] = end[prop] - start[prop];
		}
	}
	
	private function addFilter(disp:DisplayObject, filter:BitmapFilter):void
	{
		var filters:Array = disp.filters || [];
		filters.push(filter);
		disp.filters = filters;
	}
	
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
		return new model();
	}
	
	override public function update(ease:IEazeEasing, k:Number):void
	{
		var disp:DisplayObject = DisplayObject(target);
		var current:BitmapFilter = getCurrentFilter(disp, true);
		
		for each(var prop:String in properties) 
			current[prop] = start[prop] + ease.calculate(k) * delta[prop];
		
		if (!removeWhenFinished || k < 1.0) addFilter(disp, current);
		else disp.filters = disp.filters;
	}
		
	override public function dispose():void
	{
		start = null;
		delta = null;
	}
	
	public function get filterClass():Class { return null; }
}

class FilterColorMatrix extends FilterBase
{
	public function FilterColorMatrix(target:Object, value:*, reverse:Boolean, next:EazeSpecial)
	{
		super(target, value, reverse, next);
	}
	
	override public function get filterClass():Class { return ColorMatrixFilter; }
}

class FilterBlur extends FilterBase
{
	public function FilterBlur(target:Object, value:*, reverse:Boolean, next:EazeSpecial)
	{
		super(target, value, reverse, next);
	}
	
	override public function get filterClass():Class { return BlurFilter; }
}

class FilterGlow extends FilterBase
{
	public function FilterGlow(target:Object, value:*, reverse:Boolean, next:EazeSpecial)
	{
		super(target, value, reverse, next);
	}
	
	override public function get filterClass():Class { return GlowFilter; }
}

class FilterDropShadow extends FilterBase
{
	public function FilterDropShadow(target:Object, value:*, reverse:Boolean, next:EazeSpecial)
	{
		super(target, value, reverse, next);
	}
	
	override public function get filterClass():Class { return DropShadowFilter; }
}
