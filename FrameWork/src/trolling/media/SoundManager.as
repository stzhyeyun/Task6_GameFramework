package trolling.media
{
	import flash.events.Event;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.utils.Dictionary;
	
	public class SoundManager
	{
		public static const ALL:String = "all";
		public static const SELECT:String = "select";
		
		private static const TAG:String = "[SoundManager]";
		private static const MAX_CHANNEL:int = 32; 

		private static var _sounds:Dictionary; // key: String(Name), value: Sound
		private static var _channels:Vector.<SoundChannel>; // 동시에 32개까지 사용 가능
		private static var _bgm:Sound;
		
		public function SoundManager()
		{

		}
		
		public static function dispose():void
		{
			if (_channels)
			{
				for (var i:int = 0; i < _channels.length; i++)
				{
					if (_channels[i])
					{
						_channels[i].stop();
					}
					_channels[i] = null;
				}
			}
			_channels = null;
			
			if (_sounds)
			{
				for (var key:String in _sounds)
				{
					var sound:Sound = _sounds[key];
					sound.dispose();
					sound = null;
				}
			}
			_sounds = null;
			
			if (_bgm)
			{
				_bgm.close();
			}
			_bgm = null;
		}
		
		/**
		 * Sound를 등록합니다. Volume, Panning, startTime, Loops 값을 미리 지정해야 할 필요가 있습니다.  
		 * @param name 등록할 Sound의 이름입니다.
		 * @param sound 등록한 Sound입니다.
		 * 
		 */
		public static function addSound(name:String, sound:Sound):void
		{
			if (!sound)
			{
				trace(TAG + " addSound : No sound.");
				return;
			}
		
			if (_sounds && _sounds[name])
			{
				trace(TAG + " addSound : Registered name.");
				return;
			}
			
			if (!_sounds)
			{
				_sounds = new Dictionary();
			}
			_sounds[name] = sound;
		}
		
		/**
		 * 등록된 Sound를 제거합니다. 제거하고자 하는 Sound가 재생 중이라면 재생이 중지됩니다.
		 * @param name 제거하고자 하는 Sound의 이름입니다.
		 * 
		 */
		public static function removeSound(name:String):void
		{
			if (!_sounds || !_sounds[name])
			{
				trace(TAG + " removeSound : No sound.");
				return;
			}
			
			var sound:Sound = _sounds[name];
			
			if (sound.channelIndex != -1 && _channels && _channels[sound.channelIndex])
			{
				var channel:SoundChannel = _channels[sound.channelIndex];
				channel.stop();
				_channels[sound.channelIndex] = null;
			}
			
			sound.dispose();
			_sounds[name] = null;
			delete _sounds[name];
		}
		
		/**
		 * 해당 이름의 Sound을 반환합니다. 
		 * @param name 반환받고자 하는 Sound의 이름입니다. 
		 * @return 해당 이름을 가진 Sound입니다. 대상이 없을 경우 null을 반환합니다.
		 * 
		 */
		public static function getSound(name:String):Sound
		{
			if (!_sounds)
			{
				return null;	
			}
			
			for (var key:String in _sounds)
			{
				if (key == name)
				{
					return _sounds[key];
				}
			}
			
			return null;
		}
		
		/**
		 * 해당 이름의 Sound를 교체합니다.
		 * @param name 교체하고자 하는 Sound의 이름입니다.
		 * @param editedSound 새롭게 등록할 Sound입니다.
		 * 
		 */
		public static function setSound(name:String, editedSound:Sound):void
		{
			if (!_sounds)
			{
				return;	
			}
			
			for (var key:String in _sounds)
			{
				if (key == name)
				{
					_sounds[key] = editedSound;
					break;
				}
			}
		}
		
		/**
		 * 지정한 Sound를 재생합니다.
		 * @param name 재생하고자 하는 Sound의 이름입니다.
		 * 
		 */
		public static function play(name:String):void
		{
			if (!_sounds || !_sounds[name])
			{
				trace(TAG + " play : No sound.");
				return;
			}
			
			if (_channels && _channels.length == MAX_CHANNEL)
			{
				trace(TAG + " play : Cannot add channel.");
				return;
			}
			
			var sound:Sound = _sounds[name];
			
			var loops:int = sound.loops;
			var isInfinite:Boolean = false;
			if (loops == Sound.INFINITE)
			{
				loops = 0;
				isInfinite = true;
			}
			
			var channel:SoundChannel =
				sound.play(sound.startTime, loops, new SoundTransform(sound.volume, sound.panning));
			
			// Channel 저장			
			if (!_channels)
			{
				_channels = new Vector.<SoundChannel>();
			}
			
			var pushed:Boolean = false;
			for (var i:int = 0; i < _channels.length; i++)
			{
				if (_channels[i] == null)
				{
					_channels[i] = channel;
					pushed = true;
					break;
				}
			}
			
			if (!pushed)
			{
				_channels.push(channel);
			}
			sound.channelIndex = _channels.length - 1;
			
			// addEventListener
			if (!isInfinite)
			{
				channel.addEventListener(Event.SOUND_COMPLETE, onEnd);
			}
			else
			{
				channel.addEventListener(Event.SOUND_COMPLETE, onEndBgm);
				_bgm = sound;
			}
		}
		
		/**
		 * 현재 재생 중인 배경음악(무한반복되도록 설정된 Sound)을 정지합니다. 
		 * 
		 */
		public static function stopBgm():void
		{
			if (!_bgm || !_channels)
			{
				return;
			}
			
			var bgmIndex:int = _bgm.channelIndex;
			
			if (bgmIndex < 0 || !_channels[bgmIndex])
			{
				return;
			}
			
			var channel:SoundChannel = _channels[bgmIndex];
			channel.removeEventListener(Event.SOUND_COMPLETE, onEndBgm);
			channel.stop();
			channel = null;
			
			_bgm.channelIndex = -1;
			_bgm = null;
		}
				
		/**
		 * 현재 재생 중인 Sound의 Volume을 제어합니다. 
		 * @param target SoundManager.ALL: 현재 재생 중인 전체 Sound / SoundManager:SELECT: 현재 재생 중인 Sound 중 지정한 Sound
		 * @param volume 0부터 1 사이의 값을 지정합니다.
		 * @param name Volume을 제어하고자 하는 특정 Sound의 이름입니다.
		 * 
		 */
		public static function setPlayingSoundVolume(target:String, volume:Number, name:String = null):void
		{
			if (!_channels)
			{
				trace(TAG + " setPlayingSoundVolume : No target.");
				return;
			}
			
			switch (target)
			{
				case ALL:
				{
					for (var key:String in _channels)
					{
						var channel:SoundChannel = _channels[key];
						channel.soundTransform.volume = volume;
					}
				}
					break;
				
				case SELECT:
				{
					if (!name || !_channels[name])
					{
						trace(TAG + " setPlayingSoundVolume : No target.");
						return;
					}
					
					var channel:SoundChannel = _channels[name];
					channel.soundTransform.volume = volume;
				}
					break;
			}
		}
		
		/**
		 * 현재 재생 중인 Sound의 Panning을 제어합니다. 
		 * @param target SoundManager.ALL: 현재 재생 중인 전체 Sound / SoundManager:SELECT: 현재 재생 중인 Sound 중 지정한 Sound
		 * @param pan -1(왼쪽 최대)부터 1(오른쪽 최대) 사이의 값을 지정합니다.
		 * @param name Panning을 제어하고자 하는 특정 Sound의 이름입니다.
		 * 
		 */
		public static function setPlayingSoundPanning(target:String, pan:Number, name:String = null):void
		{
			if (!_channels)
			{
				trace(TAG + " setPlayingSoundPanning : No target.");
				return;
			}
			
			switch (target)
			{
				case ALL:
				{
					for (var key:String in _channels)
					{
						var channel:SoundChannel = _channels[key];
						channel.soundTransform.pan = pan;
					}
				}
					break;
				
				case SELECT:
				{
					if (!name || !_channels[name])
					{
						trace(TAG + " setPlayingSoundPanning : No target.");
						return;
					}
					
					var channel:SoundChannel = _channels[name];
					channel.soundTransform.pan = pan;
				}
					break;
			}
		}
		
		/**
		 * Sound의 재생이 끝나면 해당 SoundChannel의 인덱스를 null 처리합니다. 
		 * @param event Event.SOUND_COMPLETE
		 * 
		 */
		private static function onEnd(event:Event):void
		{
			var channel:SoundChannel = event.target as SoundChannel;
			
			if (channel)
			{
				channel.removeEventListener(Event.SOUND_COMPLETE, onEnd);
				
				var index:int = _channels.indexOf(channel);
				if (index != -1)
				{
					_channels[index] = null;
				}
			}
		}
		
		/**
		 * 배경음악(무한반복되도록 설정된 Sound)의 재생이 끝나면 다시 재생을 시작합니다.
		 * @param event Event.SOUND_COMPLETE
		 * 
		 */
		private static function onEndBgm(event:Event):void
		{
			var channel:SoundChannel = event.target as SoundChannel;
			
			if (channel)
			{
				channel.removeEventListener(Event.SOUND_COMPLETE, onEndBgm);
				
				channel = _bgm.play(_bgm.startTime, 0, channel.soundTransform);
				channel.addEventListener(Event.SOUND_COMPLETE, onEndBgm);
			}
		}
	}
}