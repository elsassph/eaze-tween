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
		private var delta:ColorTransform;
		
		function PropertyTint(target:Object, value:*, reverse:Boolean, next:EazeSpecial)
		{
			super(target, value, reverse, next);
			var disp:DisplayObject = DisplayObject(target);
			
			var transformTint:ColorTransform;
			
			if (value === null)
			{
				transformTint = new ColorTransform();
			}
			else 
			{
				var alpha:Number = 1.0;
				var mix:Number = 0.0;
				var amix:Number = 1.0;
				var tint:uint = value;
				if (tint > 0xffffff)
				{
					var aa:int = (tint >> 24) & 0xff;
					mix = aa / 128.0;
					if (mix > 1) { amix = 1; mix = (mix - 1) * 128 / 127; }
					else amix = 1 - mix;
				}
				transformTint = new ColorTransform(
					amix, amix, amix, alpha,
					mix * ((tint >> 16) & 0xff),
					mix * ((tint >> 8) & 0xff),
					mix * (tint & 0xff)
				);
			}
			
			var end:ColorTransform;
			if (reverse) { start = transformTint; end = disp.transform.colorTransform; }
			else { start = disp.transform.colorTransform; end = transformTint; }
			
			delta = new ColorTransform(
				end.redMultiplier - start.redMultiplier,
				end.greenMultiplier - start.greenMultiplier,
				end.blueMultiplier - start.blueMultiplier,
				end.alphaMultiplier - start.alphaMultiplier,
				end.redOffset - start.redOffset,
				end.greenOffset - start.greenOffset,
				end.blueOffset - start.blueOffset
			);
			
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
			t.alphaMultiplier = start.alphaMultiplier + delta.alphaMultiplier * ke;
			t.redOffset = start.redOffset + delta.redOffset * ke;
			t.greenOffset = start.greenOffset + delta.greenOffset * ke;
			t.blueOffset = start.blueOffset + delta.blueOffset * ke;
			
			disp.transform.colorTransform = t;
		}
		
		override public function dispose():void
		{
			start = delta = null;
		}
	}

}