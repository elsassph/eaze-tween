package aze.motion.specials 
{
	import aze.motion.easing.IEazeEasing;
	import aze.motion.Eaze;
	import aze.motion.specials.EazeSpecial;
	import flash.display.FrameLabel;
	import flash.display.MovieClip;
	
	/**
	 * Frame tweening as a special property
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
		private var frameStart:*;
		private var frameEnd:*;
		
		public function PropertyFrame(target:Object, value:*, next:EazeSpecial)
		{
			super(target, value, next);
		
			var mc:MovieClip = MovieClip(target);
			
			var parts:Array;
			if (value is String) 
			{
				// smart frame label handling
				var label:String = value;
				if (label.indexOf("+") > 0) 
				{
					parts = label.split("+");
					frameStart = parts[0];
					frameEnd = label;
				}
				else if (label.indexOf(">") > 0) 
				{
					parts = label.split(">");
					frameStart = parts[0];
					frameEnd = parts[1];
				}
				else frameEnd = label;
			}
			else 
			{
				// numeric frame index
				frameEnd = Math.max(1, Math.min(mc.totalFrames, int(value)));
			}
		}
		
		override public function init(reverse:Boolean):void 
		{
			var mc:MovieClip = MovieClip(target);
			
			// convert labels to num
			if (frameStart is String) frameStart = findLabel(mc, frameStart);
			else frameStart = mc.currentFrame;
			if (frameEnd is String) frameEnd = findLabel(mc, frameEnd);
			
			if (reverse) { start = frameEnd; delta = frameStart - start; }
			else { start = frameStart; delta = frameEnd - start; }
			
			mc.gotoAndStop(start);
		}
		
		private function findLabel(mc:MovieClip, name:String):int
		{
			for each(var label:FrameLabel in mc.currentLabels)
				if (label.name == name) return label.frame;
			return 1;
		}
		
		override public function update(ease:IEazeEasing, k:Number):void
		{
			var mc:MovieClip = MovieClip(target);
			
			mc.gotoAndStop(Math.round(start + delta * ease.calculate(k)));
		}
	}

}