package aze.motion.easing 
{
	import aze.motion.easing.IEazeEasing;
	
	/**
	 * ...
	 * @author Philippe / http://philippe.elsass.me
	 * @author Robert Penner / http://www.robertpenner.com/easing_terms_of_use.html
	 */
	final public class Quart
	{
		static public function get easeIn():IEazeEasing { return new QuartEaseIn(); }
		static public function get easeOut():IEazeEasing { return new QuartEaseOut(); }
		static public function get easeInOut():IEazeEasing { return new QuartEaseInOut(); }
	}

}

import aze.motion.easing.IEazeEasing;

final class QuartEaseIn implements IEazeEasing
{
	public function calculate(k:Number):Number 
	{
		return k * k * k * k;
	}
}

final class QuartEaseOut implements IEazeEasing
{
	public function calculate(k:Number):Number 
	{
		return -(--k * k * k * k - 1);
	}
}

final class QuartEaseInOut implements IEazeEasing
{
	public function calculate(k:Number):Number 
	{
		if ((k *= 2) < 1) return 0.5 * k * k * k * k;
		return -0.5 * ((k -= 2) * k * k * k - 2);
	}
}
