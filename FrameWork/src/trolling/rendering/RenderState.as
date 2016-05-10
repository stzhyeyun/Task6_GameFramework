package trolling.rendering
{
	import flash.geom.Matrix3D;
	
	public class RenderState
	{
		private var _alpha:Number;
		private var _culling:String;
		private var _matrix:Matrix3D;
		private var _red:Number;
		private var _green:Number;
		private var _blue:Number;
		
		public function RenderState()
		{
			
		}

		public function get blue():Number
		{
			return _blue;
		}

		public function set blue(value:Number):void
		{
			_blue = value;
		}

		public function get green():Number
		{
			return _green;
		}

		public function set green(value:Number):void
		{
			_green = value;
		}

		public function get red():Number
		{
			return _red;
		}

		public function set red(value:Number):void
		{
			_red = value;
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