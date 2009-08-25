package aze.motion.easing 
{
	import aze.motion.easing.IEazeEasing;
	
	/**
	 * ...
	 * @author Philippe / http://philippe.elsass.me
	 * @author Robert Penner / http://www.robertpenner.com/easing_terms_of_use.html
	 */
	final public class Cubic
	{
		static public function get easeIn():IEazeEasing { return new CubicEaseIn(); }
		static public function get easeOut():IEazeEasing { return new CubicEaseOut(); }
		static public function get easeInOut():IEazeEasing { return new CubicEaseInOut(); }
	}

}

import aze.motion.easing.IEazeEasing;

final class CubicEaseIn implements IEazeEasing
{
	public function calculate(k:Number):Number 
	{
		return k * k * k;
	}
}

final class CubicEaseOut implements IEazeEasing
{
	public function calculate(k:Number):Number 
	{
		return --k * k * k + 1;
	}
}

final class CubicEaseInOut implements IEazeEasing
{
	public function calculate(k:Number):Number 
	{
		if ((k *= 2) < 1) return 0.5 * k * k * k;
		return 0.5 * ((k -= 2) * k * k + 2);
	}
}
