package trolling.rendering 
{
	import flash.display.Stage3D;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.VertexBuffer3D;
	import flash.events.Event;
	import flash.geom.Matrix3D;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	
	public class Painter
	{	
		private static const X_AXIS:Vector3D = Vector3D.X_AXIS;
		private static const Y_AXIS:Vector3D = Vector3D.Y_AXIS;
		private static const Z_AXIS:Vector3D = Vector3D.Z_AXIS;
		
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
		
		public function pushState():void
		{
			var state:RenderState = new RenderState();
			state.matrix = _matrix.clone();
			_stateStack.push(state);
		}
		
		public function popState():void
		{
			var state:RenderState = _stateStack.pop();
			_matrix = state.matrix.clone();
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
			_program.initProgram(_context);
			setProgram();
			createVertexBuffer();
			createIndexBuffer();
			setVertextBuffer();
			_context.setDepthTest(true, Context3DCompareMode.ALWAYS);
			_context.setBlendFactors(
				Context3DBlendFactor.SOURCE_ALPHA,
				Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA
			);
			_moleCallBack(_context);
			//	_context.set
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
			//	_context.setCulling(Context3DTriangleFace.BACK);
			
			_backBufferWidth = viewPort.width;
			_backBufferHeight = viewPort.height;
		}
		
		public function setDrawData(triangleData:TriangleData):void
		{
			setUVVector(triangleData);
			_matrix.appendRotation(0, X_AXIS);
			//	_matrix.appendTranslation(0, -0.5, 0);
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
			_matrix.append(matrix);
		}
		
		public function setUVVector(triagleData:TriangleData):void
		{
			_context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 4, triagleData.uvData);
		}
		
		private function createVertexBuffer():void
		{
			_vertexBuffer = _context.createVertexBuffer(4, 5);
			_vertexBuffer.uploadFromVector(TriangleData.rawVertexData, 0, 4);
		}
		
		private function createIndexBuffer():void
		{
			_indexBuffer = _context.createIndexBuffer(TriangleData.rawIndexData.length);
			_indexBuffer.uploadFromVector(TriangleData.rawIndexData, 0, TriangleData.rawIndexData.length);
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