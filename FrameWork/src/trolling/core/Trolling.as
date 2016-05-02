package trolling.core
{
	import flash.display.Sprite;
	import flash.display.Stage3D;
	import flash.display3D.Context3D;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Mouse;
	import flash.utils.Dictionary;
	
	import trolling.component.physics.Collider;
	import trolling.event.TouchManager;
	import trolling.event.TouchPhase;
	import trolling.event.TrollingEvent;
	import trolling.object.GameObject;
	import trolling.object.Scene;
	import trolling.object.Stage;
	import trolling.rendering.Painter;
	import trolling.utils.Color;
	
	public class Trolling
	{        
		private const TAG:String = "[Trolling]";
		
		private var _sceneDic:Dictionary;
		private var _createQueue:Array = new Array();
		
		private var _currentScene:GameObject;
		private var _viewPort:Rectangle;
		private var _stage:Stage;
		
		private var _started:Boolean = false;
		private var _initRender:Boolean = false;
		
		private var _painter:Painter;
		
		private var _nativeStage:flash.display.Stage;
		private var _nativeOverlay:Sprite;
		
		private static var sPainters:Dictionary = new Dictionary(true);
		private static var _current:Trolling;
		private var _context:Context3D = null;
		
		private var _touchManager:TouchManager = new TouchManager();
		
		
		// Collider Management
		private var _colliders:Vector.<Collider>;
		private var _colliderActivated = true;
		//
		
		public function Trolling(stage:flash.display.Stage, stage3D:Stage3D = null)
		{
			if (stage == null) throw new ArgumentError("Stage must not be null");
			if (stage3D == null) stage3D = stage.stage3Ds[0];
			
			_current = this;
			
			trace(stage.width, stage.height);
			_viewPort = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
			
			_nativeOverlay = new Sprite();
			
			_stage = new Stage(_viewPort.width, _viewPort.height, stage.color);
			trace("stage init");
			_nativeStage = stage;
			_nativeStage.addChild(_nativeOverlay);
			trace("addNativeOverlay");
			
			_painter = createPainter(stage3D);
			_painter.initPainter(onInitPainter);
			
			stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			trace("successed Creater");
			
			stage.addEventListener(TouchEvent.TOUCH_BEGIN, onTouch); 
			stage.addEventListener(TouchEvent.TOUCH_MOVE, onTouch); 
			stage.addEventListener(TouchEvent.TOUCH_END, onTouch);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onTouch);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onTouch);
			stage.addEventListener(MouseEvent.MOUSE_UP, onTouch);
			stage.addEventListener(TouchEvent.TOUCH_OVER, onTouch);
		}
		
		private function onTouch(event:Event):void
		{
			if(_currentScene == null)
				return;
			//trace("onTouch");
			
			var globalX:Number;
			var globalY:Number;
			var touchID:int;
			var phase:String;
			var pressure:Number = 1.0;
			var width:Number = 1.0;
			var height:Number = 1.0;
			
			// figure out general touch properties
			if (event is MouseEvent)
			{
				var mouseEvent:MouseEvent = event as MouseEvent;
				globalX = mouseEvent.stageX;
				globalY = mouseEvent.stageY;
				touchID = 0;
				
				// MouseEvent.buttonDown returns true for both left and right button (AIR supports
				// the right mouse button). We only want to react on the left button for now,
				// so we have to save the state for the left button manually.
				//if (event.type == MouseEvent.MOUSE_DOWN)    _leftMouseDown = true;
				//else if (event.type == MouseEvent.MOUSE_UP) _leftMouseDown = false;
			}
			else
			{
				var touchEvent:TouchEvent = event as TouchEvent;
				
				// On a system that supports both mouse and touch input, the primary touch point
				// is dispatched as mouse event as well. Since we don't want to listen to that
				// event twice, we ignore the primary touch in that case.
				
				if (Mouse.supportsCursor && touchEvent.isPrimaryTouchPoint) return;
				else
				{
					globalX  = touchEvent.stageX;
					globalY  = touchEvent.stageY;
					touchID  = touchEvent.touchPointID;
					pressure = touchEvent.pressure;
					width    = touchEvent.sizeX;
					height   = touchEvent.sizeY;
				}
			}
			
			switch (event.type) 
			{
				case TouchEvent.TOUCH_BEGIN: phase = TouchPhase.BEGAN; break;
				case TouchEvent.TOUCH_MOVE:  phase = TouchPhase.MOVED; break;
				case TouchEvent.TOUCH_END:   phase = TouchPhase.ENDED; break;
				case MouseEvent.MOUSE_MOVE:  phase = TouchPhase.MOVED; break;
				case MouseEvent.MOUSE_DOWN:  phase = TouchPhase.BEGAN; break;
				case MouseEvent.MOUSE_UP:    phase = TouchPhase.ENDED; break;
				case TouchEvent.TOUCH_OVER:  phase = TouchPhase.HOVER; break;
				//case MouseEvent.MOUSE_MOVE: 
				//phase = (_leftMouseDown ? TouchPhase.MOVED : TouchPhase.HOVER); break;
			}
			
			// move position into viewport bounds
			globalX = _stage.stageWidth  * (globalX - _viewPort.x) / _viewPort.width;
			globalY = _stage.stageHeight * (globalY - _viewPort.y) / _viewPort.height;
			var point:Point = new Point(globalX, globalY);
			_touchManager.pushPoint(point);
			var hit:GameObject;
			
			//trace("globalX = " + globalX + " globalY = " + globalY);
			
			if(phase == TouchPhase.BEGAN)
			{
				hit = _currentScene.findClickedGameObject(point);
				if(hit != null)
					hit.dispatchEvent(new TrollingEvent(phase, _touchManager.points));
				_touchManager.hoverFlag = true;
				_touchManager.hoverTarget = hit;
			}
			else if(phase == TouchPhase.MOVED)
			{
				hit = _currentScene.findClickedGameObject(point);
				if(hit != null)
					hit.dispatchEvent(new TrollingEvent(phase, _touchManager.points));
				//	_touchManager.pushPoint(point);
				if(hit != _touchManager.hoverTarget)
					_touchManager.hoverTarget = hit;
			}
			else if(phase == TouchPhase.ENDED)
			{
				hit = _currentScene.findClickedGameObject(point);
				if(hit != null)
					hit.dispatchEvent(new TrollingEvent(phase, _touchManager.points));
				_touchManager.hoverFlag = false;
			}
		}
		
		//		private function seekHover():void
		//		{
		//			if(!_touchManager.hoverFlag)
		//				return;
		//		}
		
		public function get painter():Painter
		{
			return _painter;
		}
		
		public function set painter(value:Painter):void
		{
			_painter = value;
		}
		
		public static function get painter():Painter
		{
			return _current.painter;
		}
		
		public function get profile():String
		{
			if(_context)
				return _context.profile;
			else
				return null;
		}
		
		public function get context():Context3D
		{
			return _context;
		}
		
		public function set context(value:Context3D):void
		{
			_context = value;
		}
		
		public static function get current():Trolling
		{
			return _current;
		}
		
		public static function set current(value:Trolling):void
		{
			_current = value;
		}
		
		public function get stage():Stage
		{
			return _stage;
		}
		
		public function set stage(value:Stage):void
		{
			_stage = value;
		}
		
		private function onInitPainter(context:Context3D):void
		{
			_painter.configureBackBuffer(_viewPort);
			_initRender = true;
			_context = context;
			trace("createContext");
			//	initializeRoot();
			createSceneFromQueue();
			trace("initRoot");
		}
		
		private function createSceneFromQueue():void
		{
			var arrayTemp:Array;
			while(_createQueue.length != 0)
			{
				arrayTemp = _createQueue.shift();
				addScene(arrayTemp[0], arrayTemp[1]);
			}
			arrayTemp = null;
			_createQueue = null;
		}
		
		private function nextFrame():void
		{
			_currentScene.dispatchEvent(new Event(Event.ENTER_FRAME));
		}
		
		public function addScene(sceneClass:Class, key:String):void
		{
			if(_sceneDic && _sceneDic[key] != null)
				return;
			if(_context == null)
			{
				var addArray:Array = new Array();
				addArray.push(sceneClass);
				addArray.push(key);
				_createQueue.push(addArray);
				return;	
			}
			var scene:Scene = new sceneClass() as Scene;
			if(!_sceneDic)
			{
				_sceneDic = new Dictionary();
				_currentScene = scene;
			}
			_sceneDic[key] = scene;
			if(scene == null)
				trace("scene is null");
			if(_stage == null)
				trace("_stage is null");
			scene.width = _stage.stageWidth;
			scene.height = _stage.stageHeight;
		}
		
		public function switchScene(key:String):void
		{
			if(_sceneDic == null || _sceneDic[key] == null)
				return;
			_currentScene = _sceneDic[key];
		}
		
		//		public function initializeRoot():void
		//		{
		//			if(_currentScene == null && _rootClass != null)
		//			{
		//				_currentScene = new _rootClass() as GameObject;
		//				_currentScene.x = _stage.x;
		//				_currentScene.y = _stage.y;
		//				_currentScene.width = _stage.width;
		//				_currentScene.height = _stage.height;
		//				_stage.addChild(_currentScene);
		//			}
		//		}
		
		public function start():void
		{
			_started = true;
		}
		
		public function dispose():void
		{
			
		}
		
		private function createPainter(stage3D:Stage3D):Painter
		{
			if (stage3D in sPainters)
				return sPainters[stage3D];
			else
			{
				var painter:Painter = new Painter(stage3D);
				sPainters[stage3D] = painter;
				return painter;
			}
		}
		
		private function onEnterFrame(event:Event):void
		{
			if(!_started || !_initRender || !_currentScene)
				return;
			if(_touchManager.hoverFlag)
				_touchManager.hoverTarget.dispatchEvent(new TrollingEvent(TouchPhase.HOVER, _touchManager.points));
			nextFrame();
			detectCollision();
			render();
		}
		
		private function render():void
		{
			if(_painter.context == null)
				return;
			
			_painter.context.setRenderToBackBuffer();
			_painter.context.clear(Color.getRed(_stage.color)/255.0, Color.getGreen(_stage.color)/255.0, Color.getBlue(_stage.color)/255.0);
			//	_painter.triangleData.initArray();
			_currentScene.render(_painter);
			_painter.present();
		}
		
		// ColliderManagement //////////////////////////////////////// 
		
		public function addCollider(collider:Collider):void
		{
			if (!_colliders)
			{
				_colliders = new Vector.<Collider>();
			}
			_colliders.push(collider);
		}
		
		public function removeCollider(collider:Collider):void
		{
			if (!_colliders || !collider)
			{
				return;
			}
			
			for (var i:int = 0; i < _colliders.length; i++)
			{
				if (_colliders[i] == collider)
				{
					_colliders.removeAt(i);
					break;
				}
			}
		}
		
		public function set colliderActivated(value:Boolean):void
		{
			_colliderActivated = value;
		}
		
		private function detectCollision():void
		{
			if (!_colliderActivated || !_colliders || _colliders.length <= 1)
			{
				return;
			}
			
			var index:int = 0;
			var collidedIndices:Vector.<int>;
			var detectionObjects:Vector.<Collider> = new Vector.<Collider>();
			for (var i:int = 0; i < _colliders.length; i++)
			{
				detectionObjects.push(_colliders[i]);	
			}
			
			if (!detectionObjects)
			{
				throw new ArgumentError(TAG + " detectCollision : Failed to clone Colliders.");
			}
			
			while (index < detectionObjects.length - 1)
			{
				for (var i:int = index + 1; i < detectionObjects.length; i++)
				{
					if (detectionObjects[index].isCollision(detectionObjects[i]))
					{
						// Dispatch event
						detectionObjects[index].parent.dispatchEvent(
							new TrollingEvent(TrollingEvent.COLLIDE, detectionObjects[i].parent));
						detectionObjects[i].parent.dispatchEvent(
							new TrollingEvent(TrollingEvent.COLLIDE, detectionObjects[index].parent));
						
						// Store collided objects' indices for deletion from detectionObjects
						if (!collidedIndices)
						{
							collidedIndices = new Vector.<int>();
						}
						collidedIndices.push(i);
					}
				}
				
				// Remove collided objects from detectionObjects
				if (collidedIndices)
				{
					var numRemove:int = 0;
					for (var j:int = 0; j < collidedIndices.length; j++)
					{
						detectionObjects.removeAt(collidedIndices[j] - numRemove);
						numRemove++;
					}
				}
				collidedIndices = null;
				
				index++;
			}
			
			collidedIndices = null;
			detectionObjects = null;
		}
		
		// End of ColliderManagement 
	}
}