package media.youtube
{
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import media.Source;
	
	import mx.events.PropertyChangeEvent;
	import mx.formatters.DateFormatter;


	public class YouTubeSource extends Source
	{
		public function YouTubeSource(xml:XML)
		{
			for each (var element:XML in xml.children())
			{
				if (element.localName() == "id")
				{
					id=element.toString().substr(element.toString().lastIndexOf("/") + 1);
				}
				if (element.localName() == "title")
				{
					name=element;
				}
				if (element.localName() == "author")
				{
					author=element.child(0);
				}
				if (element.localName() == "group")
				{
					for each (var element1:XML in element.children())
					{
						if (element1.localName() == "description")
						{
							description=element1;
						}
						if (element1.localName() == "duration")
						{
							duration=element1.attribute("seconds");
							var date:Date=new Date(null, null, null, 0, 0, Number(duration));
							var dateF:DateFormatter=new DateFormatter();
							dateF.formatString="JJ:NN:SS";
							durationFormatted=dateF.format(date);
						}
						if (element1.localName() == "thumbnail")
						{
							videoImageURL=element1.attribute("url");
						}
					}
				}
			}
			tubeId="youtube://"+id;
			retrieveVideoURL();
		}

		private function retrieveVideoURL():void
		{
			var url:String="http://www.youtube.com/watch/?v=" + id;
			var request:URLRequest=new URLRequest(url);
			var loader:URLLoader=new URLLoader();
			loader.addEventListener(Event.COMPLETE, completeHandler);
			try
			{
				loader.load(request);
			}
			catch (error:Error)
			{
				trace("unable to retrieve video url");
			}
		}

		private function completeHandler(event:Event):void
		{
			var page:String=String(event.target.data);
			page=page.substring(page.indexOf("fmt_url_map") + String("fmt_url_map=").length, page.indexOf("&", page.indexOf("fmt_url_map")));
			page=unescape(page);
			var streams:Array=page.split(",");
			var pair:Array;
			for each (var stream:String in streams)
			{
				pair=stream.split("|");
				if (pair[0] == "34")
				{
					videoStreamURL=pair[1];
				}
			}
			dispatchEvent(new PropertyChangeEvent("propertyChange"));
		}
	}
}