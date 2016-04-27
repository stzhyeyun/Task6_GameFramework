package trolling.component.animation
{
	import flash.display.BitmapData;
	import flash.utils.Dictionary;
	
	import trolling.component.ComponentType;
	import trolling.component.DisplayComponent;
	import trolling.object.GameObject;

	public class Animator extends DisplayComponent
	{
		private const TAG:String = "[Animator]";
		private const NONE:String = "none";
		
		private var _states:Dictionary; // key: TouchEvent name, value: State
		private var _currentState:String; // TouchEvent name
		
		public function Animator(name:String, parent:GameObject)
		{
			super(ComponentType.ANIMATOR, name, parent);
			
			_currentState = NONE;
		}
				
		public override function dispose():void
		{
			isActive(false);
			
			if (_states)
			{
				for (var key:String in _states)
				{
					State(_states[key]).dispose();
					_states[key] = null;
				}
			}
			_states = null;
			_currentState = null;
			
			super.dispose();
		}
		
		public override function set isActive(value:Boolean):void
		{
			if (value)
			{
				if (!_isActive)
				{
					if (!_states)
					{
						return;
					}
					//addEventListener(TouchEvent.ENDED, onTouch);
				}
			}
			else
			{
				if (_isActive)
				{
					State(_states[_currentState]).stop();
					//removeEventListener(TouchEvent.ENDED, onTouch);
				}
			}

			_isActive = value;
		}
		
		public override function getRenderingResource():BitmapData
		{
			if (!_isActive || !_states || _currentState == NONE)
			{
				return null;
			}
			
			return State(_states[_currentState]).getCurrentFrame();
		}
				
		public function addState(key:String, name:String):State // 새로운 State 추가
		{
			if (!name || name == "" || name == NONE)
			{
				return null;
			}
			
			if (_states && _states[key])
			{
				return null;
			}
			
			var isFirst:Boolean = false;
			if (!_states)
			{
				_states = new Dictionary();
				isFirst = true;
			}
			
			var state:State = new State(name);
			_states[key] = state;
			
			if (isFirst)
			{
				_currentState = key;
			}
			
			return state;
		}
		
		public function removeState(name:String):void
		{
			if (_isActive || !name || name == "" || !_states)
			{
				return;
			}
			
			var key:String = isState(name);
			if (key == NONE)
			{
				return;
			}
			
			State(_states[key]).dispose();
			_states[key] = null;
			delete _states[key];
			
			_currentState = NONE;
		}
		
		public function getState(name:String):State
		{
			if (!_states)
			{
				return null;	
			}
			
			for (var key:String in _states)
			{
				var state:State = _states[key];
				if (state.name == name)
				{
					return state;
				}
			}
			
			return null;
		}
		
		public function setState(name:String, editedState:State):void // 기존 State를 수정(교체)
		{
			if (_isActive || !_states)
			{
				return;	
			}
			
			for (var key:String in _states)
			{
				var state:State = _states[key];
				if (state.name == name)
				{
					state = editedState;
					break;
				}
			}
		}
		
		public function get currentState():String
		{
			return _currentState;	
		}
		
//		private function onTouch(event:TouchEvent):void
//		{
//			if (!_isActive || !_states)
//			{
//				return;
//			}
//			
//			// Get key
//			
//			if (isKey(key))
//			{
//				transition(key);			
//			}
//		}
		
		private function isKey(input:String):Boolean
		{
			if (!_states)
			{
				return false;	
			}
			
			var result:Boolean = false;
			
			for (var key:String in _states)
			{
				if (key == input)
				{
					result = true;
					break;
				}
			}
			
			return result;
		}
		
		private function isState(input:String):String
		{
			if (!_states)
			{
				return NONE;	
			}
			
			for (var key:String in _states)
			{
				var state:State = _states[key];
				if (state.name == input)
				{
					return key;
				}
			}
			
			return NONE;
		}
		
		private function transition(key:String):void
		{
			if (!_isActive || !_states)
			{
				return;
			}

			if (_currentState != NONE)
			{
				State(_states[_currentState]).stop();
			}
			
			_currentState = key;			
			State(_states[_currentState]).play();
		}
	}
}