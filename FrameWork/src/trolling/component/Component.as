package trolling.component
{
	import flash.events.EventDispatcher;
	
	import trolling.object.GameObject;
	
	public class Component extends EventDispatcher
	{		
		private var _type:String;
		protected var _name:String;
		protected var _parent:GameObject;
		protected var _isActive:Boolean;
		
		public function Component(type:String, name:String, parent:GameObject)
		{
			_type = type;
			_name = name;
			_parent = parent;
			_isActive = false;
		}
		
		public function dispose():void
		{
			_name = null;
			_type = null;
			_parent = null;
			_isActive = false;
		}
		
		public function get type():String
		{
			return _type;
		}
		
		public function get name():String
		{
			return _name;
		}
		
		public function set name(value:String):void
		{
			_name = value;
		}
		
		public function get parent():GameObject
		{
			return _parent;
		}
		
		public function set parent(value:GameObject):void
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
	}
}