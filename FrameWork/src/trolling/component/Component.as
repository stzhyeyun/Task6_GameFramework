package trolling.component
{
	import trolling.object.GameObject;
	
	public class Component
	{		
		private var _type:String;
		protected var _parent:GameObject;
		protected var _isActive:Boolean;
		
		public function Component(type:String, isActive:Boolean = false)
		{
			_type = type;
			_isActive = isActive;
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