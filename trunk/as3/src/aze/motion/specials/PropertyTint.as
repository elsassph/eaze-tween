package aze.motion.specials 
{
	import aze.motion.Eaze;
	import aze.motion.easing.IEazeEasing;
	import aze.motion.easing.Linear;
	import flash.display.DisplayObject;
	import flash.geom.ColorTransform;
	
	/**
	 * ...
	 * @author Philippe / http://philippe.elsass.me
	 */
	public class PropertyTint extends EazeSpecial
	{
		static public function register():void
		{
			Eaze.specialProperties.tint = PropertyTint;
		}
		
		private var start:ColorTransform;
		private var tvalue:ColorTransform;
		private var delta:ColorTransform;
		
		function PropertyTint(target:Object, value:*, next:EazeSpecial)
		{
			super(target, value, next);
			var disp:DisplayObject = DisplayObject(target);
			
			if (value === null) tvalue = new ColorTransform();
			else 
			{
				var color:uint = value;
				var mix:Number = (color > 0xffffff) ? ((color >> 24) & 0xff) / 255.0 : 0.5;
				var amix:Number;
				if (mix <= 0.5) { amix = 1 - mix * 2; mix *= 2; }
				else { amix = 1; mix = Math.min(1, (mix - 0.49) * 2); }
				
				tvalue = new ColorTransform();
				tvalue.redMultiplier = amix;
				tvalue.greenMultiplier = amix;
				tvalue.blueMultiplier = amix;
				tvalue.redOffset = mix * ((color >> 16) & 0xff);
				tvalue.greenOffset = mix * ((color >> 8) & 0xff);
				tvalue.blueOffset = mix * (color & 0xff);
			}
		}
		
		override public function init(reverse:Boolean):void 
		{
			var disp:DisplayObject = DisplayObject(target);
			
			if (reverse) { start = tvalue; tvalue = disp.transform.colorTransform; }
			else { start = disp.transform.colorTransform; }
			
			delta = new ColorTransform(
				tvalue.redMultiplier - start.redMultiplier,
				tvalue.greenMultiplier - start.greenMultiplier,
				tvalue.blueMultiplier - start.blueMultiplier,
				0,
				tvalue.redOffset - start.redOffset,
				tvalue.greenOffset - start.greenOffset,
				tvalue.blueOffset - start.blueOffset
			);
			tvalue = null;
			
			if (reverse) update(Linear.easeNone, 1);
		}
		
		override public function update(ease:IEazeEasing, k:Number):void
		{
			var disp:DisplayObject = DisplayObject(target);
			
			var ke:Number = ease.calculate(k);
			var t:ColorTransform = disp.transform.colorTransform;
			
			t.redMultiplier = start.redMultiplier + delta.redMultiplier * ke;
			t.greenMultiplier = start.greenMultiplier + delta.greenMultiplier * ke;
			t.blueMultiplier = start.blueMultiplier + delta.blueMultiplier * ke;
			t.redOffset = start.redOffset + delta.redOffset * ke;
			t.greenOffset = start.greenOffset + delta.greenOffset * ke;
			t.blueOffset = start.blueOffset + delta.blueOffset * ke;
			
			disp.transform.colorTransform = t;
		}
		
		override public function dispose():void
		{
			start = delta = null;
			tvalue = null;
		}
	}

}