package  
{
	import aze.motion.Eaze;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.getTimer;
	
	/**
	 * Tweens chaing test
	 * @author Philippe / http://philippe.elsass.me
	 */
	public class TestChain extends Sprite
	{
		
		public function TestChain() 
		{
			addEventListener(Event.ENTER_FRAME, tick);
			
			hello("before");
			
			Eaze.delay(0) // will happen on next frame
				.onComplete(hello, "after");
		}
		
		private function tick(e:Event):void 
		{
			trace("A frame has ticked");
		}
		
		private function hello(when:String):void
		{
			trace("Hello", when);
			if (when == "after") removeEventListener(Event.ENTER_FRAME, tick);
			
			// chain 3 fade-ins
			var cpt:int = 0;
			var sp1:Sprite = createItem(cpt * 100, 10);
			sp1.name = String(++cpt);
			var sp2:Sprite = createItem(cpt * 100, 10);
			sp2.name = String(++cpt);
			var sp3:Sprite = createItem(cpt * 100, 10);
			sp3.name = String(++cpt);
			
			Eaze.to(sp1, 1, { alpha:1 } )
				.onComplete(tweenComplete, sp1)
				.chainTo(sp2, 1, { alpha:1 } )
				.onComplete(tweenComplete, sp2)
				.chainTo(sp3, 1, { alpha:1 } )
				.onComplete(tweenComplete, sp3);
		}
		
		private function tweenComplete(sp:Sprite):void
		{
			trace("Tween complete", sp.name);
		}
		
		private function createItem(sx:int, sy:int):Sprite
		{
			var sp:Sprite = new Sprite();
			sp.x = sx + 10;
			sp.y = sy + 10;
			sp.graphics.beginFill(Math.random() * 0xffffff);
			sp.graphics.drawRect(0, 0, 80, 80);
			sp.alpha = 0;
			addChild(sp);
			return sp;
		}
		
		
	}

}