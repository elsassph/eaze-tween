package aze.motion
{
	import aze.motion.easing.IEazeEasing;
	import aze.motion.easing.Quadratic;
	import aze.motion.easing.Quart;
	import aze.motion.specials.EazeSpecial;
	import aze.motion.specials.PropertyTint;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getTimer;
	
	/**
	 * ...
	 * @author Philippe / http://philippe.elsass.me
	 */
	final public class Eaze
	{
		//--- STATIC ----------------------------------------------------------
		
		static public var defaultEase:IEazeEasing = Quadratic.easeOut;
		
		static public const specialProperties:Object = { }; // register properties at the end of this file
		
		static private const running:Dictionary = new Dictionary(true);
		static private const ticker:Shape = createTicker();
		static private var head:Eaze;
		
		/**
		 * Immediately change target properties
		 * @param	target
		 * @param	parameters
		 * @param	overwrite	Remove existing tweens of target
		 */
		static public function apply(target:Object, parameters:Object, overwrite:Boolean = true):void
		{
			new Eaze(target, 0, parameters, overwrite);
		}
		
		/**
		 * Animate target from current state to provided new state
		 * @param	target
		 * @param	duration
		 * @param	parameters
		 * @param	overwrite	Remove existing tweens of target
		 * @return Tween object
		 */
		static public function to(target:Object, duration:Number, parameters:Object, overwrite:Boolean = true):Eaze
		{
			return new Eaze(target, duration, parameters, overwrite);
		}
		
		/**
		 * Animate target from provided new state to current state
		 * @param	target
		 * @param	duration
		 * @param	parameters
		 * @param	overwrite	Remove existing tweens of target
		 * @return Tween object
		 */
		static public function from(target:Object, duration:Number, parameters:Object, overwrite:Boolean = true):Eaze
		{
			return new Eaze(target, duration, parameters, overwrite, true);
		}
		
		/**
		 * Stop immediately all running tweens
		 */
		static public function killAllTweens():void
		{
			for (var target:Object in running)
				killTweensOf(target);
		}
		
		/**
		 * Stop immediately all tweens associated with target
		 * @param	target
		 */
		static public function killTweensOf(target:Object):void
		{
			var tween:Eaze = running[target];
			var prev:Eaze;
			while (tween)
			{
				tween.dispose(false);
				if (tween.rnext) { prev = tween; tween = tween.rnext; prev.rnext = null; }
			}
			delete running[target];
		}
		
		static private function createTicker():Shape
		{
			var sp:Shape = new Shape();
			sp.addEventListener(Event.ENTER_FRAME, tick);
			return sp;
		}
		
		static private function register(tween:Eaze):void
		{
			if (head) head.prev = tween;
			tween.next = head;
			head = tween;
		}
		
		static private function tick(e:Event):void 
		{
			if (head) updateTweens(getTimer());
		}
		
		static private function updateTweens(time:int):void 
		{
			var t:Eaze = head;
			while (t)
			{
				if (time >= t.startTime) 
				{
					var isComplete:Boolean;
					if (t.isDead) isComplete = true;
					else 
					{
						isComplete = time >= t.endTime;
						var k:Number = isComplete ? 1.0 : (time - t.startTime) / t._duration;
						var target:Object = t.target;
						var _ease:IEazeEasing = t._ease;
						
						// update
						var p:EazeProperty = t.properties;
						while (p)
						{
							target[p.name] = p.start + p.delta * _ease.calculate(k);
							p = p.next;
						}
						
						if (t.slowTween)
						{
							if (t.autoVisible) target.visible = target.alpha > 0.0;
							if (t.specials)
							{
								var s:EazeSpecial = t.specials;
								while (s)
								{
									s.update(_ease, k);
									s = s.next;
								}
							}
							
							if (t._onUpdate != null) 
								t._onUpdate.apply(null, t._onUpdateArgs);
						}
					}
					
					if (isComplete) // tween ends
					{
						// finalize
						var tComplete:Function = t._onComplete;
						var tCompleteArgs:Array = t._onCompleteArgs;
						t.isDead = true;
						t.dispose(true);
						
						// remove from chain
						var dead:Eaze = t;
						var prev:Eaze = t.prev;
						t = dead.next;
						if (prev) { prev.next = t; if (t) t.prev = prev; }
						else { head = t; if (t) t.prev = null; }
						dead.prev = dead.next = null;
						
						// call dead tween's complete
						if (tComplete != null) 
						{
							tComplete.apply(null, tCompleteArgs);
							tComplete = null;
							tCompleteArgs = null;
						}
						continue;
					}
				}
				// next
				t = t.next;
			}
		}
		
		//--- INSTANCE --------------------------------------------------------
		
		private var prev:Eaze;
		private var next:Eaze;
		private var rnext:Eaze;
		private var isDead:Boolean;
		
		private var target:Object;
		private var _delay:Number;
		private var _duration:Number;
		private var _ease:IEazeEasing;
		private var startTime:Number;
		private var endTime:Number;
		private var properties:EazeProperty;
		private var specials:EazeSpecial;
		private var autoVisible:Boolean;
		private var slowTween:Boolean;
		
		private var _onUpdate:Function;
		private var _onUpdateArgs:Array;
		private var _onComplete:Function;
		private var _onCompleteArgs:Array;
		
		/**
		 * Creates a tween instance
		 * @param	target
		 * @param	duration
		 * @param	parameters
		 * @param	overwrite	Remove existing tweens of target
		 * @param	reverse		Animate "from" provided parameters instead of "to"
		 */
		public function Eaze(target:Object, duration:Number, parameters:Object, overwrite:Boolean = true, reverse:Boolean = false)
		{
			this.target = target;
			_ease = defaultEase;
			
			if (overwrite) killTweensOf(target);
			
			// properties
			for (var name:String in parameters)
			{
				var value:* = parameters[name];
				if (!(name in target))
				{
					if (name == "autoAlpha") { name = "alpha"; autoVisible = true; }
					else if (name in specialProperties)
					{
						specials = new specialProperties[name](target, value, reverse, specials);
						continue;
					}
				}
				if (reverse) properties = new EazeProperty(name, value, target[name], properties);
				else properties = new EazeProperty(name, target[name], value, properties);
			}
			
			slowTween = !autoVisible || specials != null;
			
			if (!duration) // apply
			{
				update(startTime = endTime = 0);
				if (overwrite) delete running[target];
			}
			else // tween
			{
				isDead = false;
				
				// timing
				_duration = duration < 10 ? duration * 1000 : duration;
				startTime = getTimer();
				endTime = startTime + _duration;
				if (reverse) update(startTime);
				
				// add to target's running tweens chain
				var tween:Eaze = running[target];
				if (!tween) running[target] = this;
				else { this.rnext = tween; running[target] = this; }
				
				// add to main tween chain
				register(this);
			}
		}
		
		/**
		 * Set easing method
		 * @param	easing
		 * @return	Tween reference
		 */
		public function ease(easing:IEazeEasing):Eaze
		{
			_ease = easing;
			return this;
		}
		
		/**
		 * Set tween delay
		 * @param	value
		 * @return	Tween reference
		 */
		public function delay(value:Number):Eaze
		{
			_delay = value < 10 ? value * 1000 : value;
			startTime = getTimer() + _delay;
			endTime = startTime + _duration;
			return this;
		}
		
		/**
		 * Set callback on tween update
		 * @param	handler
		 * @param	...args
		 * @return	Tween reference
		 */
		public function onUpdate(handler:Function, ...args):Eaze
		{
			_onUpdate = handler;
			_onUpdateArgs = args;
			slowTween = _onUpdate != null || !autoVisible || specials != null;
			return this;
		}
		
		/**
		 * Set callback on tween end
		 * @param	handler
		 * @param	...args
		 * @return	Tween reference
		 */
		public function onComplete(handler:Function, ...args):Eaze
		{
			_onComplete = handler;
			_onCompleteArgs = args;
			return this;
		}
		
		/**
		 * Stop tween immediately
		 * @param	setEndValues	Set final tween values to target
		 */
		public function kill(setEndValues:Boolean = false):void
		{
			if (isDead) return;
			
			if (setEndValues) 
			{
				_onUpdate = _onComplete = null;
				update(endTime);
			}
			else dispose(true);
			isDead = true;
		}
		
		private function update(time:Number):void
		{
			// make this tween the only tween to update 
			var prev:Eaze = head;
			head = this;
			updateTweens(time);
			head = prev;
		}
		
		private function dispose(removeRunningReference:Boolean):void
		{
			if (removeRunningReference)
			{
				var targetTweens:Eaze = running[target];
				if (targetTweens == this) running[target] = this.rnext;
				else 
				{
					var prev:Eaze = targetTweens;
					targetTweens = targetTweens.next;
					while (targetTweens) 
					{
						if (targetTweens == this)
						{
							prev.rnext = this.rnext;
							break;
						}
					}
				}
				this.rnext = null;
			}
			
			target = null;
			if (properties)
			{
				properties.dispose();
				properties = null;
			}
			_delay = 0;
			_onComplete = null;
			_onCompleteArgs = null;
			if (slowTween)
			{
				if (specials)
				{
					specials.dispose();
					specials = null;
				}
				autoVisible = false; 
				_onUpdate = null;
				_onUpdateArgs = null;
			}
		}
	}

}

/**
 * Tweened propertie infos (chained list)
 */
final class EazeProperty
{
	public var name:String;
	public var start:Number;
	public var delta:Number;
	public var next:EazeProperty;
	
	function EazeProperty(name:String, start:Number, end:Number, next:EazeProperty)
	{
		this.name = name;
		this.start = start;
		this.delta = end - start;
		this.next = next;
	}
	
	public function dispose():void
	{
		if (next) next.dispose();
		next = null;
	}
}

import aze.motion.specials.PropertyTint; PropertyTint.register();
import aze.motion.specials.PropertyFrame; PropertyFrame.register();
import aze.motion.specials.PropertyFilter; PropertyFilter.register();
