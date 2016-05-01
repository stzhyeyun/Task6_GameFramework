package trolling.component.animation
{
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	import trolling.component.ComponentType;
	import trolling.component.DisplayComponent;
	import trolling.rendering.Texture;
	import trolling.event.TrollingEvent;

	public class Animator extends DisplayComponent
	{
		private const TAG:String = "[Animator]";
		private const NONE:String = "none";
		
		private var _states:Dictionary; // key: State name, value: State
		private var _currentState:String; // State name
		
		public function Animator()
		{
			super(ComponentType.ANIMATOR);
			
			_currentState = NONE;
			
			addEventListener(Event.ENTER_FRAME, onNextFrame);
			addEventListener(TrollingEvent.DEACTIVATE, onDeactivateScene);
		}
				
		public override function dispose():void
		{
			this.isActive = false;
			
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
					addEventListener(TrollingEvent.DEACTIVATE, onDeactivateScene);
				}
			}
			else
			{
				if (_isActive)
				{
					var state:State = _states[_currentState];
					state.stop();
					
					removeEventListener(Event.ENTER_FRAME, onNextFrame);
					removeEventListener(TrollingEvent.DEACTIVATE, onDeactivateScene);
				}
			}

			_isActive = value;
		}
		
		public override function getRenderingResource():Texture
		{
			if (!_isActive || !_states || _currentState == NONE)
			{
				if (!_isActive)
					trace(TAG + " getRenderingResource : Animator is inactive now.");
				else if (!_states)
					trace(TAG + " getRenderingResource : No State.");
				else if (_currentState == NONE)
					trace(TAG + " getRenderingResource : No current State.");
				
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
				state.dispatchEvent(event);
			}
		}
		
		protected override function onDeactivateScene(event:Event):void
		{
			this.isActive = false;
		}
				
		public function addState(stateName:String):State // 새로운 State 추가
		{
			if (!stateName || stateName == "" || stateName == NONE)
			{
				trace(TAG + " addState : Inappropriate state name.");
				return null;
			}
			
			if (_states && _states[stateName])
			{
				trace(TAG + " addState : Animator already has the state of same name.");
				return null;
			}
			
			var isFirst:Boolean = false;
			if (!_states)
			{
				_states = new Dictionary();
				isFirst = true;
			}
			
			var state:State = new State(stateName);
			_states[stateName] = state;
			
			if (isFirst)
			{
				_currentState = stateName;
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