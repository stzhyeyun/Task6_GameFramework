package trolling.object
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;
	
	import trolling.component.Component;
	import trolling.component.ComponentType;
	import trolling.component.DisplayComponent;
	import trolling.component.animation.Animator;
	import trolling.core.Trolling;
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
		
		private var _rotate:Number;
		
		private var _visable:Boolean;
		
		public function GameObject()
		{
			this.addEventListener(Event.ENTER_FRAME, nextFrame);
			_x = _y = _width = _height = _rotate = 0.0;
			_pivot = PivotType.TOP_LEFT;
			_scaleX = _scaleY = 1;
			_components = new Dictionary();
			_visable = true;
		}
		
		public function get visable():Boolean
		{
			return _visable;
		}
		
		public function set visable(value:Boolean):void
		{
			_visable = value;
			
			for(var componentType:String in _components)
			{
				var component:Component = _components[componentType];
				component.isActive = value;
			}
		}
		
		public function get rotate():Number
		{
			return _rotate;
		}
		
		public function set rotate(value:Number):void
		{
			_rotate = value;
		}
		
		/**
		 *컴포넌트를 추가시켜주는 함수
		 * 추가시킬 컴포넌트를 인자로 받습니다. 
		 * @param component
		 * 
		 */		
		public function addComponent(component:Component):void
		{
			if(_components && _components[component.type])
			{
				trace(TAG + " addComponent : GameObject already has the component of this type.");
				return;
			}
			if(component.parent != null)
				component.parent.removeComponent(component.type);
			
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
		
		/**
		 *컴포넌트를 삭제하는 함수
		 * 삭제시킬 컴포넌트의 타입을 인자로 받고
		 * 해당 타입의 컴포넌트가 있을경우 삭제시켜줍니다.
		 * @param componentType
		 * 
		 */		
		public function removeComponent(componentType:String):void
		{
			if(_components[componentType] == null)
				return;
			//			if(!(_components in component))
			//				return;
			_components[componentType].parent = null;
			_components[componentType] = null;
		}
		
		/**
		 *자식을 추가시키는 함수
		 * GameObject를 인자로 받으며 오브젝트간에 트리구조를 형성할 수 있습니다. 
		 * @param child
		 * 
		 */		
		public function addChild(child:GameObject):void
		{
			if(child == null)
				return;
			if(child.parent != null)
				child.parent.removeChild(child);
			_children.insertAt(_children.length, child);
			child.parent = this;
		}
		
		/**
		 *원하는 순서로 자식오브젝트를 추가시키기위한 함수입니다. 
		 * @param child
		 * @param index
		 * 
		 */		
		public function addChildAt(child:GameObject, index:uint):void
		{
			if(child == null)
				return;
			if(_children.length < index)
				return;
			if(child.parent != null)
				child.parent.removeChild(child);
			_children.insertAt(index, child);
			child.parent = this;
		}
		
		/**
		 *자식오브젝트를 하나 제거합니다. 
		 * @param index
		 * 
		 */		
		public function removeChildAt(index:uint):void
		{
			if(index >= _children.length)
				return;
			_children[index].parent = null;
			_children.removeAt(index);
		}
		
		/**
		 *현제 오브젝트를 부모오브젝트로부터 삭제합니다. 
		 * 
		 */		
		public function removeFromParent():void
		{
			_parent.removeChild(this);
		}
		
		/**
		 *현제오브젝트가 가지고있는 모든 자식오브젝트를 삭제합니다. 
		 * 
		 */		
		public function removeChildren():void
		{
			if(_children.length <= 0)
				return;
			for(var i:int = _children.length-1; i >= 0; i--)
			{
				removeChild(_children[i]);
			}
		}
		
		/**
		 *자식오브젝트를 하나 제거합니다. 
		 * @param child
		 * 
		 */		
		public function removeChild(child:GameObject):void
		{
			if(_children.indexOf(child) < 0)
				return;
			_children.removeAt(_children.indexOf(child));
			child.parent = null;
		}
		
		/**
		 *현재오브젝트를 정지합니다. 
		 * 
		 */		
		public function dispose():void
		{
			this.removeEventListener(Event.ENTER_FRAME, nextFrame);
			for(var componentType:String in _components)
			{
				var component:Component = _components[componentType];
				component.dispose();
			}
			if(_children)
			{
				for(var i:int = 0; i < _children.length; i++)
				{
					_children[i].dispose();
				}
			}
			this.removeFromParent();
		}
		
		/**
		 *render함수 
		 * @param painter
		 * 
		 */		
		public function render(painter:Painter):void
		{	
			if(!_visable)
				return;
			var numChildren:int = _children.length;
			var componentType:String = decideRenderingComponent();
			painter.pushState();
			if(this == Trolling.current.currentScene)
				painter.matrix.appendTranslation(-1, 1, 0);
			painter.pushState();
			if(this != Trolling.current.currentScene)
			{	
				var displayComponent:DisplayComponent = DisplayComponent(_components[componentType]);
				var triangleData:TriangleData = new TriangleData();
				
				var drawRect:Rectangle = getRectangle();
				
				drawRect.x = _x;
				drawRect.y = _y;
				
				drawRect.x = (drawRect.x*2) / (painter.viewPort.width);
				drawRect.y = (drawRect.y*2) / (painter.viewPort.height);
				
				drawRect.width = drawRect.width*2 / painter.viewPort.width;
				drawRect.height = drawRect.height*2 / painter.viewPort.height;
				
				if(_pivot == PivotType.CENTER)
				{
					drawRect.x -= (drawRect.width/2);
					drawRect.y -= (drawRect.height/2);
				}
				
				//				triangleData.vertexData.push(Vector.<Number>([drawRect.width/2, drawRect.height/2, 0, 1, 0]));
				//				triangleData.vertexData.push(Vector.<Number>([drawRect.width/2, -drawRect.height/2, 0, 1, 1]));
				//				triangleData.vertexData.push(Vector.<Number>([-drawRect.width/2, -drawRect.height/2, 0, 0, 1]));
				//				triangleData.vertexData.push(Vector.<Number>([-drawRect.width/2, drawRect.height/2, 0, 0, 0]));
				
				triangleData.vertexData.push(Vector.<Number>([drawRect.width, 0, 0, 1, 0]));
				triangleData.vertexData.push(Vector.<Number>([drawRect.width, -drawRect.height, 0, 1, 1]));
				triangleData.vertexData.push(Vector.<Number>([0, -drawRect.height, 0, 0, 1]));
				triangleData.vertexData.push(Vector.<Number>([0, 0, 0, 0, 0]));
				
				triangleData.calculVertex();
				
				painter.matrix.prependTranslation(drawRect.x, -drawRect.y, 0);
				painter.matrix.prependTranslation(drawRect.width/2, -drawRect.height/2, 0);
				painter.matrix.prependRotation(_rotate, Vector3D.Z_AXIS);
				painter.matrix.prependTranslation(-drawRect.width/2, drawRect.height/2, 0);
				
				if(componentType != NONE)
				{
					painter.context.setTextureAt(0, displayComponent.getRenderingResource().nativeTexture);
					triangleData.uvData[0] = displayComponent.getRenderingResource().u;
					triangleData.uvData[1] = displayComponent.getRenderingResource().v;
				}
				
				
				painter.setDrawData(triangleData);
				if(componentType != NONE)
					painter.draw();
			}
			
			for(var i:int = 0; i < numChildren; i++)
			{
				var child:GameObject = _children[i];
				child.render(painter);
			}
			painter.popState();
			painter.popState();
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
			var rectangle:Rectangle = new Rectangle(_x, _y, getWidth(), getHeight());
			return rectangle;
		}
		
		/**
		 *매프레임마다 EnterFarme이벤트를 모든 자식 객체에게 전해줍니다. 
		 * @param event
		 * 
		 */		
		private function nextFrame(event:Event):void
		{
			for(var key:String in _components)
			{
				if(_components[key] != null)
					Component(_components[key]).dispatchEvent(event);
			}
			
			if(_children)
			{
				for(var i:int = 0; i < _children.length; i++)
					_children[i].dispatchEvent(event);
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
			var globalPoint:Point = getPivotPoint();
			
			//			if(_pivot == PivotType.CENTER)
			//			{
			//				globalPoint.x -= (getWidth())/2;
			//				globalPoint.y -= (getHeight())/2;
			//			}
			
			if(_parent != null)
			{
				globalPoint.x += _parent.getGlobalPoint().x;
				globalPoint.y += _parent.getGlobalPoint().y;
			}
			
			return globalPoint;
		}
		
		private function getPivotPoint():Point
		{
			var pivot:Point = new Point(_x, _y);
			if(_pivot == PivotType.CENTER)
			{
				pivot.x -= (getWidth()/2);
				pivot.y -= (getHeight()/2);
			}
			return pivot;
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
		
		/**
		 *전체좌표계에서 이 오브젝트가 차지하는 사각형을 구할 수 있습니다. 
		 * @return 
		 * 
		 */		
		public function getGlobalRect():Rectangle
		{
			var rect:Rectangle = new Rectangle();
			rect.topLeft = getGlobalPoint();
			rect.width = getWidth();
			rect.height = getHeight();
			
			return rect;
		}
		
		private function getWidth():Number
		{
			return _width * _scaleX;
		}
		
		private function getHeight():Number
		{
			return _height * _scaleY;
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