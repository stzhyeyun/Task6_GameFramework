package trolling.utils
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.Texture;
	import flash.geom.Matrix;
	
	import trolling.core.Trolling;
	
	public class TextureUtil
	{	
		public function TextureUtil()
		{
			
		}
		
		public static function fromBitmap(bitmap:Bitmap):flash.display3D.textures.Texture
		{
			var _nativeTexture:flash.display3D.textures.Texture;
			
			var binaryWidth:Number = nextPowerOfTwo(bitmap.width);
			var binaryHeight:Number = nextPowerOfTwo(bitmap.height);
			
			var matrix:Matrix = new Matrix();
			matrix.scale(binaryWidth/bitmap.width, binaryHeight/bitmap.height);
			
			//	var _nativeTexture:flash.display3D.textures.Texture;
			_nativeTexture = Trolling.current.context.createTexture(binaryWidth, binaryHeight, Context3DTextureFormat.BGRA, false);
			//	_nativeTexture.uploadFromBitmapData(bitmap.bitmapData);
			
			var bitmapData:BitmapData = new BitmapData(binaryWidth, binaryHeight);
			bitmapData.draw(bitmap.bitmapData, matrix);
			_nativeTexture.uploadFromBitmapData(bitmapData);
			return _nativeTexture;
		}
		
		public static function nextPowerOfTwo(v:uint): uint
		{
			v--;
			v |= v >> 1;
			v |= v >> 2;
			v |= v >> 4;
			v |= v >> 8;
			v |= v >> 16;
			v++;
			return v;
		}
	}
}