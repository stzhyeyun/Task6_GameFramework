package trolling.rendering 
{
	public class TriangleData
	{
		private static var _rawVertexData:Vector.<Number> = 
			Vector.<Number>([
				1, 1, 0, 1, 0,
				1, -1, 0, 1, 1,
				-1, -1, 0, 0, 1,
				-1, 1, 0, 0, 0]);
		private static var _rawIndexData:Vector.<uint> = 
			Vector.<uint>([
				0, 1, 2,
				2, 3, 0]);
		
		private var _uvData:Vector.<Number> = new <Number>[1, 1, 1, 1];
		
		public function TriangleData()
		{
			
		}
		
		public function get uvData():Vector.<Number>
		{
			return _uvData;
		}

		public function set uvData(value:Vector.<Number>):void
		{
			_uvData = value;
		}
		
		public static function get rawVertexData():Vector.<Number>
		{
			return _rawVertexData;
		}
		
		public static function get rawIndexData():Vector.<uint>
		{
			return _rawIndexData;
		}
	}
}