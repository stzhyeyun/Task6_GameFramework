package trolling.component.animation
{
	import flash.utils.Dictionary;
	
	import trolling.component.ComponentType;
	import trolling.component.DisplayComponent;
	import trolling.rendering.Texture;

	public class Animator extends DisplayComponent
	{
		private const TAG:String = "[Animator]";
		private const NONE:String = "none";
		
		private var _states:Dictionary; // key: TouchEvent name, value: State
		private var _currentState:String; // TouchEvent name
		
		public function Animator(isActive:Boolean = false)
		{
			super(ComponentType.ANIMATOR, isActive);
			
			_currentState = NONE;
		}
				
		public override function dispose():void
		{
			isActive(false);
			
			if (_states)
			{
				for (var key:String in _states)
				{
					var state:State = _states[key];
					state.dispose();
					state = null;
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
					var state:State = _states[_currentState];
					state.stop();
					//removeEventListener(TouchEvent.ENDED, onTouch);
				}
			}

			_isActive = value;
		}
		
		public override function getRenderingResource():Texture
		{
			if (!_isActive || !_states || _currentState == NONE)
			{
				return null;
			}
			
			var state:State = _states[_currentState];
			
			return state.getCurrentFrame();
		}
				
		public function addState(key:String, name:String):State // 새로운 State 추가
		{
			if (!key || key == "" || !name || name == "" || name == NONE)
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
			if (_isActive || !name || !_states)
			{
				return;
			}
			
			var key:String = isState(name);
			if (key == NONE)
			{
				return;
			}
			
			var state:State = _states[key];
			state.dispose();
			state = null;
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
				var currState:State = _states[_currentState];
				currState.stop();
			}
			
			_currentState = key;
			var nextState:State = _states[_currentState];
			nextState.play();
		}
	}
}