package aze.motion.specials 
{
	/**
	 * ...
	 * @author Philippe / http://philippe.elsass.me
	 */
	public class EazeSpecial
	{
		protected var target:Object;
		public var next:EazeSpecial;
		
		/**
		 * Configure special tween
		 * @param	target	Target object
		 * @param	value	Special property parameter(s)
		 * @param	reverse	Animate "from" value instead of "to" value
		 * @param	next	Reference to another special tween
		 */
		public function EazeSpecial(target:Object, value:*, next:EazeSpecial)
		{
			this.target = target;
			this.next = next;
		}
		
		/**
		 * Prepare tween first use (ie. read "start" value);
		 */
		public function init(reverse:Boolean):void
		{
			
		}
		
		public function update(ke:Number, isComplete:Boolean):void
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