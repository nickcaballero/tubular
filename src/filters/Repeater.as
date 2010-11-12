package filters
{
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Point;

	public class Repeater implements IBitmapFilter
	{
		[Bindable]
		public var amount:Number=2;
		private var _bmp:BitmapData;

		public function Repeater()
		{
		}

		public function applyFilter(bitmapData:BitmapData):void
		{
			var amount:int=amount;
			var square:int=Math.pow(amount, 2);

			var scaleX:Number=Math.ceil(bitmapData.width / amount);
			var scaleY:Number=Math.ceil(bitmapData.height / amount);

			var newbmp:BitmapData=new BitmapData(scaleX, scaleY, true, 0x00000000);
			var matrix:Matrix=new Matrix();
			matrix.scale(1 / amount, 1 / amount);
			newbmp.draw(bitmapData, matrix);

			for (var count:int=0; count < square; count++)
			{
				bitmapData.copyPixels(newbmp, newbmp.rect, new Point((count % amount) * scaleX, int(count / amount) * scaleY));
			}
		}

	}
}