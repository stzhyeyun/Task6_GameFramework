package trolling.core
{	
	import trolling.component.Component;
	import trolling.object.GameObject;
	
	public class Disposer
	{	
		private static var _deathNote:Vector.<GameObject>;
		
		public function Disposer()
		{
			
		}
		
		public static function requestDisposal(target:GameObject):void
		{
			if (!target)
			{
				return;
			}
			
			if (!_deathNote)
			{
				_deathNote = new Vector.<GameObject>();
			}
			_deathNote.push(target);
		}
		
		public static function disposeObjects():void
		{
			if (_deathNote)
			{
				var gameObject:GameObject;
				for (var i:int = 0; i < _deathNote.length; i++)
				{
					gameObject = _deathNote[i];
					
					for(var componentType:String in gameObject.components)
					{
						var component:Component = gameObject.components[componentType];
						component.dispose();
					}
					gameObject.removeFromParent();
				}
			}
			_deathNote = null;
		}
	}
}