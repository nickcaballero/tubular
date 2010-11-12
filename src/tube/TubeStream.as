package tube
{
	import flash.net.NetConnection;
	import flash.net.NetStream;

	public class TubeStream extends NetStream
	{

		public var subscribers:Number=0;

		public function TubeStream(connection:NetConnection, peerID:String=connectToFMS)
		{
			super(connection, peerID);
		}

		public function bindPlayer(obj:Object):void
		{
			subscribers++;
		}

		public function unbindPlayer(obj:Object):void
		{
			subscribers--;
			if (subscribers < 1)
			{
				this.close();
			}
		}

	}
}