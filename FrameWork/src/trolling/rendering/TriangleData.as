package trolling.rendering 
{
	public class TriangleData
	{
		private static var _rawIndexData:Vector.<uint> = 
			Vector.<uint>([
				0, 1, 2,
				2, 3, 0]);
		
		private var _rawVertexData:Vector.<Number> = new Vector.<Number>();
		private var _vertexData:Array = new Array();
		
		private var _uvData:Vector.<Number> = new <Number>[1, 1, 1, 1];
		
		public function TriangleData()
		{
			
		}
		
		public function calculVertex():void
		{
			while(_vertexData.length != 0)
				_rawVertexData = _rawVertexData.concat(_vertexData.shift());
		}
		
		public function get vertexData():Array
		{
			return _vertexData;
		}
		
		public function set vertexData(value:Array):void
		{
			_vertexData = value;
		}
		
		public function get uvData():Vector.<Number>
		{
			return _uvData;
		}
		
		public function set uvData(value:Vector.<Number>):void
		{
			_uvData = value;
		}
		
		public function get rawVertexData():Vector.<Number>
		{
			return _rawVertexData;
		}
		
		public static function get rawIndexData():Vector.<uint>
		{
			return _rawIndexData;
		}
	}
}