package trolling.component
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import trolling.object.GameObject;
	
	public class Component extends EventDispatcher
	{		
		private var _type:String;
		protected var _parent:GameObject;
		protected var _isActive:Boolean;
		
		public function Component(type:String)
		{
			_type = type;
			_isActive = true;
		}
		
		public function dispose():void
		{
			_type = null;
			_parent = null;
			_isActive = false;
		}
		
		public function get type():String
		{
			return _type;
		}
		
		public function get parent():GameObject
		{
			return _parent;
		}
		
		public virtual function set parent(value:GameObject):void
		{
			_parent = value;
		}
		
		public function get isActive():Boolean
		{
			return _isActive;
		}
		
		public virtual function set isActive(value:Boolean):void
		{
			_isActive = value;
		}
		
		protected virtual function onNextFrame(event:Event):void
		{
			// Empty
		}
		
		protected virtual function onActivateScene(event:Event):void
		{
			// Empty
		}
		
		protected virtual function onDeactivateScene(event:Event):void
		{
			// Empty
		}
	}
}