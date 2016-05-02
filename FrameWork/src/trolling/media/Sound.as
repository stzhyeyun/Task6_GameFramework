package trolling.media
{
	import flash.media.SoundLoaderContext;
	import flash.net.URLRequest;

	public class Sound extends flash.media.Sound
	{
		public static const INFINITE:int = -1;
		public static const NO_LOOP:int = 0;
		
		private var _volume:Number; // 0(Mute) to 1(Max)
		private var _panning:Number; // -1(Left) to 1(Right)
		private var _startTime:Number; // millisecond
		private var _loops:int;
		private var _channelIndex:int;
		
		public function Sound(stream:URLRequest = null, context:SoundLoaderContext = null)
		{
			super(stream, context);
			
			_volume = 1;
			_panning = 0;
			_startTime = 0;
			_loops = NO_LOOP;
			_channelIndex = -1;
		}

		public function dispose():void
		{
			_volume = 1;
			_panning = 0;
			_startTime = 0;
			_loops = NO_LOOP;
			_channelIndex = -1;
			
			super.close();
		}
		
		public function get volume():Number
		{
			return _volume;
		}
		
		public function set volume(value:Number):void
		{
			_volume = value;
		}
		
		public function get panning():Number
		{
			return _panning;
		}
		
		public function set panning(value:Number):void
		{
			_panning = value;
		}
		
		public function get startTime():Number
		{
			return _startTime;
		}
		
		public function set startTime(value:Number):void
		{
			_startTime = value;
		}
		
		public function get loops():int
		{
			return _loops;
		}
		
		public function set loops(value:int):void
		{
			_loops = value;
		}
		
		public function get channelIndex():int
		{
			return _channelIndex;
		}
		
		public function set channelIndex(value:int):void
		{
			_channelIndex = value;
		}
	}
}