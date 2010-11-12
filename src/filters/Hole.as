package filters
{
	import flash.display.BitmapData;
	import flash.display.Shape;

	public class Hole implements IBitmapFilter
	{
		
		private var circle:Shape;
		public function Hole()
		{
			circle = new Shape();
			circle.graphics.beginFill(0xFF0000);
			circle.graphics.drawCircle(10,10,10);
		}

		public function applyFilter(source:BitmapData):void
		{
			source.draw(circle);
		}
		
	}
}