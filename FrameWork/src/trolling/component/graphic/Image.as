package trolling.component.graphic
{
	import flash.display.Bitmap;
	
	import trolling.component.ComponentType;
	import trolling.component.DisplayComponent;
	import trolling.object.GameObject;
	import trolling.rendering.Texture;
	
	public class Image extends DisplayComponent
	{
		private const TAG:String = "[Image]";
		
		private var _texture:Texture;
		
		public function Image(name:String, parent:GameObject, resource:Bitmap)
		{
			super(ComponentType.IMAGE, name, parent);
			
			if (!resource)
			{
				//super.dispose();
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
				return null;
			}
			
			if (_texture)
			{
				return _texture;
			}
			else
			{
				return null;
			}
		}
	}
}