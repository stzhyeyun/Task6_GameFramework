package trolling.core
{	
	import trolling.component.Component;
	import trolling.object.GameObject;
	
	public class Disposer
	{	
		private static var _gameObjects:Vector.<GameObject>;
		
		public function Disposer()
		{
			
		}
		
		/**
		 *인자로 받은 GameObject는 정지가 되어야할 객체로 등록되며  다음 프레임이 시작될 때 정지됩니다.
		 * @param target
		 * 
		 */		
		public static function requestDisposal(target:GameObject):void
		{
			if (!target)
			{
				return;
			}
			
			if (!_gameObjects)
			{
				_gameObjects = new Vector.<GameObject>();
			}
			_gameObjects.push(target);
		}
		
		public static function disposeObjects():void
		{
			if (_gameObjects)
			{
				for (var i:int = 0; i < _gameObjects.length; i++)
				{
					_gameObjects[i].removeFromParent();
					
					if (_gameObjects[i].components)
					{
						for (var key:String in _gameObjects[i].components)
						{
							var component:Component = _gameObjects[i].components[key];
							component.dispose();
							delete _gameObjects[i].components[key];
						}
					}
				}
				_gameObjects.splice(0, _gameObjects.length);
			}
			_gameObjects = null;
		}
	}
}