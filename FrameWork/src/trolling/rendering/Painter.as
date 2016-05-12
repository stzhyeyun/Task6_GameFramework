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
	
	import trolling.core.Trolling;
	
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
		private var _alpha:Number = 1.0;
		private var _red:Number = 1.0;
		private var _green:Number = 1.0;
		private var _blue:Number = 1.0;
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
			state.alpha = _alpha;
			state.red = _red;
			state.green = _green;
			state.blue = _blue;
			_stateStack.push(state);
		}
		
		public function popState():void
		{
			var state:RenderState = _stateStack.pop();
			_matrix = state.matrix.clone();
			_alpha = state.alpha;
			_red = state.red;
			_green = state.green;
			_blue = state.blue;
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
			createIndexBuffer();
			_context.setDepthTest(true, Context3DCompareMode.ALWAYS);
			_context.setBlendFactors(
				Context3DBlendFactor.SOURCE_ALPHA,
				Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA
			);
			_moleCallBack(_context);
			//_context.set
		}
		
		public function configureBackBuffer(stageRectangle:Rectangle, antiAlias:Boolean = true):void
		{
			_stage3D.x = stageRectangle.x;
			_stage3D.y = stageRectangle.y;
			
			_viewPort = Trolling.current.viewPort;
			
			var alias:int;
			if(antiAlias)
				alias = 1;
			else
				alias = 0;
			
			trace(stageRectangle.width + ", " + stageRectangle.height);
			_context.configureBackBuffer(stageRectangle.width, stageRectangle.height, alias, true);
			//_context.setCulling(Context3DTriangleFace.BACK);
			
			_backBufferWidth = stageRectangle.width;
			_backBufferHeight = stageRectangle.height;
		}
		
		public function setDrawData(triangleData:TriangleData):void
		{
			createVertexBuffer(triangleData);
			setVertextBuffer();
			setUVVector(triangleData);
			//_matrix.appendRotation(90, Z_AXIS);
			//_matrix.appendTranslation(0, -0.5, 0);
			_context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, _matrix, true);
			_context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, new <Number>[_red, _green, _blue, _alpha], 1);    // fc0
		}
		
		public function present():void
		{
			_context.present();	
		}
		
		public function draw():void
		{
			Trolling.current.drawCall++;
			_context.drawTriangles(_indexBuffer);
		}
		
		public function setUVVector(triagleData:TriangleData):void
		{
			_context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 4, triagleData.uvData);
		}
		
		private function createVertexBuffer(triangleData:TriangleData):void
		{
			_vertexBuffer = _context.createVertexBuffer(4, 5);
			_vertexBuffer.uploadFromVector(triangleData.rawVertexData, 0, 4);
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
		
		public function get alpha():Number
		{
			return _alpha;
		}
		
		public function set alpha(value:Number):void
		{
			_alpha = value;
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
	}
}