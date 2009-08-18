package aze.motion.specials 
{
	import aze.motion.easing.IEazeEasing;
	import aze.motion.Eaze;
	import aze.motion.specials.EazeSpecial;
	import flash.display.FrameLabel;
	import flash.display.MovieClip;
	
	/**
	 * ...
	 * @author Philippe / http://philippe.elsass.me
	 */
	public class PropertyFrame extends EazeSpecial
	{
		static public function register():void
		{
			Eaze.specialProperties.frame = PropertyFrame;
		}
		
		private var start:int;
		private var delta:int;
		
		public function PropertyFrame(target:Object, value:*, reverse:Boolean, next:EazeSpecial)
		{
			super(target, value, reverse, next);
		
			var mc:MovieClip = MovieClip(target);
			
			var current:int = mc.currentFrame;
			var frame:int;
			if (value is String) // smart frame label handling
			{
				var label:String = value;
				if (label.indexOf("+") > 0) 
				{
					current = findLabel(mc, label.split("+")[0]);
				}
				else if (label.indexOf(">") > 0) 
				{
					var parts:Array = label.split(">");
					current = findLabel(mc, parts[0]);
					label = parts[1];
				}
				frame = findLabel(mc, label);
			}
			else // numeric
			{
				frame = Math.max(1, Math.min(mc.totalFrames, int(value)));
			}
			
			if (reverse) { start = frame; delta = current - start; }
			else { start = current; delta = current - start; }
			mc.gotoAndStop(start);
		}
		
		private function findLabel(mc:MovieClip, name:String):int
		{
			for each(var label:FrameLabel in mc.currentLabels)
				if (label.name == name) return label.frame;
				
			return mc.totalFrames;
		}
		
		override public function update(ease:IEazeEasing, k:Number):void
		{
			var mc:MovieClip = MovieClip(target);
			
			mc.gotoAndStop(Math.round(start + delta * ease.calculate(k)));
		}
	}

}