package trolling.core
{
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	import trolling.object.Scene;
	
	public class SceneManager
	{	
		private static var _sceneDic:Dictionary;
		private static var _sceneVector:Vector.<Scene> = new Vector.<Scene>();
		
		public function SceneManager()
		{
			
		}
		
		/**
		 *현제의 Scene을  
		 * @param key
		 * 
		 */		
		public static function goScene(key:String):void
		{
			if(_sceneDic == null || _sceneDic[key] == null)
				return;
			
			if(Trolling.current.currentScene != null)
				_sceneVector.push(_sceneDic[Trolling.current.currentScene.key]);
			switchScene(key);
		}
		
		public static function outScene():void
		{
			var scene:Scene = _sceneVector.pop();
			switchScene(scene.key);
		}
		
		public static function addScene(sceneClass:Class, key:String):void
		{
			if(_sceneDic && _sceneDic[key] != null)
				return;
			if(Trolling.current.context == null)
			{
				var addArray:Array = new Array();
				addArray.push(sceneClass);
				addArray.push(key);
				Trolling.current.createQueue.push(addArray);
				return;	
			}
			var scene:Scene = new sceneClass() as Scene;
			scene.key = key;
			if(!_sceneDic)
			{
				_sceneDic = new Dictionary();
				Trolling.current.currentScene = scene;
			}
			_sceneDic[key] = scene;
			scene.width = Trolling.current.stage.stageWidth;
			scene.height = Trolling.current.stage.stageHeight;
		}
		
		public static function switchScene(key:String):void
		{
			if(_sceneDic == null || _sceneDic[key] == null)
				return;
			if(Trolling.current.currentScene != null)
			{
				Trolling.current.currentScene.visable = false;
				Trolling.current.currentScene.dispatchEvent(new Event(Event.DEACTIVATE));
			}
			Trolling.current.currentScene = _sceneDic[key];
			Trolling.current.currentScene.dispatchEvent(new Event(Event.ACTIVATE));
			Trolling.current.currentScene.visable = true;
		}
	}
}