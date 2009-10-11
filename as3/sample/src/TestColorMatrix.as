package  
{
	import assets.ColorMatrixSample;
	import aze.motion.Eaze;
	import aze.motion.specials.PropertyColorMatrix;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.ColorMatrixFilter;
	import flash.utils.setInterval;
	
	/**
	 * ...
	 * @author Philippe / http://philippe.elsass.me
	 */
	public class TestColorMatrix extends Sprite
	{	
		private var view:ColorMatrixSample;
		private var sampler:SamplerTest;
		
		public function TestColorMatrix() 
		{
			PropertyColorMatrix.register();
			
			view = new ColorMatrixSample();
			addChild(view);
			
			view.sBrightness.addEventListener(Event.CHANGE, animate);
			view.sContrast.addEventListener(Event.CHANGE, animate);
			view.sSaturation.addEventListener(Event.CHANGE, animate);
			view.sHue.addEventListener(Event.CHANGE, animate);
		}
		
		private function animate(e:Event):void 
		{
			Eaze.to(view.mcPict, 1)
				.filter(ColorMatrixFilter, { 
					brightness:view.sBrightness.value,
					contrast:view.sContrast.value,
					saturation:view.sSaturation.value,
					hue:view.sHue.value
				});
		}
		
	}

}