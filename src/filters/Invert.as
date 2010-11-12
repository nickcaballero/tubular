package filters
{
	import flash.display.BitmapData;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Point;

	public class Invert implements IBitmapFilter
	{
		private const arr:Array=[-1, 0, 0, 0, 255, 0, -1, 0, 0, 255, 0, 0, -1, 0, 255, 0, 0, 0, 1, 0]
		private const p:Point = new Point(0,0);
		public function Invert()
		{
		}

		public function applyFilter(bitmapData:BitmapData):void
		{
			bitmapData.applyFilter(bitmapData, bitmapData.rect, p, new ColorMatrixFilter(arr));
		}

	}
}