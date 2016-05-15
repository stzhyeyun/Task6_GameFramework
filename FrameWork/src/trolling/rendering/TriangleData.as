package trolling.rendering 
{
	public class TriangleData
	{
//		private static var _rawIndexData:Vector.<uint> = 
//			Vector.<uint>([
//				0, 1, 2,
//				2, 3, 0]);
		
		private var _rawIndexData:Vector.<uint> = 
			Vector.<uint>([
				0, 1, 2,
				2, 3, 0]);
		
		private var _rawVertexData:Vector.<Number> = new Vector.<Number>();
		
		public function TriangleData()
		{
			
		}

//		public function calculVertex():void
//		{
//			while(_vertexData.length != 0)
//				_rawVertexData = _rawVertexData.concat(_vertexData.shift());
//		}
		
		public function get rawVertexData():Vector.<Number>
		{
			return _rawVertexData;
		}
		
		public function set rawVertexData(value:Vector.<Number>):void
		{
			_rawVertexData = value;
		}
		
		public function get rawIndexData():Vector.<uint>
		{
			return _rawIndexData;
		}
		
		public function set rawIndexData(value:Vector.<uint>):void
		{
			_rawIndexData = value;
		}
		
//		public static function get rawIndexData():Vector.<uint>
//		{
//			return _rawIndexData;
//		}
	}
}