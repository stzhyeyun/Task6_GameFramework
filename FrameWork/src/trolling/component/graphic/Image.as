package trolling.component.graphic
{
	import flash.display.Bitmap;
	
	import trolling.component.ComponentType;
	import trolling.component.DisplayComponent;
	import trolling.rendering.Texture;
	
	public class Image extends DisplayComponent
	{
		private const TAG:String = "[Image]";
		
		private var _texture:Texture;
		
		public function Image(resource:Bitmap, isActive:Boolean = false)
		{
			super(ComponentType.IMAGE, isActive);
			
			if (!resource)
			{
				//super.dispose(); // ?
				throw new ArgumentError(TAG + " ctor : No \'resource\'.");
			}
			
			var texture:Texture = new Texture(resource);
			
			if (!texture)
			{
				throw new ArgumentError(TAG + " ctor : Failed to create a Texture.");
			}
			
			_texture = texture;
		}
		
		public override function dispose():void
		{
//			if (_texture)
//			{
//				_texture.dispose();
//			}
			_texture = null;
			
			super.dispose();
		}
		
		public override function getRenderingResource():Texture
		{
			if (!_isActive)
			{
				trace(TAG + " getRenderingResource : Image is inactive now.");
				return null;
			}
			
			if (_texture)
			{
				return _texture;
			}
			else
			{
				trace(TAG + " getRenderingResource : No texture.");
				return null;
			}
		}
	}
}