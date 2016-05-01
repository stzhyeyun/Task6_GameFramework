package trolling.object
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import trolling.component.Component;
	import trolling.component.ComponentType;
	import trolling.component.DisplayComponent;
	import trolling.component.animation.Animator;
	import trolling.rendering.Painter;
	import trolling.rendering.TriangleData;
	import trolling.utils.PivotType;
	
	public class GameObject extends EventDispatcher
	{	
		private const TAG:String = "[GameObject]";
		private const NONE:String = "none";
		
		private var _parent:GameObject = null;
		private var _depth:Number;
		
		private var _components:Dictionary;
		private var _children:Vector.<GameObject> = new Vector.<GameObject>();
		
		private var _x:Number;
		private var _y:Number;
		private var _pivot:String;
		private var _width:Number;
		private var _height:Number;
		private var _scaleX:Number;
		private var _scaleY:Number;
		
		public function GameObject()
		{
			this.addEventListener(Event.ENTER_FRAME, nextFrame);
			_x = _y = _width = _height = 0.0;
			_pivot = PivotType.TOP_LEFT;
			_scaleX = _scaleY = 1;
			_components = new Dictionary();
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
			component.parent = this;
			_components[component.type] = component;
			
			if (component is DisplayComponent)
			{
				if(DisplayComponent(component).getRenderingResource() != null)
				{
					var compare:Rectangle = new Rectangle(0, 0, DisplayComponent(component).getRenderingResource().width, DisplayComponent(component).getRenderingResource().height);
					setBound(compare);
				}
			}
		}
		
		public function dispose():void
		{
			
		}
		
		public function addChild(child:GameObject):void
		{
			if(_children == null)
				_children = new Vector.<GameObject>();
			_children.insertAt(_children.length, child);
			if(child != null)
				child.parent = this;
		}
		
		/**
		 *render함수 
		 * @param painter
		 * 
		 */		
		public function render(painter:Painter):void
		{	
			var numChildren:int = _children.length;
			var componentType:String = decideRenderingComponent();
			
			if(componentType != NONE)
			{
				painter.pushState();
				
				var displayComponent:DisplayComponent = DisplayComponent(_components[componentType]);
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
				painter.context.setTextureAt(0, displayComponent.getRenderingResource().nativeTexture);
				triangleData.uvData[0] = displayComponent.getRenderingResource().u;
				triangleData.uvData[1] = displayComponent.getRenderingResource().v;
				
				painter.appendMatrix(matrix);
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
		
		/**
		 *클릭된 좌표의 가장 위쪽에 있는 객체를 찾아냅니다. 
		 * @param point
		 * @return 
		 * 
		 */		
		public function findClickedGameObject(point:Point):GameObject
		{			
			var target:GameObject = this;
			for(var i:int = _children.length-1; i >= 0; i--)
			{
				if(_children[i].getBound().containsPoint(point))
				{
					target = _children[i].findClickedGameObject(point);
					break;
				}
			}
			return target;
		}
		
		/**
		 *객체의 x,y,width,height값을 받아옵니다. 
		 * @return 
		 * 
		 */		
		public function getRectangle():Rectangle
		{
			var rectangle:Rectangle = new Rectangle(_x, _y, width, height);
			return rectangle;
		}
		
		/**
		 *매프레임마다 EnterFarme이벤트를 모든 자식 객체에게 전해줍니다. 
		 * @param event
		 * 
		 */		
		private function nextFrame(event:Event):void
		{
			if(_children)
			{
				for(var i:int = 0; i < _children.length; i++)
					_children[i].dispatchEvent(event);
			}
			if(_components)
			{
				for(var key:String in _components)
					Component(_components[key]).dispatchEvent(event);
			}
		}
		
		/**
		 *Object의 크기보다 큰 이미지가 들어오면 크기를 자동으론 늘려줍니다.
		 * @param compare
		 * 
		 */		
		private function setBound(compare:Rectangle):void
		{
			var nativeBound:Rectangle = getRectangle();
			if(nativeBound.width < (compare.x+compare.width))
				_width = compare.x+compare.width;
			if(nativeBound.height < (compare.y+compare.height))
				_height = compare.y+compare.height;
		}
		
		/**
		 *객체가 전체좌표에서 가지는 x,y값을 구합니다. 
		 * @return 
		 * 
		 */		
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
			
			if(_pivot == PivotType.CENTER)
			{
				globalPoint.x -= width/2;
				globalPoint.y -= height/2;
			}
			
			return globalPoint;
		}
		
		/**
		 *Object와 Children까지 모두 합하여 범위를 구합니다.
		 * @return 
		 * 
		 */		
		public function getBound():Rectangle
		{
			var bound:Rectangle = getGlobalRect();
			
			var numChildren:int = _children.length;
			
			for(var i:int = 0; i < numChildren; i++)
			{
				var childBound:Rectangle = _children[i].getBound();
				if(childBound.topLeft.x < bound.topLeft.x)
					bound.x = childBound.x;
				if(childBound.topLeft.y < bound.topLeft.y)
					bound.y = childBound.y;
				if(childBound.bottomRight.x > bound.bottomRight.x)
					bound.width += (childBound.bottomRight.x-bound.bottomRight.x);
				if(childBound.bottomRight.y > bound.bottomRight.y)
					bound.height += (childBound.bottomRight.y-bound.bottomRight.y);
			}
			
			return bound;
		}
		
		public function getGlobalRect():Rectangle
		{
			var rect:Rectangle = new Rectangle();
			rect.topLeft = getGlobalPoint();
			rect.width = width;
			rect.height = height;
			
			return rect;
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
			return _height * _scaleY;
		}
		
		public function set height(value:Number):void
		{
			_height = value;
		}
		
		public function get width():Number
		{
			return _width * _scaleX;
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
		
		public function get scaleY():Number
		{
			return _scaleY;
		}
		
		public function set scaleY(value:Number):void
		{
			_scaleY = value;
		}
		
		public function get scaleX():Number
		{
			return _scaleX;
		}
		
		public function set scaleX(value:Number):void
		{
			_scaleX = value;
		}
		
		public function get pivot():String
		{
			return _pivot;
		}
		
		public function set pivot(value:String):void
		{
			if(value != PivotType.CENTER && value != PivotType.TOP_LEFT)
				return;
			_pivot = value;
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
		
		public function transition(nextStateName:String):void // [혜윤] 애니메이터에게 지정 상태로 전이하도록 합니다.
		{
			if (!_components || !_components[ComponentType.ANIMATOR])
			{
				return;
			}
			
			var animator:Animator = _components[ComponentType.ANIMATOR];
			animator.transition(nextStateName);
		}
	}
}