package media
{
	import flash.events.EventDispatcher;

	public class Source extends EventDispatcher
	{
		public static var sources:Array=new Array();
		[Bindable]
		public var rawURL:String;
		[Bindable]
		public var videoStreamURL:String;
		[Bindable]
		public var videoImageURL:String;
		[Bindable]
		public var name:String;
		[Bindable]
		public var description:String;
		[Bindable]
		public var duration:String;
		[Bindable]
		public var durationFormatted:String;
		[Bindable]
		public var author:String;
		[Bindable]
		public var id:String;
		[Bindable]
		public var tubeId:String;

		public function Source(obj:Object=null)
		{
		}

		public static function getSource(tubeId:String, cl:Class, param:Object=null):Source
		{
			if (sources[tubeId] == null)
			{
				sources[tubeId]=new cl(param);
			}
			return sources[tubeId];
		}
	}
}