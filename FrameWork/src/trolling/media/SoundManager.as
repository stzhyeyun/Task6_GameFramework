package trolling.media
{
	import flash.events.Event;
	import flash.media.SoundChannel;
	import flash.media.SoundMixer;
	import flash.media.SoundTransform;
	import flash.utils.Dictionary;
	
	import trolling.event.Event;
	
	public class SoundManager
	{
		public static const ALL:String = "all";
		public static const SELECT:String = "select";
		
		private const TAG:String = "[SoundManager]";
		private const MAX_CHANNEL:int = 32; 
		
		private static var _instance:SoundManager;
		
		private var _sounds:Dictionary; // key: String(Name), value: Sound
		private var _channels:Vector.<SoundChannel>; // key: String(Name), value: SoundChannel // 동시에 32개까지 사용 가능
		private var _bgm:Sound;
		
		public function SoundManager()
		{
			_instance = this;
		}
		
		public static function getInstance():SoundManager
		{
			if (!_instance)
			{
				_instance = new SoundManager();
			}
			return _instance;
		}
		
		public function dispose():void
		{
			//stopAll();
			
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
		
		public function addSound(name:String, sound:Sound):void
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
		
		public function removeSound(name:String):void
		{
			if (!_sounds || !_sounds[name])
			{
				trace(TAG + " removeSound : No sound.");
				return;
			}
			
			if (_channels && _channels[name])
			{
				var channel:SoundChannel = _channels[name];
				channel.stop();
				_channels[name] = null;
				delete _channels[name];
			}
			
			var sound:Sound = _sounds[name];
			sound.dispose();
			_sounds[name] = null;
			delete _sounds[name];
		}
		
		public function play(name:String):void
		{
			if (!_sounds || !_sounds[name])
			{
				trace(TAG + " play : No sound.");
				return;
			}
			
//			if (_channels && _channels[name])
//			{
//				trace(TAG + " play : " + name + " is playing.");
//				return;
//			}
			
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
				if (_channels[i] = null)
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
		
		public function stopBgm():void
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
				
		public function setVolume(target:String, volume:Number, name:String = null):void
		{
			if (!_channels)
			{
				trace(TAG + " setVolume : No target.");
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
						trace(TAG + " setVolume : No target.");
						return;
					}
					
					var channel:SoundChannel = _channels[name];
					channel.soundTransform.volume = volume;
				}
					break;
			}
		}
		
		public function setPan(target:String, pan:Number, name:String = null):void
		{
			if (!_channels)
			{
				trace(TAG + " setPan : No target.");
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
						trace(TAG + " setPan : No target.");
						return;
					}
					
					var channel:SoundChannel = _channels[name];
					channel.soundTransform.pan = pan;
				}
					break;
			}
		}
		
		private function onEnd(event:Event):void
		{
			var channel:SoundChannel = event.target as SoundChannel;
			
			if (channel)
			{
				channel.removeEventListener(Event.SOUND_COMPLETE, onEnd);
				channel = null;
			}
		}
		
		private function onEndBgm(event:Event):void
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