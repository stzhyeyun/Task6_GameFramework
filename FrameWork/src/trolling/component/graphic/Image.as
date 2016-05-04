package trolling.component.graphic
{
	import trolling.component.ComponentType;
	import trolling.component.DisplayComponent;
	import trolling.rendering.Texture;
	
	public class Image extends DisplayComponent
	{
		private const TAG:String = "[Image]";
		
		private var _texture:Texture;
		
		public function Image(texture:Texture = null)
		{
			super(ComponentType.IMAGE);
			
			_texture = texture;
		}
		
		public override function dispose():void
		{
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

		public function get texture():Texture
		{
			return _texture;
		}

		public function set texture(value:Texture):void
		{
			_texture = value;
		}
	}
}