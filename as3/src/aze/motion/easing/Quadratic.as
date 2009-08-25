package aze.motion.easing 
{
	import aze.motion.easing.IEazeEasing;
	
	/**
	 * ...
	 * @author Philippe / http://philippe.elsass.me
	 * @author Robert Penner / http://www.robertpenner.com/easing_terms_of_use.html
	 */
	final public class Quadratic
	{
		static public function get easeIn():IEazeEasing { return new QuadraticEaseIn(); }
		static public function get easeOut():IEazeEasing { return new QuadraticEaseOut(); }
		static public function get easeInOut():IEazeEasing { return new QuadraticEaseInOut(); }
	}

}

import aze.motion.easing.IEazeEasing;

final class QuadraticEaseIn implements IEazeEasing
{
	public function calculate(k:Number):Number 
	{
		return k * k;
	}
}

final class QuadraticEaseOut implements IEazeEasing
{
	public function calculate(k:Number):Number 
	{
		return -k * (k - 2);
	}
}

final class QuadraticEaseInOut implements IEazeEasing
{
	public function calculate(k:Number):Number 
	{
		if ((k *= 2) < 1) return 0.5 * k * k;
		return -0.5 * (--k * (k - 2) - 1);
	}
}
