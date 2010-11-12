package media.youtube
{
	import media.youtube.ui.YouTubeList;


	public class YouTube
	{

		import mx.events.DragEvent;
		import mx.rpc.events.ResultEvent;
		import mx.collections.ArrayCollection;
		import mx.collections.XMLListCollection;
		import flash.display.Sprite;
		import flash.errors.*;
		import flash.events.*;
		import flash.net.URLLoader;
		import flash.net.URLRequest;

		[Bindable]
		public static var youtubeEntries:ArrayCollection=new ArrayCollection();
		[Bindable]
		public static var currentState:String = '';
		private static var pool:YouTubeList;

		public static function setPool(poo:YouTubeList):void
		{
			currentState='';
			pool=poo;
		}

		public static function searchVideos(keywords:String):void
		{
			try
			{
				var url:String="http://gdata.youtube.com/feeds/api/videos?q=" + keywords;
				var request:URLRequest=new URLRequest(url);
				var loader:URLLoader=new URLLoader();
				loader.addEventListener(Event.COMPLETE, completeHandler);
				loader.load(request);
				currentState='searching';
			}
			catch (error:Error)
			{
				trace("error caught: " + url);
			}
		}

		private static function completeHandler(event:Event):void
		{
			var xml:XML=XML(event.target.data);
			youtubeEntries.removeAll();
			for each (var element:XML in xml.children())
			{
				if (element.localName() == "entry")
				{
					youtubeEntries.addItem(new YouTubeSource(element));
				}
			}
			currentState='browsing';
		}

	}
}