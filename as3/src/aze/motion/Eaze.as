package aze.motion
{
	import aze.motion.easing.IEazeEasing;
	import aze.motion.easing.Linear;
	import aze.motion.easing.Quadratic;
	import aze.motion.easing.Quart;
	import aze.motion.specials.EazeSpecial;
	import aze.motion.specials.PropertyFrame;
	import aze.motion.specials.PropertyTint;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getTimer;
	import flash.utils.setInterval;
	
	/**
	 * ...
	 * @author Philippe - http://philippe.elsass.me
	 */
	final public class Eaze
	{
		//--- STATIC ----------------------------------------------------------
		
		/** Defines default easing method to use when no ease is specified */
		static public var defaultEase:IEazeEasing = Quadratic.easeOut;
		static public var defaultDuration:Object = { slow:1, normal:0.4, fast:0.2 };
		
		/** Registered plugins */ 
		static public const specialProperties:Dictionary = new Dictionary(); // see end of this file
		
		static private const running:Dictionary = new Dictionary();
		static private const ticker:Shape = createTicker();
		static private var head:Eaze;
		static private var tweenCount:int = 0;
		
		/**
		 * Create a blank tween for delaying
		 * @param	duration	Seconds or "slow/normal/fast/auto"
		 * @param	target		Optional target object (defaults to first chained tween's target)
		 * @param	overwrite	"keep" or "overwrite" (default) existing tweens of target
		 * @return Tween object
		 */
		static public function delay(duration:*, target:Object = null, overwrite:String = "overwrite"):Eaze
		{
			if (!target) { target = Eaze; overwrite = "keep"; }
			return new Eaze(target, Math.max(0.0001, duration), null, overwrite).start();
		}
		
		/**
		 * Immediately change target properties
		 * @param	target
		 * @param	newState
		 * @param	overwrite	"keep" or "overwrite" (default) existing tweens of target
		 */
		static public function apply(target:Object, newState:Object = null, overwrite:String = "overwrite"):void
		{
			new Eaze(target, 0, newState, overwrite).start();
		}
		
		/**
		 * Animate target from current state to provided new state
		 * @param	target
		 * @param	duration	Seconds or "slow/normal/fast/auto"
		 * @param	newState
		 * @param	overwrite	"keep" or "overwrite" (default) existing tweens of target
		 * @return Tween object
		 */
		static public function to(target:Object, duration:*, newState:Object = null, overwrite:String = "overwrite"):Eaze
		{
			return new Eaze(target, duration, newState, overwrite).start();
		}
		
		/**
		 * Animate target from provided new state to current state
		 * @param	target
		 * @param	duration	Seconds or "slow/normal/fast/auto"
		 * @param	newState
		 * @param	overwrite	"keep" or "overwrite" (default) existing tweens of target
		 * @return Tween object
		 */
		static public function from(target:Object, duration:*, newState:Object = null, overwrite:String = "overwrite"):Eaze
		{
			return new Eaze(target, duration, newState, overwrite, "backward").start();
		}
		
		/**
		 * Play target MovieClip timeline
		 * @param	target
		 * @param	frame		Frame number or label (default: totalFrames)
		 * @param	overwrite	"keep" or "overwrite" (default) existing tweens of target
		 * @return	Tween object
		 */
		static public function play(target:Object, frame:* = 0, overwrite:String = "overwrite"):Eaze
		{
			return new Eaze(target, "auto", { frame:frame }, overwrite).ease(Linear.easeNone).start();
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
			if (!target) return;
			
			var tween:Eaze = running[target];
			var rprev:Eaze;
			while (tween)
			{
				tween.isDead = true;
				tween.dispose();
				if (tween.rnext) { rprev = tween; tween = tween.rnext; rprev.rnext = null; }
				else tween = null;
			}
			delete running[target];
		}
		
		/// Setup enterframe event for update
		static private function createTicker():Shape
		{
			var sp:Shape = new Shape();
			sp.addEventListener(Event.ENTER_FRAME, tick);
			//setInterval(checkLeaks, 5000);
			return sp;
		}
		
		static private function checkLeaks():void
		{
			var targets:int = 0;
			var t:Eaze;
			for (var target:Object in running)
			{
				trace(target);
				targets++;
			}
			
			var tweens:int = 0.
			t = head;
			while (t) { tweens++; t = t.next; }
			trace("== check targets=", targets, "tweens=", tweens);
		}
		
		/// Add tween to chain
		static private function register(tween:Eaze):void
		{
			if (head) head.prev = tween;
			tween.next = head;
			head = tween;
		}
		
		/// Enterframe handler for update
		static private function tick(e:Event):void 
		{
			if (head) updateTweens(getTimer());
		}
		
		/// Main update loop
		static private function updateTweens(time:int):void 
		{
			var complete:Array = [];
			var ct:int = 0;
			var t:Eaze = head;
			var cpt:int = 0;
			
			while (t)
			{
				cpt++;
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
						if (t.autoVisible) target.visible = target.alpha > 0.001;
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
					var cd:CompleteData = new CompleteData(t._onComplete, t._onCompleteArgs, t._chain);
					t._chain = null;
					complete.unshift(cd);
					ct++;
					
					// finalize
					t.isDead = true;
					t.detach();
					t.dispose();
					
					// remove from chain
					var dead:Eaze = t;
					var prev:Eaze = t.prev;
					t = dead.next; // next tween
					
					if (prev) { prev.next = t; if (t) t.prev = prev; }
					else { head = t; if (t) t.prev = null; }
					dead.prev = dead.next = null;
				}
				else t = t.next; // next tween
			}
			
			// honor completed tweens notifications & chaining
			for (var i:int = 0; i < ct; i++) complete[i].execute();
			
			tweenCount = cpt;
		}
		
		//--- INSTANCE --------------------------------------------------------
		
		private var prev:Eaze;
		private var next:Eaze;
		private var rnext:Eaze;
		private var isDead:Boolean;
		
		private var target:Object;
		private var reversed:Boolean;
		private var killTweens:Boolean;
		private var _started:Boolean;
		private var duration:*;
		private var _duration:Number;
		private var _ease:IEazeEasing;
		private var startTime:Number;
		private var endTime:Number;
		private var properties:EazeProperty;
		private var specials:EazeSpecial;
		private var autoVisible:Boolean;
		private var slowTween:Boolean;
		private var _chain:Array;
		
		private var _onStart:Function;
		private var _onStartArgs:Array;
		private var _onUpdate:Function;
		private var _onUpdateArgs:Array;
		private var _onComplete:Function;
		private var _onCompleteArgs:Array;
		
		/**
		 * Creates a tween instance
		 * @param	target
		 * @param	duration	Seconds or "slow/normal/fast/auto"
		 * @param	newState
		 * @param	overwrite	"keep" or "overwrite" (default) existing tweens of target
		 * @param	direction	Animate "forward" or "backward"
		 */
		public function Eaze(target:Object, duration:*, newState:Object = null, overwrite:String = "overwrite", direction:String = "forward")
		{
			if (!target) throw new ArgumentError("Eaze: target can not be null");
			
			this.target = target;
			reversed = (direction == "backward");
			killTweens = (overwrite != "keep");
			this.duration = duration;
			_ease = defaultEase;
			
			// properties
			if (newState)
			for (var name:String in newState)
			{
				var value:* = newState[name];
				if (!(name in target))
				{
					if (name == "autoAlpha") { name = "alpha"; autoVisible = true; }
					else if (name in specialProperties)
					{
						specials = new specialProperties[name](target, value, specials);
						continue;
					}
				}
				properties = new EazeProperty(name, value, properties);
			}
			
			slowTween = autoVisible || specials != null;
		}
		
		/**
		 * Register this tween and run it
		 */
		public function start():Eaze
		{
			if (!target) throw new ArgumentError("Eaze: target can not be null");
			
			// configure properties
			var p:EazeProperty = properties;
			while (p) { p.init(target, reversed); p = p.next; }
			
			var s:EazeSpecial = specials;
			while (s) { s.init(reversed); s = s.next; }
			
			// add to main tween chain
			startTime = getTimer();
			_duration = (isNaN(duration) ? smartDuration(String(duration)) : Number(duration)) * 1000;
			endTime = startTime + _duration;
			
			if (_onStart != null)
			{
				_onStart.apply(null, _onStartArgs);
				_onStart = null;
				_onStartArgs = null;
			}
			
			// set values
			if (reversed || _duration == 0) update(startTime);
			
			_started = true;
			attach(killTweens);
			register(this);
			
			return this;
		}
		
		/// Resolve non numeric durations
		private function smartDuration(duration:String):Number
		{
			if (duration in defaultDuration) return defaultDuration[duration];
			else if (duration == "auto")
			{
				// look for a special property willing to provide an optimal duration
				var s:EazeSpecial = specials;
				while (s)
				{
					if ("getPreferredDuration" in s) return s["getPreferredDuration"]();
					s = s.next;
				}
			}
			return defaultDuration.normal;
		}
		
		/**
		 * Set easing method
		 * @param	easing
		 * @return	Tween reference
		 */
		public function ease(easing:IEazeEasing):Eaze
		{
			_ease = easing || defaultEase;
			return this;
		}
		
		/**
		 * Add a filter animation
		 * @param	classRef	Filter class (ex: BlurFilter or "blurFilter")
		 * @param	parameters
		 * @return	Tween reference
		 */
		public function filter(classRef:*, parameters:Object, removeWhenDone:Boolean = false):Eaze
		{
			if (classRef in specialProperties && target)
			{
				if (!parameters) parameters = { };
				if (removeWhenDone) parameters.remove = true;
				specials = new specialProperties[classRef](target, parameters, specials);
				if (_started) specials.init(reversed);
				slowTween = true;
			}
			return this;
		}
		
		/**
		 * Set callback on tween startup
		 * @param	handler
		 * @param	...args
		 * @return	Tween reference
		 */
		public function onStart(handler:Function, ...args):Eaze
		{
			_onStart = handler;
			_onStartArgs = args;
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
			else 
			{
				detach();
				dispose();
			}
			isDead = true;
		}
		
		/// Update this tween alone
		private function update(time:Number):void
		{
			// make this tween the only tween to update 
			var prev:Eaze = head;
			head = this;
			updateTweens(time);
			head = prev;
		}
		
		/// associate target/tween in running Dictionnary
		private function attach(exclusive:Boolean):void
		{
			if (exclusive) killTweensOf(target);
			
			var tween:Eaze = running[target];
			if (tween) rnext = tween;
			running[target] = this;
		}
		
		/// delete target/tween association in running Dictionnary
		private function detach():void
		{
			if (target && _started)
			{
				var targetTweens:Eaze = running[target];
				if (targetTweens == this) 
				{
					if (rnext) running[target] = rnext;
					else delete running[target];
				}
				else if (targetTweens)
				{
					var prev:Eaze = targetTweens;
					targetTweens = targetTweens.rnext;
					while (targetTweens) 
					{
						if (targetTweens == this)
						{
							prev.rnext = rnext;
							break;
						}
						prev = targetTweens;
						targetTweens = targetTweens.rnext;
					}
				}
				rnext = null;
			}
		}
		
		/// Cleanup all references except main chaining
		private function dispose():void
		{
			if (_started) target = null;
			if (properties) { properties.dispose(); properties = null; }
			_ease = null;
			_onStart = null;
			_onStartArgs = null;
			_onComplete = null;
			_onCompleteArgs = null;
			if (_chain)
			{
				for each(var tween:Eaze in _chain) tween.dispose();
				_chain = null;
			}
			if (slowTween)
			{
				if (specials) { specials.dispose(); specials = null; }
				autoVisible = false; 
				_onUpdate = null;
				_onUpdateArgs = null;
			}
		}
		
		/**
		 * Immediately change target properties
		 * @param	target
		 * @param	parameters
		 * @param	overwrite	"keep" or "overwrite" (default) existing tweens of target
		 */
		public function chainApply(target:Object, parameters:Object = null, overwrite:String = "overwrite"):Eaze
		{
			return chain(new Eaze(target, 0, parameters, overwrite));
		}
		
		/**
		 * Animate target from current state to provided new state
		 * @param	target
		 * @param	duration	Seconds or "slow/normal/fast/auto"
		 * @param	parameters
		 * @param	overwrite	"keep" or "overwrite" (default) existing tweens of target
		 * @return Tween object
		 */
		public function chainTo(target:Object, duration:*, parameters:Object = null, overwrite:String = "overwrite"):Eaze
		{
			return chain(new Eaze(target, duration, parameters, overwrite));
		}
		
		/**
		 * Animate target from provided new state to current state
		 * @param	target
		 * @param	duration	Seconds or "slow/normal/fast/auto"
		 * @param	parameters
		 * @param	overwrite	"keep" or "overwrite" (default) existing tweens of target
		 * @return Tween object
		 */
		public function chainFrom(target:Object, duration:*, parameters:Object = null, overwrite:String = "overwrite"):Eaze
		{
			return chain(new Eaze(target, duration, parameters, overwrite, "backward"));
		}
		
		/**
		 * Play target MovieClip timeline
		 * @param	target
		 * @param	frame		Frame number or label (default: totalFrames)
		 * @param	overwrite	"keep" or "overwrite" (default) existing tweens of target
		 * @return	Tween object
		 */
		public function chainPlay(target:Object, frame:* = 0, overwrite:String = "overwrite"):Eaze
		{
			return chain(new Eaze(target, "auto", { frame:frame }, overwrite)).ease(Linear.easeNone);
		}
		
		// Add tween to list of tweens started at the end of this one
		private function chain(tween:Eaze):Eaze
		{
			if (!tween) return null;
			
			if (target == Eaze) // no target, set same target as tween
			{
				detach();
				target = tween.target;
				killTweens = tween.killTweens;
				attach(killTweens);
			}
			
			if (!_chain) _chain = [];
			_chain.push(tween);
			return tween;
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
	public var end:Number;
	public var delta:Number;
	public var next:EazeProperty;
	
	function EazeProperty(name:String, end:Number, next:EazeProperty)
	{
		this.name = name;
		this.end = end;
		this.next = next;
	}
	
	public function init(target:Object, reversed:Boolean):void
	{
		if (reversed)
		{
			start = end;
			end = target[name];
			target[name] = start;
		}
		else start = target[name];
		
		this.delta = end - start;
	}
	
	public function dispose():void
	{
		if (next) next.dispose();
		next = null;
	}
}

import aze.motion.Eaze;

/**
 * Information to honor tween completion: complete event, chaining.
 */
final class CompleteData
{
	private var callback:Function;
	private var args:Array;
	private var chain:Array;
	
	function CompleteData(callback:Function, args:Array, chain:Array)
	{
		this.callback = callback;
		this.args = args;
		this.chain = chain;
	}
	
	public function execute():void
	{
		if (callback != null)
		{
			callback.apply(null, args);
			callback = null;
		}
		args = null;
		if (chain)
		{
			var len:int = chain.length;
			for (var i:int = 0; i < len; i++) chain[i].start();
			chain = null;
		}
	}
}

// you can comment out the following lines to disable some plugins
import aze.motion.specials.PropertyTint; PropertyTint.register();
import aze.motion.specials.PropertyFrame; PropertyFrame.register();
import aze.motion.specials.PropertyFilter; PropertyFilter.register();
import aze.motion.specials.PropertyVolume; PropertyVolume.register();
