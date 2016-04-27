package trolling.object
{	
	public class Stage extends GameObject
	{	
		//	private var _width:int;
		//	private var _height:int;
		private var _color:uint;
		
		public function Stage(stageWidth:int, stageHeight:int, color:uint=0)
		{
			width = stageWidth;
			height = stageHeight;
			_color = color;
		}
		
		public function get color():uint
		{
			return _color;
		}
		
		public function set color(value:uint):void
		{
			_color = value;
		}
		
	}
}