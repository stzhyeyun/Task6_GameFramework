package trolling.utils
{
	import flash.events.Event;

	public class EventWith extends flash.events.Event
	{		
		private var _data:Object;
		
		public function EventWith(type:String, data:Object = null)
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