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
<<<<<<< HEAD
	import trolling.component.ComponentType;
	import trolling.component.DisplayComponent;
=======
>>>>>>> 73a7a9025732479366c36ed15af53a6a223f2d83
	import trolling.rendering.Painter;
	import trolling.rendering.Texture;
	import trolling.rendering.TriangleData;
<<<<<<< HEAD
	import trolling.utils.TextureUtil;
	
	public class GameObject extends EventDispatcher
	{
		private const TAG:String = "[GameObject]";
		private const NONE:String = "none";
=======
	
	
	public class GameObject extends EventDispatcher
	{
		[Embed( source = "iu3.jpg" )]
		protected const TextureBitmap:Class;
>>>>>>> 73a7a9025732479366c36ed15af53a6a223f2d83
		
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
		
		public function addComponent(component:Component):void
		{
			if(_components && _components[component.type])
			{
				trace(TAG + " addComponent : GameObject already has the component of this type.");
				return;
			}
			
			if (!_components)
			{
				_components = new Dictionary();
			}
			_components[component.type] = component;
		}
		
		public function removeComponent(componentType:String):void
		{
			if (!_components || !_components[componentType])
			{
				return;
			}
			
			var component:Component = _components[componentType];
			component.dispose();
			component = null;
			delete _components[componentType];
		}
		
		public function getComponent(componentType:String):Component
		{
			if (!_components || !_components[componentType])
			{
				return null;
			}
			
			return _components[componentType];
		}
		
		public function setComponent(component:Component):void
		{
			// to do
			
			
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
			if (!_children && !_components) // [혜윤] Render 대상이 없으면 함수 종료
			{
				return;
			}
			
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
			
			var renderingComponentType:String = decideRenderingComponent(); // [혜윤] Render할 컴포넌트 확인 및 결정
			if(painter.root != this && renderingComponentType != NONE)
			{
<<<<<<< HEAD
				trace("_width , _height = " + _width + ", " + _height);
//				if(_bitmapData != null)
//					trace("얍얍");
//				_texture = TextureUtil.fromBitmap(new Bitmap(_bitmapData)); // [혜윤] Component 그리기 테스트를 위해 주석 처리
				
				//
				var displayComponent:DisplayComponent = _components[renderingComponentType];
				var texture:Texture = displayComponent.getRenderingResource();
				if (!texture)
				{
					trace(TAG + " render : No Texture(Component).");
					return;					
				}
				//
				
				painter.context.setTextureAt(0, texture);
=======
//				trace("_width , _height = " + _width + ", " + _height);
				_texture = new Texture(_bitmap);
				painter.context.setTextureAt(0, _texture.nativeTexture);
				_triangleData.uvData[0] = _texture.u;
				_triangleData.uvData[1] = _texture.v;
>>>>>>> 73a7a9025732479366c36ed15af53a6a223f2d83
				
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
		
		private function decideRenderingComponent():String
		{
			// 컴포넌트가 없음
			if (!_components)
			{
				return NONE;
			}
			// Image만 있음
			else if (_components[ComponentType.IMAGE] && !_components[ComponentType.ANIMATOR])
			{
				var image:Component = _components[ComponentType.IMAGE];
				
				if (image.isActive)
				{
					return ComponentType.IMAGE;
				}
				else
				{
					return NONE;
				}
			}
			// Animator만 있음
			else if (!_components[ComponentType.IMAGE] && _components[ComponentType.ANIMATOR])
			{
				var animator:Component = _components[ComponentType.ANIMATOR];
				
				if (animator.isActive)
				{
					return ComponentType.ANIMATOR;
				}
				else
				{
					return NONE;
				}
			}
			// Image와 Animator 둘 다 있음
			else if (_components[ComponentType.IMAGE] && _components[ComponentType.ANIMATOR])
			{
				var image:Component = _components[ComponentType.IMAGE];
				var animator:Component = _components[ComponentType.ANIMATOR];
				
				if (image.isActive && !animator.isActive)
				{
					return ComponentType.IMAGE;
				}
				else if (!image.isActive && animator.isActive)
				{
					return ComponentType.ANIMATOR;
				}
				else if (image.isActive && animator.isActive)
				{
					return ComponentType.ANIMATOR; // Animator를 우선하여 그림
				}
				else
				{
					return NONE;
				}
			}
			// 컴포넌트가 없음
			else
			{
				return NONE;
			}
		}
	}
}