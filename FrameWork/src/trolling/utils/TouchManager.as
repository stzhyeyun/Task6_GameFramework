package trolling.utils
{
	import flash.geom.Point;
	
	import trolling.object.GameObject;

	public class TouchManager
	{
		private const MAX_POINT_LENGT:uint = 10;
		
		private var _hoverFlag:Boolean;
		private var _hoverTarget:GameObject = null;
		private var _points:Vector.<Point>;
		
		public function TouchManager()
		{
			initPoints();
		}
		
		public function pushPoint(value:Point):void
		{
			if(_points.length >= MAX_POINT_LENGT)
			{
				_points.shift();
			}
			_points.push(value);
		}
		
		public function initPoints():void
		{
			_points = new Vector.<Point>();
		}

		public function get points():Vector.<Point>
		{
			return _points.reverse();
		}

		public function get hoverTarget():GameObject
		{
			return _hoverTarget;
		}

		public function set hoverTarget(value:GameObject):void
		{
			_hoverTarget = value;
		}

		public function get hoverFlag():Boolean
		{
			return _hoverFlag;
		}

		public function set hoverFlag(value:Boolean):void
		{
			_hoverFlag = value;
		}
	}
}