package trolling.component.graphic
{
	import trolling.component.ComponentType;
	import trolling.component.DisplayComponent;
	import trolling.rendering.Texture;
	
	public class Image extends DisplayComponent
	{
		private const TAG:String = "[Image]";
		
		private var _texture:Texture;
		private var _name:String;
		
		public function Image(texture:Texture = null)
		{
			super(ComponentType.IMAGE);
			
			_texture = texture;
		}
		
		public function get name():String
		{
			return _name;
		}

		public function set name(value:String):void
		{
			_name = value;
		}

		public override function dispose():void
		{
			_texture = null;
			
			super.dispose();
		}
		
		/**
		 * 현재 프레임에 Render해야 하는 Texture를 반환합니다. 
		 * @return Image가 비활성화 상태이거나 지정된 Texture가 없을 경우 null을 반환합니다.
		 * 
		 */
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