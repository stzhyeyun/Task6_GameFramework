package trolling
{
	import trolling.object.GameObject;

	public class Scene extends GameObject
	{
		private const TAG:String = "[Scene]";
		
		private var _name:String;
		private var _isActive:Boolean;
	
		public function Scene()
		{
			super();
		}
		
		public override function dispose():void
		{
			_name = null;
			_isActive = false;
			
			super.dispose();
		}
		
		public function activate():void
		{
			// activate children
			
			
			_isActive = true;
		}
		
		public function deactivate():void
		{
			// deactive children

			
			_isActive = false;
		}
		
		public function get name():String
		{
			return _name;
		}
		
		public function set name(name:String):void
		{
			_name = name;
		}
		
		public function get isActive():Boolean
		{
			return _isActive;
		}
		
		public override function set pivot(value:String):void
		{
			return;
		}
	}
}