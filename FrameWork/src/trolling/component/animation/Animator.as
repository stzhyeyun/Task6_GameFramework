package trolling.component.animation
{
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	import trolling.component.ComponentType;
	import trolling.component.DisplayComponent;
	import trolling.rendering.Texture;

	public class Animator extends DisplayComponent
	{
		private const TAG:String = "[Animator]";
		private const NONE:String = "none";
		
		private var _states:Dictionary; // key: State name, value: State
		private var _currentState:String; // State name
		
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
					
					addEventListener(Event.ENTER_FRAME, onNextFrame);
					addEventListener(Event.DEACTIVATE, onDeactivateScene);
				}
			}
			else
			{
				if (_isActive)
				{
					var state:State = _states[_currentState];
					state.stop();
					
					removeEventListener(Event.ENTER_FRAME, onNextFrame);
					removeEventListener(Event.DEACTIVATE, onDeactivateScene);
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
		
		protected override function onNextFrame(event:Event):void
		{
			if (_isActive && _states && _currentState != NONE)
			{
				var state:State = _states[_currentState];
				state.dispatchEvent(new Event(Event.ENTER_FRAME));
			}
		}
		
		protected override function onDeactivateScene(event:Event):void
		{
			isActive(false);
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
		
		public function removeState(stateName:String):void
		{
			if (_isActive || !stateName || !_states || !_states[stateName])
			{
				return;
			}

			var state:State = _states[stateName];
			state.dispose();
			state = null;
			delete _states[stateName];
			
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
		
		public function transition(nextStateName:String):void
		{
			if (!_isActive || !_states || !_states[nextStateName])
			{
				return;
			}
			
			if (_currentState != NONE)
			{
				var currState:State = _states[_currentState];
				currState.stop();
			}
			
			_currentState = nextStateName;
			var nextState:State = _states[_currentState];
			nextState.play();
		}
		
		public function get currentState():String
		{
			return _currentState;	
		}
	}
}