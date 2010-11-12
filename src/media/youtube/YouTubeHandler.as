package media.plugins.youtube
{
	import flash.events.Event;
	import flash.media.Video;
	
	import media.Handler;

	public class YouTubeHandler extends Handler
	{
		public var videoPlayer:Video;

		public function YouTubeHandler()
		{
			super();
			videoPlayer=new Video(RECT.width, RECT.height);
			videoPlayer.cacheAsBitmap=true;
			videoPlayer.addEventListener(Event.ENTER_FRAME, attachWorkaround);
			videoPlayer.addEventListener(Event.ENTER_FRAME, updateOutput);
		}

		private function attachWorkaround(e:Event):void
		{
			videoPlayer.width=RECT.width;
			videoPlayer.height=RECT.height;
		}

		private function updateOutput(event:Event):void
		{
			try
			{
				if (!binded)
				{
					bindingHandler.bitmapData=ImageSnapshot.captureBitmapData(videoPlayer);
					bufferLength=ns.bufferLength;
				}
			}
			catch (e:Error)
			{
			}
			if (state != STOPPED)
			{
				cloneOutputBitmap();
				if (invertFilterEnabled)
				{
					invertFilter.applyFilter(processedImage.bitmapData);
				}
				repeaterFilter.applyFilter(processedImage.bitmapData);
			}
			else
			{
				clearOutputBitmap();
			}
		}
	}
}