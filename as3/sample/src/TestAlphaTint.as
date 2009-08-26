package  
{
	import aze.motion.Eaze;
	import flash.display.Sprite;
	import flash.filters.BlurFilter;
	import flash.utils.setTimeout;
	
	/**
	 * ...
	 * @author Philippe / http://philippe.elsass.me
	 */
	public class TestAlphaTint extends Sprite
	{
		private var sp:Sprite;
		
		public function TestAlphaTint() 
		{
			sp = new Sprite();
			sp.graphics.beginFill(0xffcc00);
			sp.graphics.drawRect(0, 0, 100, 100);
			sp.graphics.endFill();
			addChild(sp);
			
			Eaze.to(sp, 1, { alpha:1, tint:0xffffff } )
				.delay(1)
				.filter(BlurFilter, { blurX:5, blurY:5 } );
				//.chain(sp, 1, { alpha:1, tint:null } );
			
			setTimeout(modif, 500);
			
			Eaze.to(sp, 1, { alpha:0.5, tint:0x00ccff }, false)
				.delay(2)
				.filter(BlurFilter, { blurX:0, blurY:0 }, true);
			//setTimeout(back, 2000);
		}
		
		private function modif():void
		{
			sp.alpha = 0.2;
		}
		
		private function back():void
		{
			Eaze.to(sp, 1, { alpha:1 } );
		}
		
		private function update():void
		{
			trace(sp.alpha, sp.transform.colorTransform.alphaMultiplier);
		}
		
	}

}