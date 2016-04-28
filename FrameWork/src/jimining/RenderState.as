package jimining
{
	import flash.geom.Matrix3D;
	
	public class RenderState
	{
		private var _alpha:Number;
		private var _culling:String;
		private var _matrix:Matrix3D;
		
		//	private static var sMatrix3D:Matrix3D = new Matrix3D();
		
		public function RenderState()
		{
			
		}

		public function get matrix():Matrix3D
		{
			return _matrix;
		}

		public function set matrix(value:Matrix3D):void
		{
			_matrix = value;
		}

		public function get culling():String
		{
			return _culling;
		}

		public function set culling(value:String):void
		{
			_culling = value;
		}

		public function get alpha():Number
		{
			return _alpha;
		}

		public function set alpha(value:Number):void
		{
			_alpha = value;
		}

	}
}