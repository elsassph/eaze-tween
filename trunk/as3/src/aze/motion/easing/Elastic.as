package aze.motion.easing 
{
	import aze.motion.easing.IEazeEasing;
	
	/**
	 * ...
	 * @author Philippe / http://philippe.elsass.me
	 * @author Robert Penner / http://www.robertpenner.com/easing_terms_of_use.html
	 */
	final public class Elastic
	{
		static public function get easeIn():IEazeEasing { return new ElasticEaseIn(0.1, 0.4); }
		static public function get easeOut():IEazeEasing { return new ElasticEaseOut(0.1, 0.4); }
		static public function get easeInOut():IEazeEasing { return new ElasticEaseInOut(0.1, 0.4); }
		
		static public function easeInWith(a:Number, p:Number):IEazeEasing
		{
			return new ElasticEaseIn(a, p);
		}
		static public function easeOutWith(a:Number, p:Number):IEazeEasing
		{
			return new ElasticEaseOut(a, p);
		}
		static public function easeInOutWith(a:Number, p:Number):IEazeEasing
		{
			return new ElasticEaseInOut(a, p);
		}
	}

}

import aze.motion.easing.IEazeEasing;

final class ElasticEaseIn implements IEazeEasing
{
	public var a:Number;
	public var p:Number;
	
	function ElasticEaseIn(a:Number, p:Number) 
	{
		this.a = a;
		this.p = p;
	}
	
	public function calculate(k:Number):Number 
	{
		if (k == 0) return 0; if (k == 1) return 1; if (!p) p = 0.3;
		var s:Number;
		if (!a || a < 1) { a = 1; s = p / 4; }
		else s = p / (2 * Math.PI) * Math.asin (1 / a);
		return -(a * Math.pow(2, 10 * (k -= 1)) * Math.sin( (k - s) * (2 * Math.PI) / p ));
	}
}

final class ElasticEaseOut implements IEazeEasing
{
	public var a:Number;
	public var p:Number;
	
	function ElasticEaseOut(a:Number, p:Number) 
	{
		this.a = a;
		this.p = p;
	}
	
	public function calculate(k:Number):Number 
	{
		if (k == 0) return 0; if (k == 1) return 1; if (!p) p = 0.3;
		var s:Number;
		if (!a || a < 1) { a = 1; s = p / 4; }
		else s = p / (2 * Math.PI) * Math.asin (1 / a);
		return (a * Math.pow(2, -10 * k) * Math.sin((k - s) * (2 * Math.PI) / p ) + 1);
	}
}

final class ElasticEaseInOut implements IEazeEasing
{
	public var a:Number;
	public var p:Number;
	
	function ElasticEaseInOut(a:Number, p:Number) 
	{
		this.a = a;
		this.p = p;
	}
	
	public function calculate(k:Number):Number 
	{
		if (k == 0) return 0; if (k == 1) return 1; if (!p) p = 0.3;
		var s:Number;
		if (!a || a < 1) { a = 1; s = p / 4; }
		else s = p / (2 * Math.PI) * Math.asin (1 / a);
		if (k < 1) return -0.5 * (a * Math.pow(2, 10 * (k -= 1)) * Math.sin( (k - s) * (2 * Math.PI) / p ));
		return a * Math.pow(2, -10 * (k -= 1)) * Math.sin( (k - s) * (2 * Math.PI) / p ) * .5 + 1;
	}
}
