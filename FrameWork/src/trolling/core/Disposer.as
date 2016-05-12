package trolling.core
{	
	import trolling.component.Component;
	import trolling.object.GameObject;
	
	public class Disposer
	{	
		private static var _gameObjects:Vector.<GameObject>;
		private static var _components:Vector.<Component>;
		
		public function Disposer()
		{
			
		}
		
		public static function requestDisposal(target:Object):void
		{
			if (!target)
			{
				return;
			}
			
			if (target is GameObject)
			{
				if (!_gameObjects)
				{
					_gameObjects = new Vector.<GameObject>();
				}
				_gameObjects.push(target);
			}
			else if (target is Component)
			{
				if (!_components)
				{
					_components = new Vector.<Component>();
				}
				_components.push(target);
			}
		}
		
		public static function disposeObjects():void
		{
			if (_gameObjects)
			{
				for (var i:int = 0; i < _gameObjects.length; i++)
				{
					_gameObjects[i].removeFromParent();
				}
				_gameObjects.splice(0, _gameObjects.length);
			}
			_gameObjects = null;
			
			if (_components)
			{
				for (i = 0; i < _components.length; i++)
				{
					if (_components[i])
					{
						_components[i].parent = null;
					}
				}
				_components.splice(0, _components.length);
			}
			_components = null;
		}
	}
}