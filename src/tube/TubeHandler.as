package tube
{
	import filters.Invert;
	import filters.Repeater;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.AsyncErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.NetStatusEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.media.SoundTransform;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	import media.Source;
	
	import mx.collections.ArrayCollection;
	import mx.events.PropertyChangeEvent;
	import mx.graphics.ImageSnapshot;

	public class TubeHandler extends EventDispatcher
	{
		//event names
		public static const STATE_CHANGE:String="stateChange";
		public static const BINDING_LOSS:String="bindingLoss";
		//states
		public static const PLAYING:String="Playing";
		public static const PAUSED:String="Paused";
		public static const STOPPED:String="Stopped";
		//basic drawing stuff
		public static const ORIGIN:Point=new Point();
		public static const RECT:Rectangle=new Rectangle(0, 0, 640, 480);
		//general static handler for tubes stuff
		[Bindable]
		public static var tubes:ArrayCollection=new ArrayCollection();
		[Bindable]
		public var state:Object=STOPPED;
		[Bindable]
		public var source:Source;
		public var videoPlayer:Video;
		[Bindable]
		public var outputImage:Bitmap;
		[Bindable]
		public var processedImage:Bitmap;
		public var bitmapData:BitmapData;
		public var processedData:BitmapData;
		public var colorTransform:ColorTransform;
		[Bindable]
		public var volume:Number=1;
		public var volumeCache:Number=1;
		[Bindable]
		public var balance:Number=0;
		[Bindable]
		public var ns:NetStream;
		[Bindable]
		public var buffering:Boolean=true;
		[Bindable]
		public var bufferLength:Number=0;
		[Bindable]
		public var binded:Boolean=false;
		[Bindable]
		public var bindingHandler:TubeHandler;
		[Bindable]
		public var bindCount:Number=1;
		public var controller:TubeControl;
		public var invertFilter:Invert;
		[Bindable]
		public var invertFilterEnabled:Boolean = false;
		[Bindable]
		public var repeaterFilter:Repeater;
		[Bindable]
		public var index:Number=0;
		[Bindable]
		public var alpha:Number=1;

		public function TubeHandler(controller:TubeControl)
		{
			invertFilter=new Invert();
			repeaterFilter=new Repeater();
			this.controller=controller;
			bindingHandler=this;
			colorTransform=new ColorTransform();
			bitmapData=new BitmapData(RECT.width, RECT.height, true, 0x00000000);
			processedData=new BitmapData(RECT.width, RECT.height, true, 0x00000000);
			outputImage=new Bitmap(bitmapData);
			processedImage=new Bitmap(bitmapData);
			processedImage.opaqueBackground=null;
			videoPlayer=new Video(RECT.width, RECT.height);
			videoPlayer.cacheAsBitmap=true;
			videoPlayer.addEventListener(Event.ENTER_FRAME, attachWorkaround);
			videoPlayer.addEventListener(Event.ENTER_FRAME, updateOutput);
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

		private function clearOutputBitmap():void
		{
			outputImage.bitmapData.fillRect(outputImage.bitmapData.rect, 0);
			processedImage.bitmapData.fillRect(processedImage.bitmapData.rect, 0);
		}

		private function cloneOutputBitmap():void
		{
			outputImage.bitmapData.copyPixels(bindingHandler.bitmapData, bindingHandler.bitmapData.rect, ORIGIN);
			processedImage.bitmapData=outputImage.bitmapData.clone();
		}

		private function attachWorkaround(e:Event):void
		{
			videoPlayer.width=RECT.width;
			videoPlayer.height=RECT.height;
		}

		public function setSource(source:Source):void
		{
			this.source=source;
		}

		public function bindNewStream(time:Number=0):NetStream
		{
			var nc:NetConnection=new NetConnection();
			nc.connect(null);
			ns=new NetStream(nc);
			ns.bufferTime=5;
			ns.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler);
			ns.addEventListener(NetStatusEvent.NET_STATUS, netStreamStatusHandler);
			ns.client=this;
			videoPlayer.attachNetStream(ns);
			ns.play(source.videoStreamURL, time);
			return ns;
		}

		public function onMetaData(data:Object):void
		{
			//ignore
		}

		public function onCuePoint(data:Object):void
		{
			//ignore
		}

		private function asyncErrorHandler(event:AsyncErrorEvent):void
		{
			trace("caught a connection error but ignored: " + source.videoStreamURL);
		}

		public function unbindStream():void
		{
			videoPlayer.clear();
			state=STOPPED;
			buffering=false;
			if (ns != null && !hasEventListener(STATE_CHANGE))
			{
				ns.close();
				ns=null;
			}
			else if (hasEventListener(STATE_CHANGE))
			{
				dispatchEvent(new PropertyChangeEvent(BINDING_LOSS, false, false, "change in hands", null, null, ns));
			}
			if (binded)
			{
				bindingHandler.bindCount--;
				bindingHandler.removeEventListener(STATE_CHANGE, stateChangeEventHandler);
				bindingHandler.removeEventListener(BINDING_LOSS, bindingLossHandler);
				bindingHandler.videoPlayer.removeEventListener(Event.ENTER_FRAME, updateOutput);
				bindingHandler.videoPlayer.attachNetStream(bindingHandler.ns);
				bindingHandler=this;
				binded=false;
			}
		}

		public function bindHandler(target:TubeHandler):void
		{
			if (binded)
			{
				bindingHandler.bindHandler(target);
			}
			else
			{
				addEventListener(STATE_CHANGE, target.stateChangeEventHandler);
				addEventListener(BINDING_LOSS, target.bindingLossHandler);
				videoPlayer.addEventListener(Event.ENTER_FRAME, target.updateOutput);
				target.binded=true;
				target.bindingHandler=this;
				target.state=state;
				target.volume=volume;
				bindCount++;
			}
		}

		public function bindingLossHandler(event:PropertyChangeEvent):void
		{
			if (event.newValue != null)
			{
				unbindStream();
				ns=NetStream(event.newValue);
				state=PLAYING;
				videoPlayer.attachNetStream(ns);
				event.newValue=null;
				event.oldValue=this;
			}
			else
			{
				TubeHandler(event.oldValue).bindHandler(this);
			}
		}

		public function stateChangeEventHandler(event:Event):void
		{
			state=bindingHandler.state;
			switch (state)
			{
				case STOPPED:
					cloneOutputBitmap();
					break;
			}
		}

		public function pauseStream():void
		{
			if (!binded)
			{
				ns.pause();
				state=PAUSED;
				dispatchEvent(new Event(STATE_CHANGE));
			}
			else
			{
				bindingHandler.pauseStream();
			}
		}

		public function resumeStream():void
		{
			if (!binded)
			{
				ns.resume();
				state=PLAYING;
				dispatchEvent(new Event(STATE_CHANGE));
			}
			else
			{
				bindingHandler.resumeStream();
			}
		}

		public function playStream():void
		{
			if (!binded)
			{
				ns.play(source.videoStreamURL);
				videoPlayer.attachNetStream(ns);
			}
			else
			{
				bindingHandler.playStream();
			}
		}

		public function stopStream():void
		{
			if (!binded)
			{
				ns.close();
				state=STOPPED;
				dispatchEvent(new Event(STATE_CHANGE));
				videoPlayer.clear();
			}
			else
			{
				bindingHandler.stopStream();
			}
		}

		private function netStreamStatusHandler(event:NetStatusEvent):void
		{
			trace('netstream status update - ' + source.tubeId + ': ' + event.info.code);
			try
			{
				switch (event.info.code)
				{
					case "NetStream.Play.Start":
						state=PLAYING;
						dispatchEvent(new Event(STATE_CHANGE));
						volume=ns.soundTransform.volume;
						balance=ns.soundTransform.pan;
						break;
					case "NetStream.Buffer.Empty":
						buffering=true;
						break;
					case "NetStream.Buffer.Full":
						buffering=false;
				}
				switch (event.info.level)
				{
					case "error":
						dispatchEvent(new PropertyChangeEvent(STATE_CHANGE, false, false, "change", state, state, STOPPED));
						state=STOPPED;
						break;
				}
			}
			catch (error:TypeError)
			{
				// Ignore any errors.
			}
			dispatchEvent(new PropertyChangeEvent(STATE_CHANGE, false, false, "change", state, null, STOPPED));
		}

		public function toggleVolume():void
		{
			if (binded)
			{
				bindingHandler.toggleVolume();
			}
			else
			{
				if (volume == 0)
				{
					setVolume(volumeCache);
				}
				else
				{
					volumeCache=volume;
					setVolume(0);
				}
			}
		}

		public function setVolume(vol:Number):void
		{
			if (binded)
			{
				bindingHandler.setVolume(vol);
			}
			else
			{
				volume=vol;
				ns.soundTransform=new SoundTransform(vol);
			}
		}

		public function setBalance(bal:Number):void
		{
			if (binded)
			{
				bindingHandler.setBalance(bal);
			}
			else
			{
				balance=bal;
				ns.soundTransform=new SoundTransform(volume, balance);
			}
		}

		public function setAlpha(a:Number):void
		{
			colorTransform.alphaMultiplier=a;
			processedImage.transform.colorTransform=colorTransform;
			alpha=a;
		}

		public static function createTubeHandler():void
		{
			var tubeC:TubeControl=new TubeControl();
			tubes.addItem(tubeC);
			Tubular.appendTube(tubeC);
			orderTubes();
		}

		private static function orderTubes():void
		{
			for each (var tc:TubeControl in tubes)
			{
				tc.y=(tubes.getItemIndex(tc) * (tc.height + 10)) + 10;
				tc.tubeHandler.index=tubes.getItemIndex(tc);
			}
		}

		public static function shiftUp(tube:TubeControl):void
		{
			if (tubes.getItemIndex(tube) != 0)
			{
				var pos:Number=tubes.getItemIndex(tube)
				tubes.removeItemAt(pos);
				tubes.addItemAt(tube, pos - 1);
				orderTubes();
			}
		}

		public static function shiftDown(tube:TubeControl):void
		{
			if (tubes.getItemIndex(tube) < tubes.length - 1)
			{
				var pos:Number=tubes.getItemIndex(tube)
				tubes.removeItemAt(pos);
				tubes.addItemAt(tube, pos + 1);
				orderTubes();
			}
		}

		public static function basicBitmapData():BitmapData
		{
			return new BitmapData(RECT.width, RECT.height, true, 0x00000000);
		}
	}
}