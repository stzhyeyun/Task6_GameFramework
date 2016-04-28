/*
	[!] DISUSE Currently
*/
package trolling.component.control
{
	import flash.utils.Dictionary;
	
	import trolling.component.Component;
	import trolling.component.ComponentType;
	
	public class Controller extends Component
	{
		public static const PLAYER:String = "player";
		public static const AI:String = "ai";
		
		private const TAG:String = "[Controller]";
		
		private var _id:String;
		private var _movements:Dictionary; 
		
		public function Controller(name:String, id:String)
		{
			super(ComponentType.CONTROLLER, name);
			
			_id = id;
		}
	}
}