package trolling.component.physics
{
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import trolling.component.Component;
	import trolling.component.ComponentType;
	import trolling.utils.Circle;

	public class Collider extends Component
	{
		public const ID_NONE:int = -1;
		public const ID_RECT:int = 0;
		public const ID_CIRCLE:int = 0;
		
		private const TAG:String = "[Collider]";
		
		private var _id:int;
		private var _rect:Rectangle;
		private var _circle:Circle;
		private var _dxFromParent:Number;
		private var _dyFromParent:Number;
		
		private var _isVisible:Boolean;
		
		public function Collider()
		{
			super(ComponentType.COLLIDER);
			
			_id = ID_NONE;
			_rect = null;
			_circle = null;
			
			_isVisible = false;
			
			addEventListener(Event.ENTER_FRAME, onNextFrame);
			addEventListener(Event.ACTIVATE, onActivateScene);
			addEventListener(Event.DEACTIVATE, onDeactivateScene);
			
			// ColliderManager에 등록
		}
		
		public override function dispose():void
		{
			_id = ID_NONE;
			_rect = null;
			_circle = null;
			_dxFromParent = 0;
			_dyFromParent = 0;
			
			_isVisible = false;
			
			super.dispose();
		}
		
		public override function set isActive(value:Boolean):void
		{
			if (value)
			{
				if (!_isActive)
				{
					addEventListener(Event.ENTER_FRAME, onNextFrame);
					addEventListener(Event.ACTIVATE, onActivateScene);
					addEventListener(Event.DEACTIVATE, onDeactivateScene);
				}
			}
			else
			{
				if (_isActive)
				{
					removeEventListener(Event.ENTER_FRAME, onNextFrame);
					removeEventListener(Event.ACTIVATE, onActivateScene);
					removeEventListener(Event.DEACTIVATE, onDeactivateScene);
					
					_isVisible = false;
				}
			}
			
			_isActive = value;
		}
		
		protected override function onNextFrame(event:Event):void
		{
			if (_isActive)
			{
				updatePosition();
			}
		}
		
		protected override function onActivateScene(event:Event):void
		{
			this.isActive = true;
		}
		
		protected override function onDeactivateScene(event:Event):void
		{
			this.isActive = false;
		}
		
		public function isCollision(object:Collider):Boolean
		{
			var objectId:int = object.id;
			
			if (_id == ID_NONE || objectId == ID_NONE)
			{
				return false;
			}

			switch (_id)
			{
				case ID_RECT:
				{
					if (objectId == ID_RECT)
					{
						return _rect.intersects(object.rect);
					}
					else if (objectId == ID_CIRCLE)
					{
						return detectCollisionRectToCircle(_rect, object.circle);
					}
				}
					break;
				
				case ID_CIRCLE:
				{
					if (objectId == ID_RECT)
					{
						return detectCollisionRectToCircle(object.rect, _circle);
					}
					else if (objectId == ID_CIRCLE)
					{
						return _circle.intersects(object.circle);
					}
				}
					break;
			}
			
			return false;
		}

		public function get id():int
		{
			return _id;
		}
		
		public function get rect():Rectangle
		{
			return _rect;
		}
		
		public function get circle():Circle
		{
			return _circle;
		}
		
		public function get isVisible():Boolean
		{
			return _isVisible;
		}
		
		public function set isVisible(value:Boolean):void
		{
			_isVisible = value;
		}
		
		public function setRect(parentLocalPos:Point, collider:Rectangle):void
		{
			_id = ID_RECT;
			_rect = collider;
			
			_dxFromParent = _rect.x - parentLocalPos.x;
			_dyFromParent = _rect.y - parentLocalPos.y;
		}
		
		public function setCircle(parentLocalPos:Point, collider:Circle):void
		{
			_id = ID_CIRCLE;
			_circle = collider;
			
			_dxFromParent = _circle.center.x - parentLocalPos.x;
			_dyFromParent = _circle.center.y - parentLocalPos.y;
		}
		
		private function detectCollisionRectToCircle(rect:Rectangle, circle:Circle):Boolean
		{
			var topRight:Point = new Point(rect.x + rect.width, rect.y);
			var bottomLeft:Point = new Point(rect.x, rect.y + rect.height);
			
			if (circle.containsPoint(rect.topLeft)) return true;
			if (circle.containsPoint(topRight)) return true;
			if (circle.containsPoint(bottomLeft)) return true;
			if (circle.containsPoint(rect.bottomRight)) return true;
			
			var outerRect:Rectangle = new Rectangle(
				circle.center.x - circle.radius, circle.center.y - circle.radius,
				circle.radius, circle.radius);
			
			return rect.intersects(outerRect);
		}
		
		private function updatePosition():void
		{
			if (!_parent || _id == ID_NONE)
			{
				return;
			}
			
			var parentGlobalPos:Point = _parent.getGlobalPoint();
			
			if (_id == ID_RECT)
			{
				_rect.x = parentGlobalPos.x + _dxFromParent;
				_rect.y = parentGlobalPos.y + _dyFromParent;
			}
			else if (_id == ID_CIRCLE)
			{
				_circle.center.x = parentGlobalPos.x + _dxFromParent;
				_circle.center.y = parentGlobalPos.y + _dyFromParent;
			}
		}
	}
}