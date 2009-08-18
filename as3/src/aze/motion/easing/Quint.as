package aze.motion.easing 
{
	import aze.motion.easing.IEazeEasing;
	
	/**
	 * ...
	 * @author Philippe / http://philippe.elsass.me
	 * @author Robert Penner / http://www.robertpenner.com/easing_terms_of_use.html
	 */
	final public class Quint
	{
		static public function get easeIn():IEazeEasing { return new QuintEaseIn(); }
		static public function get easeOut():IEazeEasing { return new QuintEaseOut(); }
		static public function get easeInOut():IEazeEasing { return new QuintEaseInOut(); }
	}

}

import aze.motion.easing.IEazeEasing;

final class QuintEaseIn implements IEazeEasing
{
	public function calculate(k:Number):Number 
	{
		return k * k * k * k * k;
	}
}

final class QuintEaseOut implements IEazeEasing
{
	public function calculate(k:Number):Number 
	{
		return --k * k * k * k * k + 1;
	}
}

final class QuintEaseInOut implements IEazeEasing
{
	public function calculate(k:Number):Number 
	{
		if (k < 0.5) return 0.5 * k * k * k * k * k;
		return 0.5 * ((k -= 2) * k * k * k * k + 2);
	}
}
