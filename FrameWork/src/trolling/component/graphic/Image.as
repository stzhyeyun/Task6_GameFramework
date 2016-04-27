package trolling.component.graphic
{
	import flash.display.BitmapData;
	
	import trolling.component.ComponentType;
	import trolling.component.DisplayComponent;
	import trolling.object.GameObject;
	
	public class Image extends DisplayComponent
	{
		private const TAG:String = "[Image]";
		
		private var _bitmapData:BitmapData;
		
		public function Image(name:String, parent:GameObject, resource:BitmapData)
		{
			super(ComponentType.IMAGE, name, parent);
			
			_bitmapData = resource;
		}
		
		public override function dispose():void
		{
			if (_bitmapData)
			{
				//_bitmapData.dispose();
			}
			_bitmapData = null;
			
			super.dispose();
		}
		
		public override function getRenderingResource():BitmapData
		{
			if (!_isActive)
			{
				return null;
			}
			
			if (_bitmapData)
			{
				return _bitmapData;
			}
			else
			{
				return null;
			}
		}
	}
}