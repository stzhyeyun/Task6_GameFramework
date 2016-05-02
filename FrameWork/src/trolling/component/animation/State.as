package trolling.component.animation
{
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import trolling.event.Event;
	import trolling.rendering.Texture;
	
	public class State extends EventDispatcher
	{
		private const TAG:String = "[State]";
		
		private var _name:String;
		private var _animation:Vector.<Texture>;
		private var _currentIndex:int;
		private var _animationSpeed:uint; // 다음 애니메이션 인덱스로 업데이트 하기까지의 프레임 수
		private var _frameCounter:uint;
		private var _isPlaying:Boolean;
		
		public function State(name:String)
		{
			_name = name;
			_currentIndex = -1;
			_animationSpeed = 0;
			_frameCounter = 0;
			_isPlaying = false;
		}
		
		public function dispose():void
		{
			stop();
			
			_name = null;
			
			if (_animation && _animation.length > 0)
			{
				for (var i:int = 0; i < _animation.length; i++)
				{
					_animation[i].dispose();
					_animation[i] = null;
				}
			}
			_animation = null;
			
			_currentIndex = -1;
			_animationSpeed = 0;
			_frameCounter = 0;
		}
		
		public function play():void
		{
			if (!_isPlaying)
			{
				if (!_animation)
				{
					return;
				}
				
				_currentIndex = 0;
				
				if (_animationSpeed == 0) // [혜윤] animationSpeed가 설정되어있지 않으면 1로 보정
				{
					_animationSpeed = 1;
				}
				
				_isPlaying = true;			
				addEventListener(Event.ENTER_FRAME, onNextFrame);
			}
		}
		
		public function stop():void
		{
			if (_isPlaying)
			{
				_currentIndex = -1;
				_isPlaying = false;
				removeEventListener(Event.ENTER_FRAME, onNextFrame);
			}
		}
		
		public function addFrame(resource:Bitmap):void
		{
			if (!resource)
			{
				trace(TAG + " addFrame : No \'resource\'.");
				return;
			}
			
			var frame:Texture = new Texture(resource);
			
			if (!frame)
			{
				throw new ArgumentError(TAG + " addFrame : Failed to create a Texture.");
			}
			
			if (!_animation)
			{
				_animation = new Vector.<Texture>();
			}
			_animation.push(frame);
		}
		
		public function removeFrame(index:int):void
		{
			if (!_animation || index < 0 || index >= _animation.length || _isPlaying)
			{
				return;
			}
			
			_animation[index].dispose();
			_animation[index] = null;
			_animation.removeAt(index);
		}
		
		public function getCurrentFrame():Texture
		{
			if (!_animation || _currentIndex < 0 || !_isPlaying)
			{
				if (!_animation || _currentIndex < 0)
					trace(TAG + " getCurrentFrame : No animating resource.");
				else if (!_isPlaying)
					trace(TAG + " getCurrentFrame : Animation is not playing.");
				
				return null;
			}
			else
			{
				return _animation[_currentIndex];
			}
		}
		
		public function get name():String
		{
			return _name;	
		}
		
		public function set name(value:String):void
		{
			_name = value;
		}
		
		public function get currentIndex():int
		{
			return _currentIndex;	
		}
		
		public function get animationSpeed():uint
		{
			return _animationSpeed;	
		}
		
		public function set animationSpeed(value:uint):void
		{
			if (value <= 0)
			{
				value = 1;
			}
			_animationSpeed = value;
		}
		
		public function get isPlaying():Boolean
		{
			return _isPlaying;	
		}
		
		private function onNextFrame(event:Event):void
		{
			if (!_isPlaying)
			{
				return;
			}
			
			_frameCounter++;
			
			if (_frameCounter == _animationSpeed)
			{
				_currentIndex++;
				
				if (_currentIndex >= _animation.length)
				{
					_currentIndex = 0;
				}
				
				_frameCounter = 0;
			}
		}
	}
}