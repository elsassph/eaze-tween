package aze.motion.easing 
{
	import aze.motion.easing.IEazeEasing;
	
	/**
	 * ...
	 * @author Philippe / http://philippe.elsass.me
	 * @author Robert Penner / http://www.robertpenner.com/easing_terms_of_use.html
	 */
	final public class Linear
	{
		static public function get easeNone():IEazeEasing { return new LinearEaseNone(); }
	}

}

import aze.motion.easing.IEazeEasing;

final class LinearEaseNone implements IEazeEasing
{
	public function calculate(k:Number):Number 
	{
		return k;
	}
}