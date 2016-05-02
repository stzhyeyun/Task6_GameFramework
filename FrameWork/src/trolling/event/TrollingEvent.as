package trolling.event
{
	import flash.events.Event;

	public class TrollingEvent extends Event
	{		
		public static const ACTIVATE:String = "activate";
		public static const COLLIDE:String = "collide";
		public static const DEACTIVATE:String = "deactivate";
		public static const ENTER_FRAME:String = "enterFrame";
		public static const SOUND_COMPLETE:String = "soundComplete";
		
		private var _data:Object;
		
		public function TrollingEvent(type:String, data:Object = null)
		{
			super(type);
			_data = data;
		}

		public function get data():Object
		{
			return _data;
		}

	}
}