package trolling.object
{
	
	public class Scene extends GameObject
	{
		private const TAG:String = "[Scene]";
		
		private var _key:String;
		
		public function Scene()
		{
			super();
		}
		
		public function get key():String
		{
			return _key;
		}
		
		public function set key(value:String):void
		{
			_key = value;
		}
		
		public override function set pivot(value:String):void
		{
			return;
		}
	}
}