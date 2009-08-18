package aze.motion.specials 
{
	import aze.motion.easing.IEazeEasing;
	
	/**
	 * ...
	 * @author Philippe / http://philippe.elsass.me
	 */
	public class EazeSpecial
	{
		protected var target:Object;
		public var next:EazeSpecial;
		
		public function EazeSpecial(target:Object, value:*, reverse:Boolean, next:EazeSpecial)
		{
			this.target = target;
			this.next = next;
		}
		
		public function update(ease:IEazeEasing, k:Number):void
		{
			
		}
		
		public function dispose():void
		{
			target = null;
			if (next) next.dispose();
			next = null;
		}
	}

}