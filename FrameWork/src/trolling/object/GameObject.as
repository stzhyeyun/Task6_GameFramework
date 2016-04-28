package trolling.object
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.EventDispatcher;
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import trolling.component.Component;
	import trolling.rendering.Painter;
	import trolling.rendering.Texture;
	import trolling.rendering.TriangleData;
	
	
	public class GameObject extends EventDispatcher
	{
		[Embed( source = "iu3.jpg" )]
		protected const TextureBitmap:Class;
		
		private var _parent:GameObject = null;
		private var _depth:Number;
		
		private var _components:Dictionary;
		private var _children:Vector.<GameObject> = new Vector.<GameObject>();
		
		private var _x:Number;
		private var _y:Number;
		private var _pivotX:Number;
		private var _pivotY:Number;
		private var _width:Number;
		private var _height:Number;
		
		private var _color:uint;
		private var _bitmapData:BitmapData;
		
		private var _bitmap:Bitmap;
		private var _texture:Texture;
		
		private var _triangleData:TriangleData;
		
		public function GameObject()
		{
			_x = _y = _pivotX = _pivotY = _width = _height = 0.0;
			_components = new Dictionary();
			_triangleData = new TriangleData();
		}
		
		public function setColor(color:uint):void
		{
			_color = color;
//			_bitmapData = new BitmapData(_width, _height, false, _color);
			_bitmap = new TextureBitmap();
		}
		
		public function addComponent(property:Component):void
		{
			if(_components[property.type] == null)
				_components[property.type] = new Vector.<Component>();
			
			_components[property.type].insertAt(_components[property.type].length, property);
		}
		
		public function addChild(child:GameObject):void
		{
			if(_children == null)
				_children = new Vector.<GameObject>();
			_children.insertAt(_children.length, child);
			if(child != null)
				child.parent = this;
		}
		
		public function render(painter:Painter):void
		{	
			_depth = 0;
			var numChildren:int = _children.length;
			
			for(var i:int = numChildren-1; i >= 0; i--)
			{
				var child:GameObject = _children[i];
				child.render(painter);
			}
			_triangleData.initArray();
			
	//		trace("numChildren = " + numChildren);
			var drawRect:Rectangle = getRectangle();
			var globalPoint:Point = getGlobalPoint();
			
			drawRect.x = globalPoint.x;
			drawRect.y = globalPoint.y;
			
			drawRect.x = (drawRect.x - (painter.viewPort.width/2)) / (painter.viewPort.width/2);
			drawRect.y = ((painter.viewPort.height/2) - drawRect.y) / (painter.viewPort.height/2);
			
			drawRect.width = drawRect.width / painter.viewPort.width;
			drawRect.height = drawRect.height / painter.viewPort.height;
	//		trace("drawRect =" + drawRect);
			
			var matrix:Matrix3D = new Matrix3D();
			matrix.identity();
			matrix.appendScale(drawRect.width, drawRect.height, 1);
			matrix.appendTranslation(drawRect.x+drawRect.width, drawRect.y-drawRect.height, 0);
			
			var triangleIndex:Vector.<uint> = new Vector.<uint>();
			
			var triangleStartIndex:uint = _triangleData.vertexData.length;
			
			if(painter.root != this)
			{
//				trace("_width , _height = " + _width + ", " + _height);
				_texture = new Texture(_bitmap);
				painter.context.setTextureAt(0, _texture.nativeTexture);
				_triangleData.uvData[0] = _texture.u;
				_triangleData.uvData[1] = _texture.v;
				
//				_triangleData.vertexData.push(Vector.<Number>([drawRect.x+drawRect.width, drawRect.y, 0, 1, 0]));
//				_triangleData.vertexData.push(Vector.<Number>([drawRect.x+drawRect.width, drawRect.y-drawRect.height, 0, 1, 1]));
//				_triangleData.vertexData.push(Vector.<Number>([drawRect.x, drawRect.y-drawRect.height, 0, 0, 1]));
//				_triangleData.vertexData.push(Vector.<Number>([drawRect.x, drawRect.y, 0, 0, 0]));
				
				_triangleData.vertexData.push(Vector.<Number>([1, 1, 0, 1, 0]));
				_triangleData.vertexData.push(Vector.<Number>([1, -1, 0, 1, 1]));
				_triangleData.vertexData.push(Vector.<Number>([-1, -1, 0, 0, 1]));
				_triangleData.vertexData.push(Vector.<Number>([-1, 1, 0, 0, 0]));
				
				triangleIndex.push(triangleStartIndex);
				triangleIndex.push(triangleStartIndex+1);
				triangleIndex.push(triangleStartIndex+2);
				_triangleData.indexData.push(triangleIndex);
				
				triangleIndex = new Vector.<uint>();
				triangleIndex.push(triangleStartIndex+2);
				triangleIndex.push(triangleStartIndex+3);
				triangleIndex.push(triangleStartIndex);
				_triangleData.indexData.push(triangleIndex);
				
				_triangleData.calculData();
				
				painter.appendMatrix(matrix);
				painter.setDrawData(_triangleData);
				
				painter.draw();
			}
		}
		
		public function getGlobalPoint():Point
		{
			var globalPoint:Point = new Point(_x, _y);
			
			var searchObject:GameObject = this;
			while(searchObject.parent != null)
			{
				globalPoint.x += searchObject.parent.x;
				globalPoint.y += searchObject.parent.y;
				
				searchObject = searchObject.parent;
			}
			
//			trace(globalPoint);
			return globalPoint;
		}
		
		public function findClickedGameObject(point:Point):GameObject
		{			
			if(!getRectangle().containsPoint(point))
			{
				trace("빈공간");
				return null;
			}
			
			var target:GameObject = hitTest(point);			
			
			return target ? target : this; 
		}
		
		public function hitTest(point:Point):GameObject
		{
			var target:GameObject = null;
			for (var i:int = _children.length - 1; i >= 0; --i)
			{
				var child:GameObject = _children[i];
				target = child.findClickedGameObject(point);
				
				if (target)
				{
					return target;
				}
			}
			return null;
		}
		
		public function getRectangle():Rectangle
		{
			var rectangle:Rectangle = new Rectangle(_x, _y, _width, _height);
			return rectangle;
		}
		
		public function get parent():GameObject
		{
			return _parent;
		}
		
		public function set parent(value:GameObject):void
		{
			_parent = value;
		}
		
		public function get height():Number
		{
			return _height;
		}
		
		public function set height(value:Number):void
		{
			_height = value;
		}
		
		public function get width():Number
		{
			return _width;
		}
		
		public function set width(value:Number):void
		{
			_width = value;
		}
		
		public function get y():Number
		{
			return _y;
		}
		
		public function set y(value:Number):void
		{
			_y = value;
		}
		
		public function get x():Number
		{
			return _x;
		}
		
		public function set x(value:Number):void
		{
			_x = value;
		}
	}
}