package tubular
{
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import tube.TubeControl;
	import tube.TubeHandler;

	public class TubularComp extends EventDispatcher
	{

		private static var movieTimer:MovieClip=new MovieClip();
		public static var composite:BitmapData=TubeHandler.basicBitmapData();

		public function TubularComp()
		{
			movieTimer.addEventListener(Event.ENTER_FRAME, timerFunction);
		}

		public function timerFunction(event:Event):void
		{
			composite.fillRect(composite.rect, 0);
			for each(var tubeC:TubeControl in TubeHandler.tubes) {
				composite.draw(tubeC.tubeHandler.processedImage, null, tubeC.tubeHandler.colorTransform);
			}
			dispatchEvent(event);
		}
	}
}