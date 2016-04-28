package trolling.object
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display3D.Context3DCompareMode;
	import flash.events.EventDispatcher;
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import trolling.component.Component;
	import trolling.component.ComponentType;
	import trolling.component.graphic.Image;
	import trolling.rendering.Painter;
	import trolling.rendering.Texture;
	import trolling.rendering.TriangleData;
	
	
	public class GameObject extends EventDispatcher
	{	
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
		
		public function GameObject()
		{
			_x = _y = _pivotX = _pivotY = _width = _height = 0.0;
			_components = new Dictionary();
		}
		
//		public function setTestBitmap():void
//		{
//			_bitmap = new TextureBitmap();
//		}
		
		public function addComponent(property:Component):void
		{
			_components[property.type] = property;
			property.isActive = true;
			property.parent = this;
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
			var numChildren:int = _children.length;
			
			if(_components[ComponentType.IMAGE] != null)
			{
				var triangleData:TriangleData = new TriangleData();
				
				var drawRect:Rectangle = getRectangle();
				var globalPoint:Point = getGlobalPoint();
				
				drawRect.x = globalPoint.x;
				drawRect.y = globalPoint.y;
				
				drawRect.x = (drawRect.x - (painter.viewPort.width/2)) / (painter.viewPort.width/2);
				drawRect.y = ((painter.viewPort.height/2) - drawRect.y) / (painter.viewPort.height/2);
				
				drawRect.width = drawRect.width / painter.viewPort.width;
				drawRect.height = drawRect.height / painter.viewPort.height;
				
				var matrix:Matrix3D = new Matrix3D();
				matrix.identity();
				matrix.appendScale(drawRect.width, drawRect.height, 1);
				matrix.appendTranslation(drawRect.x+drawRect.width, drawRect.y-drawRect.height, 0);
				
			//	painter.context.setDepthTest(false, Context3DCompareMode.ALWAYS);
			//	_texture = new Texture(_bitmap);
				trace(_components[ComponentType.IMAGE])
				_texture = Image(_components[ComponentType.IMAGE]).getRenderingResource();
				painter.context.setTextureAt(0, _texture.nativeTexture);
				triangleData.uvData[0] = _texture.u;
				triangleData.uvData[1] = _texture.v;
				
				
				painter.pushState();
				
				painter.appendMatrix(matrix);  
		//		painter.setUVVector(triangleData);
				painter.setDrawData(triangleData);
				painter.draw();
				
				painter.popState();
			}
			
			for(var i:int = 0; i < numChildren; i++)
			{
				var child:GameObject = _children[i];
				child.render(painter);
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