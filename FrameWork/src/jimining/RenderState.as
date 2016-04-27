package jimining
{
	import flash.display3D.Context3D;
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.geom.Rectangle;
	
	import trolling.core.Trolling;
	
	import trolling.rendering.Program;
	
	public class RenderState
	{
		private var _alpha:Number;
		private var _culling:String;
		private var _program:Program;
		private var _matrix3D:Matrix3D;
		private var _textureFlag:Boolean;
		
		//	private static var sMatrix3D:Matrix3D = new Matrix3D();
		
		public function RenderState()
		{
			
		}
		
		public function setState():void
		{
			_culling = Trolling.painter.culling;
			_matrix3D = Trolling.painter.matrix;
			_textureFlag = Trolling.painter.textureFlag;
		}
		
		public function getState():void
		{
			Trolling.painter.culling = _culling;
			Trolling.painter.matrix = _matrix3D;
			Trolling.painter.textureFlag = _textureFlag;
		}
	}
}