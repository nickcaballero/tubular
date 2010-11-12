package filters
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;

	public interface IBitmapFilter
	{
		function applyFilter(bitmapData:BitmapData):void;
	}
}