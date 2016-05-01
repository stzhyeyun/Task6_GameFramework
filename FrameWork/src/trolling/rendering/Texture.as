package trolling.rendering
{
	import flash.display.Bitmap;
	import flash.display3D.textures.Texture;
	
	import trolling.utils.TextureUtil;

	public class Texture
	{
		private var _width:Number;
		private var _height:Number;
		private var _u:Number;
		private var _v:Number;
		
		private var _nativeTexture:flash.display3D.textures.Texture;
		
		public function Texture(bitmap:Bitmap)
		{
			_width = bitmap.width;
			_height = bitmap.height;
			
			var textureInfo:Array = TextureUtil.fromBitmapData(bitmap.bitmapData);
			
			_nativeTexture = textureInfo[0];
			_u = textureInfo[1];
			_v = textureInfo[2];
		}
		
		public function get height():Number
		{
			return _height;
		}
		
		public function get width():Number
		{
			return _width;
		}

		public function get v():Number
		{
			return _v;
		}

		public function get u():Number
		{
			return _u;
		}

		public function get nativeTexture():flash.display3D.textures.Texture
		{
			return _nativeTexture;
		}

	}
}