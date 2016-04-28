package trolling.rendering 
{
	public class TriangleData
	{
		private var _rawVertexData:Vector.<Number>;
		private var _vertexData:Array;
		private var _rawIndexData:Vector.<uint>;
		private var _indexData:Array;
		
		private var _uvData:Vector.<Number> = new <Number>[1, 1, 1, 1];
		
		public function TriangleData()
		{
			initArray();
		}
		
		public function get uvData():Vector.<Number>
		{
			return _uvData;
		}

		public function set uvData(value:Vector.<Number>):void
		{
			_uvData = value;
		}

		public function initArray():void
		{
			_vertexData = new Array();
			_indexData = new Array();
		}
		
		public function calculData():void
		{
			_rawVertexData = new Vector.<Number>();
			for(var i:int = 0; i < _vertexData.length; i++)
			{
				var vecTemp:Vector.<Number> = Vector.<Number>(_vertexData[i]);
				//	trace(_vertexData[i][0]);
				_rawVertexData = _rawVertexData.concat(vecTemp);
				//	trace("_rawVertexData.length = " + _rawVertexData.length);
			}
			
			_rawIndexData = new Vector.<uint>();
			for(var j:int = 0; j < _indexData.length; j++)
			{
				var indTemp:Vector.<uint> = Vector.<uint>(_indexData[j]);
				_rawIndexData = _rawIndexData.concat(indTemp);
				//	trace("_rawIndexData.length = " + _rawIndexData.length);
			}
		}
		
		public function get indexData():Array
		{
			return _indexData;
		}
		
		public function set indexData(value:Array):void
		{
			_indexData = value;
		}
		
		public function get vertexData():Array
		{
			return _vertexData;
		}
		
		public function set vertexData(value:Array):void
		{
			_vertexData = value;
		}
		
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
	}
}