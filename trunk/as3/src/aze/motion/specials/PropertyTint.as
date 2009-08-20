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
			
			var tint:ColorTransform;
			
			if (value === null) tint = new ColorTransform();
			else 
			{
				var color:uint = value;
				var mix:Number = (color > 0xffffff) ? mix = ((color >> 24) & 0xff) / 255.0 : 1.0;
				
				tint = new ColorTransform();
				tint.redMultiplier = 1 - mix;
				tint.greenMultiplier = 1 - mix;
				tint.blueMultiplier = 1 - mix;
				tint.alphaMultiplier = disp.transform.colorTransform.alphaMultiplier;
				tint.redOffset = mix * ((color >> 16) & 0xff);
				tint.greenOffset = mix * ((color >> 8) & 0xff);
				tint.blueOffset = mix * (color & 0xff);
			}
			
			var end:ColorTransform;
			if (reverse) { start = tint; end = disp.transform.colorTransform; }
			else { start = disp.transform.colorTransform; end = tint; }
			
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