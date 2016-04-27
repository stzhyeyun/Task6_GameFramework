package trolling.component.control
{
	import flash.utils.Dictionary;
	
	import trolling.component.Component;
	import trolling.component.ComponentType;
	import trolling.object.GameObject;
	
	public class Controller extends Component
	{
		public static const PLAYER:String = "player";
		public static const AI:String = "ai";
		
		private const TAG:String = "[Controller]";
		
		private var _id:String;
		private var _movements:Dictionary; 
		
		public function Controller(name:String, parent:GameObject, id:String)
		{
			super(ComponentType.CONTROLLER, name, parent);
			
			_id = id;
		}
	}
}