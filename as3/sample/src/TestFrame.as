package  
{
	import assets.Anim1;
	import aze.motion.Eaze;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	/**
	 * Frame tweening test
	 * @author Philippe / http://philippe.elsass.me
	 */
	public class TestFrame extends Sprite
	{
		
		public function TestFrame() 
		{
			stage.frameRate = 30;
			
			for (var i:int = 0; i < stage.stageWidth / 100; i++) 
			{
				for (var j:int = 0; j < stage.stageHeight / 100; j++) 
				{
					createItem(i * 100, j * 100);
				}
			}
		}
		
		private function createItem(sx:int, sy:int):void
		{
			var sp:Sprite = new Anim1();
			sp.x = sx + 10;
			sp.y = sy + 10;
			sp.scaleX = sp.scaleY = 0.6;
			addChild(sp);
			
			sp.addEventListener(MouseEvent.ROLL_OVER, over);
			sp.addEventListener(MouseEvent.ROLL_OUT, out);
		}
		
		private function out(e:MouseEvent):void 
		{
			// play to end
			Eaze.play(e.target); 
			
			// from frame "squeeze" to frame "done"
			//Eaze.play(e.target, "squeeze>done");
		}
		
		private function over(e:MouseEvent):void 
		{
			if (e.target.currentFrame == 1)
				// regular tween
				Eaze.play(e.target, "firstGrow");
			else 
				// from frame "start" to frame "start+end"
				Eaze.play(e.target, "grow+end");
		}
		
	}

}