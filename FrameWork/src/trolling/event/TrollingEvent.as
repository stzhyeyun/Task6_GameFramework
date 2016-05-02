package trolling.event
{
	import flash.events.Event;

	public class TrollingEvent extends Event
	{		
		public static const COLLIDE:String = "collide";
		
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