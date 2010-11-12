/**
 * Copyright appended by Nick Caballero for the usage of the Kaleidoscope effect workflow. Some changes
 * were made for this implementation
 *
 * Copyright (c) 2003-2010 Mario Klingemann
 *
 * http://www.quasimondo.com
 * twitter: @quasimondo
 * contact: mario@quasimondo.com
 *
 * All rights reserved.
 *
 * Licensed under the CREATIVE COMMONS Attribution-Noncommercial-Share Alike 3.0
 * You may not use this file except in compliance with the License.
 * You may obtain a copy of the License at: http://creativecommons.org/licenses/by-nc-sa/3.0/us/
 *
 */
package filters
{
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;

	public class Kaleidoscope
	{

		private var rect:Rectangle=new Rectangle(120, 90);

		private var diag:Number;
		private var _alpha:ColorTransform=new ColorTransform();
		private var _slices:int=12;

		private var nudge:Number=0.09;
		private var sclfact:Number=0;
		private var rot:Number=0;
		private var r:Number=0;
		private var r2:Number=0;
		private var sh1:Number=0;
		private var sh2:Number=0;
		private var scl:Number=1;
		private var m:Matrix=new Matrix();

		public var rotate1:Boolean=true;
		public var rotate2:Boolean=true;
		public var rotate3:Boolean=true;
		public var flip:Boolean=false;
		public var singleview:Boolean=true;
		public var rotspeed1:Number=0.007;
		public var rotspeed2:Number=-0.003;
		public var rotspeed3:Number=-0.005;

		private var angle:Number;
		private var stampImage:BitmapData;

		private const mat1:Matrix=new Matrix(0.5, 0, 0, 0.5);
		private const mat2:Matrix=new Matrix(-0.5, 0, 0, 0.5, rect.width);
		private const mat3:Matrix=new Matrix(0.5, 0, 0, -0.5, 0, rect.height);
		private const mat4:Matrix=new Matrix(-0.5, 0, 0, -0.5, rect.width, rect.height);

		public function Kaleidoscope()
		{
			stampImage=new BitmapData(120,90,true,0x00000000);
			diag = Math.sqrt(2 * rect.width * rect.height) * .62;
			angle	= Math.PI / _slices;
		}

		public function applyFilter(source:BitmapData):BitmapData
		{
			var slice:Shape=new Shape();

			stampImage.fillRect(rect, 0);
			stampImage.draw(source, mat1);
			stampImage.draw(source, mat2);
			stampImage.draw(source, mat3);
			stampImage.draw(source, mat4);

			source.fillRect(rect, 0);

			if (rotate1)
			{
				r+=rotspeed1;
			}
			if (rotate2)
			{
				r2-=rotspeed2;
			}
			if (rotate3)
			{
				rot+=rotspeed3;
			}
			for (var i:int=0; i <= _slices; i++)
			{
				m.identity();
				m.b+=sh1;
				m.c+=sh2;
				m.rotate(r2);
				m.translate(2 * 10 / scl, 2 * 10 / scl + i * sclfact * 10);
				m.rotate(r);
				m.scale(scl, scl);

				var graphics:Graphics=slice.graphics;
				graphics.lineStyle();
				graphics.moveTo(0, 0);
				graphics.beginBitmapFill(stampImage, m);
				graphics.lineTo(Math.cos((angle + nudge) - Math.PI / 2) * diag, Math.sin((angle + nudge) - Math.PI / 2) * diag);
				graphics.lineTo(Math.cos(-(angle + nudge) - Math.PI / 2) * diag, Math.sin(-(angle + nudge) - Math.PI / 2) * diag);
				graphics.lineTo(0, 0);
				graphics.endFill();
				m.identity();
				if (flip && i % 2 == 1)
				{
					m.scale(-1, 1);
				}
				m.rotate(rot + i * angle * 2);
				m.translate(rect.width * 0.5, rect.height * 0.5);

				source.draw(slice, m);
				trace("draw");
			}
			return source;
		}

	}
}