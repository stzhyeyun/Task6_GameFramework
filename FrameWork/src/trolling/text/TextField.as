package trolling.text
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.text.TextField;
	
	import trolling.component.graphic.Image;
	import trolling.object.GameObject;
	import trolling.rendering.Texture;
	import trolling.utils.Color;

	public class TextField extends GameObject
	{	
		private var _textImage:Image;
		private var _textTexture:Texture;
		
		public function TextField(width:Number, height:Number, text:String, color:uint = Color.BLACK)
		{
			super();
			
			var nativeTextField:flash.text.TextField = new flash.text.TextField();
			nativeTextField.text = text;
			nativeTextField.textColor = color;
			
			var textData:BitmapData = new BitmapData(width, height, true, 0x0);
			textData.draw(nativeTextField);
			
			var bitmapText:Bitmap = new Bitmap(textData);
			
			_textTexture = new Texture(bitmapText);
			_textImage = new Image(_textTexture);
			
			addComponent(_textImage);
		}
	}
}