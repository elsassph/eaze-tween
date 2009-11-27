package  
{
	import aze.motion.eaze;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.BlurFilter;
	
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
			
			eaze(this).delay(0) // will happen on next frame
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
			else return;
			
			// chain 3 fade-ins
			var cpt:int = 0;
			var sp1:Sprite = createItem(cpt * 100, 10);
			sp1.name = String(++cpt);
			var sp2:Sprite = createItem(cpt * 100, 10);
			sp2.name = String(++cpt);
			var sp3:Sprite = createItem(cpt * 100, 10);
			sp3.name = String(++cpt);
			
			eaze(sp1).onStart(startHandler)
				.from(1, { alpha:0 } ).updateNow()
				.onComplete(tweenComplete, sp1)
				.chain(sp2).from(1, { alpha:0 } ).updateNow()
				.onComplete(tweenComplete, sp2)
				.chain(sp3).from(1, { alpha:0 } ).updateNow()
				.onComplete(tweenComplete, sp3)
				.chain(this).apply().onComplete(endOfChain)
				.to("slow").filter(BlurFilter, { blurX:10, blurY:10, quality:2 } );
			
			var sp4:Sprite = createItem(0, 100);
			sp4.name = String(++cpt);
			eaze(sp4).delay(1)
				.from(1)
					.filter(BlurFilter, { blurX:20, blurY:20, quality:2 }, true)
					.updateNow()
				.to(1, {x: 100, y: 200})
				.onComplete(tweenComplete, sp4)
				.to(1, {x: 200, y: 300})
				.onComplete(tweenComplete, sp4)
				.to(1, {x: 300, y: 400})
				.onComplete(tweenComplete, sp4);
			
			trace("tweens defined");
		}
		
		private function startHandler():void
		{
			trace("started");
		}
		
		private function endOfChain():void
		{
			trace("end of chain");
		}
		
		private function tweenComplete(sp:Sprite):void
		{
			trace("Tween complete", sp.name, sp.x, sp.y);
		}
		
		private function createItem(sx:int, sy:int):Sprite
		{
			var sp:Sprite = new Sprite();
			sp.x = sx + 10;
			sp.y = sy + 10;
			sp.graphics.beginFill(Math.random() * 0xffffff);
			sp.graphics.drawRect(0, 0, 80, 80);
			addChild(sp);
			return sp;
		}
		
		
	}

}