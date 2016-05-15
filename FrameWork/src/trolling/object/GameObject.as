package trolling.object
{
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.Texture;
	import flash.events.EventDispatcher;
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;
	
	import trolling.component.Component;
	import trolling.component.ComponentType;
	import trolling.component.DisplayComponent;
	import trolling.component.animation.Animator;
	import trolling.component.physics.Collider;
	import trolling.core.Disposer;
	import trolling.core.Trolling;
	import trolling.event.TrollingEvent;
	import trolling.rendering.BatchData;
	import trolling.rendering.Painter;
	import trolling.rendering.TriangleData;
	import trolling.utils.Circle;
	import trolling.utils.Color;
	import trolling.utils.PivotType;
	
	
	public class GameObject extends EventDispatcher
	{	
		//change
		private const TAG:String = "[GameObject]";
		private const NONE:String = "none";
		
		private var _tag:String;
		
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
		private var _name:String;
		private var _alpha:Number;
		
		private var _red:Number;
		private var _green:Number;
		private var _blue:Number;
		
		private var _active:Boolean;
		private var _visible:Boolean;
		private var _colliderRender:Boolean;
		
		public function GameObject()
		{
			this.addEventListener(TrollingEvent.ENTER_FRAME, onThrowEvent);
			this.addEventListener(TrollingEvent.END_SCENE, onThrowEvent);
			this.addEventListener(TrollingEvent.START_SCENE, onThrowEvent);
			_x = _y = _width = _height = _rotate = 0.0;
			_pivot = PivotType.TOP_LEFT;
			_scaleX = _scaleY = _alpha = _red = _green = _blue = 1;
			_components = new Dictionary();
			_active = true;
			_visible = true;
			_tag = null;
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
				trace(_components);
				trace(_components[component.type]);
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
			
			var component:Component = _components[componentType];
			component.dispose();
			
			delete _components[componentType];
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
		
		public function getChild(index:int):GameObject
		{
			if (!_children)
			{
				trace(TAG + " getChild : No children."); 
				return null;
			}
			
			if (index >= 0 && index < _children.length)
			{
				return _children[index];
			}
			else
			{
				trace(TAG + " getChild : Invalid index.");
				return null;
			}
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
			if(_parent == null)
				return;
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
			this.removeEventListener(TrollingEvent.ENTER_FRAME, onThrowEvent);
			this.removeEventListener(TrollingEvent.END_SCENE, onThrowEvent);
			this.removeEventListener(TrollingEvent.START_SCENE, onThrowEvent);
			
			Disposer.requestDisposal(this);
			
			if(_children)
			{
				for(var i:int = 0; i < _children.length; i++)
				{
					_children[i].dispose();
				}
			}
			
			if (_components)
			{
				for (var key:String in _components)
				{
					var component:Component = _components[key];
					component.dispose();
				}
			}
		}
		
		/**
		 *render함수 
		 * @param painter
		 * 
		 */		
		public function setRenderData(painter:Painter, atalasData:TriangleData = null):void
		{	
			if(!_visible)
				return;
			var numChildren:int = _children.length;
			var componentType:String = decideRenderingComponent();
			var triangleData:TriangleData;
			var textureRect:Rectangle = new Rectangle(0, 0, 1, 1);
			
			painter.pushState();
			if(this == Trolling.current.currentScene)
			{
				painter.matrix.appendTranslation(-1, 1, 0);
				painter.matrix.prependScale(_scaleX, _scaleY, 1);
			}
			else
			{	
				var displayComponent:DisplayComponent = DisplayComponent(_components[componentType]);
				if(atalasData == null)
					triangleData = new TriangleData();
				else
					triangleData = atalasData;
				
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
				
				if(_pivot == PivotType.TOP_LEFT)
				{
					painter.matrix.prependTranslation((drawRect.x), -(drawRect.y), 0);
					painter.matrix.prependRotation(_rotate, Vector3D.Z_AXIS);
					painter.matrix.prependScale(_scaleX, _scaleY, 1);
				}
				else
				{
					painter.matrix.prependTranslation((drawRect.x+(drawRect.width/2)), -(drawRect.y+(drawRect.height/2)), 0);
					painter.matrix.prependRotation(_rotate, Vector3D.Z_AXIS);
					painter.matrix.prependScale(_scaleX, _scaleY, 1);
				}
				
				if(componentType != NONE && displayComponent.getRenderingResource() != null)
				{
					textureRect.x = displayComponent.getRenderingResource().ux;
					textureRect.y = displayComponent.getRenderingResource().vy;
					textureRect.width = displayComponent.getRenderingResource().u;
					textureRect.height = displayComponent.getRenderingResource().v;
					
					var matrixTemp:Matrix3D = painter.matrix.clone();
					
					if(_pivot == PivotType.TOP_LEFT)
					{
						matrixTemp.prependTranslation(drawRect.width, 0, 0);
						triangleData.rawVertexData = triangleData.rawVertexData.concat(Vector.<Number>([matrixTemp.position.x, matrixTemp.position.y, 0, textureRect.x+textureRect.width, textureRect.y, _red, _green, _blue, _alpha*painter.alpha]));
						matrixTemp.prependTranslation(-drawRect.width, 0, 0);
						
						matrixTemp.prependTranslation(drawRect.width, -drawRect.height, 0);
						triangleData.rawVertexData = triangleData.rawVertexData.concat(Vector.<Number>([matrixTemp.position.x, matrixTemp.position.y, 0, textureRect.x+textureRect.width, textureRect.y+textureRect.height,_red, _green, _blue, _alpha*painter.alpha]));
						matrixTemp.prependTranslation(-drawRect.width, drawRect.height, 0);
						
						matrixTemp.prependTranslation(0, -drawRect.height, 0);
						triangleData.rawVertexData = triangleData.rawVertexData.concat(Vector.<Number>([matrixTemp.position.x, matrixTemp.position.y, 0, textureRect.x, textureRect.y+textureRect.height, _red, _green, _blue, _alpha*painter.alpha]));
						matrixTemp.prependTranslation(0, drawRect.height, 0);
						
						matrixTemp.prependTranslation(0, 0, 0);
						triangleData.rawVertexData = triangleData.rawVertexData.concat(Vector.<Number>([matrixTemp.position.x, matrixTemp.position.y, 0, textureRect.x, textureRect.y, _red, _green, _blue, _alpha*painter.alpha]));
						matrixTemp.prependTranslation(0, 0, 0);						
					}
					else
					{
						matrixTemp.prependTranslation((drawRect.width/2), (drawRect.height/2), 0);
						triangleData.rawVertexData = triangleData.rawVertexData.concat(Vector.<Number>([matrixTemp.position.x, matrixTemp.position.y, 0, textureRect.x+textureRect.width, textureRect.y, _red, _green, _blue, _alpha*painter.alpha]));
						matrixTemp.prependTranslation(-(drawRect.width/2), -(drawRect.height/2), 0);
						
						matrixTemp.prependTranslation((drawRect.width/2), -(drawRect.height/2), 0);
						triangleData.rawVertexData = triangleData.rawVertexData.concat(Vector.<Number>([matrixTemp.position.x, matrixTemp.position.y, 0, textureRect.x+textureRect.width, textureRect.y+textureRect.height, _red, _green, _blue, _alpha*painter.alpha]));
						matrixTemp.prependTranslation(-(drawRect.width/2), (drawRect.height/2), 0);
						
						matrixTemp.prependTranslation(-(drawRect.width/2), -(drawRect.height/2), 0);
						triangleData.rawVertexData = triangleData.rawVertexData.concat(Vector.<Number>([matrixTemp.position.x, matrixTemp.position.y, 0, textureRect.x, textureRect.y+textureRect.height, _red, _green, _blue, _alpha*painter.alpha]));
						matrixTemp.prependTranslation((drawRect.width/2), (drawRect.height/2), 0);
						
						matrixTemp.prependTranslation(-(drawRect.width/2), (drawRect.height/2), 0);
						triangleData.rawVertexData = triangleData.rawVertexData.concat(Vector.<Number>([matrixTemp.position.x, matrixTemp.position.y, 0, textureRect.x, textureRect.y, _red, _green, _blue, _alpha*painter.alpha]));
						matrixTemp.prependTranslation((drawRect.width/2), -(drawRect.height/2), 0);
					}
					
					if(painter.currentBatchData == null || painter.currentBatchData.batchTexture != displayComponent.getRenderingResource().nativeTexture)
					{
						var batchData:BatchData = new BatchData();
						batchData.batchTexture = displayComponent.getRenderingResource().nativeTexture;
						painter.currentBatchData = batchData;
						painter.batchDatas.push(batchData);
					}
					painter.currentBatchData.batchTriangles.push(triangleData);
				}
				
				painter.alpha *= _alpha;
				
//				var coll:Collider = _components[ComponentType.COLLIDER];
//				if(coll != null && _colliderRender && coll.id != Collider.ID_NONE)
//				{	
//					var rect:Rectangle;
//					if(coll.id == Collider.ID_RECT)
//						rect = coll.rect.clone();
//					else if(coll.id == Collider.ID_CIRCLE)
//					{
//						var circle:Circle = coll.circle;
//						rect = new Rectangle();
//						rect.x = circle.center.x - circle.radius;
//						rect.y = circle.center.y - circle.radius;
//						rect.width = circle.radius*2;
//						rect.height = circle.radius*2;
//					}
//					
//					rect.width = drawRect.width*coll.ratioX;
//					rect.height = drawRect.height*coll.ratioY;
//					rect.x = (drawRect.width/2)-(rect.width/2);
//					rect.y = (drawRect.height/2)-(rect.height/2);
//					
//					var bitmapData:BitmapData = new BitmapData(32, 32, false, Color.RED);
//					var textureTemp:flash.display3D.textures.Texture = painter.context.createTexture(32, 32, Context3DTextureFormat.BGRA, false);
//					textureTemp.uploadFromBitmapData(bitmapData);
//					
//					var triangleTemp:TriangleData = new TriangleData();
//					triangleTemp.rawVertexData = triangleTemp.rawVertexData.concat(Vector.<Number>([rect.width/2, rect.height/2, 0, 1, 0]));
//					triangleTemp.rawVertexData = triangleTemp.rawVertexData.concat(Vector.<Number>([rect.width/2, -rect.height/2, 0, 1, 1]));
//					triangleTemp.rawVertexData = triangleTemp.rawVertexData.concat(Vector.<Number>([-rect.width/2, -rect.height/2, 0, 0, 1]));
//					triangleTemp.rawVertexData = triangleTemp.rawVertexData.concat(Vector.<Number>([-rect.width/2, rect.height/2, 0, 0, 0]));
//					
//					painter.context.setTextureAt(0, textureTemp);
//					
//					painter.pushState();
//					if(_pivot == PivotType.TOP_LEFT)
//						painter.matrix.prependTranslation((rect.x+(rect.width/2)), -(rect.y+(rect.height/2)), 0);
//					painter.setDrawData(triangleTemp);
//					painter.draw();
//					painter.popState();
//				}
			}
			for(var i:int = 0; i < numChildren; i++)
			{
				var child:GameObject = _children[i];
				child.setRenderData(painter);
			}
			painter.popState();
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
				image = _components[ComponentType.IMAGE];
				animator = _components[ComponentType.ANIMATOR];
				
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
		
		/**
		 *클릭된 좌표의 가장 위쪽에 있는 객체를 찾아냅니다. 
		 * @param point
		 * @return 
		 * 
		 */		
		public function findClickedGameObject(point:Point):GameObject
		{            
			var target:GameObject = null;
			for(var i:int = _children.length-1; i >= 0; i--)
			{
				if(_children[i].getBound().containsPoint(point) && _children[i].visible)
				{
					target = _children[i].findClickedGameObject(point);
					break;
				}
			}
			if(target == null && getGlobalRect().containsPoint(point))
			{
				target = this;
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
			var rectangle:Rectangle = new Rectangle(_x, _y, _width, _height);
			return rectangle;
		}
		
		/**
		 *프레임워크 전체에 알려줘야하는 이벤트들은 해당 함수를 사용해서 알려줍니다.
		 * @param event
		 * 
		 */		
		private function onThrowEvent(event:TrollingEvent):void
		{
			if (!_active)
			{
				return;	
			}
			
			for(var key:String in _components)
			{
				if(_components[key] != null)
					Component(_components[key]).dispatchEvent(new TrollingEvent(event.type));
			}
			
			if(_children)
			{
				for(var i:int = 0; i < _children.length; i++)
					_children[i].dispatchEvent(new TrollingEvent(event.type));
			} 
			
			//			for(var key:String in _components)
			//			{
			//				if(_components[key] != null)
			//					Component(_components[key]).dispatchEvent(event);
			//			}
			//			
			//			if(_children)
			//			{
			//				for(var i:int = 0; i < _children.length; i++)
			//					_children[i].dispatchEvent(event);
			//			}
		}
		
		/**
		 *Object의 크기보다 큰 이미지가 들어오면 크기를 자동으론 늘려줍니다.
		 * @param compare
		 * 
		 */		
		private function setBound(compare:Rectangle):void
		{
			if(_width == 0)
				_width = compare.x+compare.width;
			if(_height == 0)
				_height = compare.y+compare.height;
		}
		
		/**
		 *객체가 전체좌표에서 가지는 x,y값을 구합니다. 
		 * @return 
		 * 
		 */		
		public function getGlobalPoint():Point
		{
			var matrix:Matrix3D = getGlobalMatrix();
			var globalPoint:Point = new Point();
			
			globalPoint.x = matrix.position.x;
			globalPoint.y = matrix.position.y;
			
			if(_pivot == PivotType.CENTER)
			{
				globalPoint.x -= ((_width*getScaleXToGlobal())/2);
				globalPoint.y -= ((_height*getScaleYToGlobal())/2);
			}
			
			return globalPoint;
		}
		
		public function getGlobalMatrix():Matrix3D
		{
			var matrix:Matrix3D = new Matrix3D();
			matrix.identity();
			
			matrix = getMatrix(matrix);
			
			return matrix;
		}
		
		private function getMatrix(matrix:Matrix3D):Matrix3D
		{
			var drawRect:Rectangle = getRectangle();
			
			if(_parent != null)
				matrix = _parent.getMatrix(matrix);
			
			matrix.prependTranslation((drawRect.x), (drawRect.y), 0);
			matrix.prependRotation(_rotate, Vector3D.Z_AXIS);
			matrix.prependScale(_scaleX, _scaleY, 1);
			
			return matrix;
		}
		
		public function getScaleXToGlobal():Number
		{
			var scaleX:Number;
			scaleX = _scaleX;
			
			if(_parent != null)
			{
				scaleX *= _parent.getScaleXToGlobal();
			}
			
			return scaleX;
		}
		
		public function getScaleYToGlobal():Number
		{
			var scaleY:Number;
			scaleY = _scaleY;
			
			if(_parent != null)
			{
				scaleY *= _parent.getScaleYToGlobal();
			}
			
			return scaleY;
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
				{
					bound.width += (bound.x - childBound.x);
					bound.x = childBound.x;
				}
				if(childBound.topLeft.y < bound.topLeft.y)
				{
					bound.height += (bound.y - childBound.y);
					bound.y = childBound.y;
				}
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
		private function getGlobalRect():Rectangle
		{
			var rect:Rectangle = new Rectangle();
			rect.topLeft = getGlobalPoint();
			rect.width = _width*getScaleXToGlobal();
			rect.height = _height*getScaleYToGlobal();
			
			return rect;
		}
		
		/**
		 * 
		 * @param red
		 * @param green
		 * @param blue
		 * 게임오브젝트에 색상을 블렌딩 합니다. 
		 */
		public function blendColor(red:int, green:int, blue:int):void
		{
			_red = red;
			_green = green;
			_blue = blue;
		}
		
		/**
		 *true면 콜라이더가 랜더링됩니다. 
		 */
		public function get colliderRender():Boolean
		{
			return _colliderRender;
		}
		
		/**
		 * @private
		 */
		public function set colliderRender(value:Boolean):void
		{
			_colliderRender = value;
		}
		
		public function get components():Dictionary
		{
			return _components;
		}
		
		public function get visible():Boolean
		{
			return _visible;
		}
		
		public function set visible(value:Boolean):void
		{
			_visible = value;
			
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
		
		public function get name():String
		{
			return _name;
		}
		
		public function set name(value:String):void
		{
			_name = value;
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
		
		public function get tag():String
		{
			return _tag;
		}
		
		public function set tag(value:String):void
		{
			_tag = value;
		}

		public function get active():Boolean
		{
			return _active;
		}

		public function set active(value:Boolean):void
		{
			_active = value;
		}

		
	}
}

