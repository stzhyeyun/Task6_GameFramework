package trolling.rendering 
{
	import flash.display.Stage3D;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DTriangleFace;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.VertexBuffer3D;
	import flash.events.Event;
	import flash.geom.Matrix3D;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	
	import jimining.RenderState;
	
	import trolling.object.GameObject;
	
	public class Painter
	{	
		private static const Z_AXIS:Vector3D = Vector3D.Z_AXIS;
		
		private var _root:GameObject;
		
		private var _stage3D:Stage3D;
		private var _context:Context3D;
		
		private var _viewPort:Rectangle;
		
		private var _vertexBuffer:VertexBuffer3D;
		private var _indexBuffer:IndexBuffer3D;
		
		private var _backBufferWidth:Number;
		private var _backBufferHeight:Number;
		
		private var _culling:String;
		private var _matrix:Matrix3D = new Matrix3D();
		private var _textureFlag:Boolean;
		private var _program:Program;
		
		private var _stateStack:Vector.<RenderState> = new Vector.<RenderState>();
		
		private var _moleCallBack:Function;
		
		public function Painter(stage3D:Stage3D)
		{
			_stage3D = stage3D;
			_program = new Program();
			_matrix.identity();
			trace("Painter Creater");
		}
		
		public function initPainter(resultFunc:Function):void
		{
			_stage3D.addEventListener(Event.CONTEXT3D_CREATE, initMolehill);
			_stage3D.requestContext3D();
			_moleCallBack = resultFunc;
		}
		
		private function initMolehill(event:Event):void
		{
			_context = _stage3D.context3D;	
			_moleCallBack(_context);
			_program.initProgram(_context);
			setProgram();
		}
		
		public function configureBackBuffer(viewPort:Rectangle, antiAlias:Boolean = true):void
		{
			_stage3D.x = viewPort.x;
			_stage3D.y = viewPort.y;
			
			_viewPort = viewPort;
			
			var alias:int;
			if(antiAlias)
				alias = 1;
			else
				alias = 0;
			
			trace(viewPort.width + ", " + viewPort.height);
			_context.configureBackBuffer(viewPort.width, viewPort.height, alias, true);
			_context.setCulling(Context3DTriangleFace.BACK);
			
			_backBufferWidth = viewPort.width;
			_backBufferHeight = viewPort.height;
		}
		
		public function setDrawData(triagleData:TriangleData):void
		{
			createVertexBuffer(triagleData);
			createIndexBuffer(triagleData);
			setUVVector(triagleData);
			setVertextBuffer();
			setMatrix();
		}
		
		public function present():void
		{
			_context.present();	
		}
		
		public function draw():void
		{
			_context.drawTriangles(_indexBuffer);
		}
		
		public function appendMatrix(matrix:Matrix3D):void
		{
//			_matrix.append(matrix);
			_matrix = matrix;
		}
		
		private function setUVVector(triagleData:TriangleData):void
		{
			_context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 4, triagleData.uvData);
		}
		
		private function createVertexBuffer(triangleData:TriangleData):void
		{
			_vertexBuffer = _context.createVertexBuffer(triangleData.vertexData.length, 5);
//			trace("triangleData.rawVertexData = " + triangleData.rawVertexData.length);
			_vertexBuffer.uploadFromVector(triangleData.rawVertexData, 0, triangleData.vertexData.length);
//			trace("triangleData.vertexData.length = " + triangleData.vertexData.length);
//			trace("triangleData.vertexData = " + triangleData.rawVertexData);
		}
		
		private function createIndexBuffer(triangleData:TriangleData):void
		{
			_indexBuffer = _context.createIndexBuffer(triangleData.rawIndexData.length);
//			trace("triangleData.rawIndexData.length = " + triangleData.rawIndexData.length);
			_indexBuffer.uploadFromVector(triangleData.rawIndexData, 0, triangleData.rawIndexData.length);
//			trace("triangleData.rawIndexData = " + triangleData.rawIndexData);
		}
		
		private function setVertextBuffer():void
		{
			_context.setVertexBufferAt(0, _vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_3);
			_context.setVertexBufferAt(1, _vertexBuffer, 3, Context3DVertexBufferFormat.FLOAT_2);
		}
		
		private function setMatrix():void
		{
		
			_context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, _matrix, true);
		}
		
		private function setProgram():void
		{
			_context.setProgram(_program.program);
		}
		
		public function get viewPort():Rectangle
		{
			return _viewPort;
		}
		
		public function set viewPort(value:Rectangle):void
		{
			_viewPort = value;
		}
		
		public function get textureFlag():Boolean
		{
			return _textureFlag;
		}
		
		public function set textureFlag(value:Boolean):void
		{
			_textureFlag = value;
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
		
		public function get program():Program
		{
			return _program;
		}
		
		public function set program(value:Program):void
		{
			_program = value;
		}
		
		public function get root():GameObject
		{
			return _root;
		}
		
		public function set root(value:GameObject):void
		{
			_root = value;
		}
		
		public function get context():Context3D
		{
			return _context;
		}
		
		public function set context(value:Context3D):void
		{
			_context = value;
		}
	}
}