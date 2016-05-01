package trolling.utils
{
	import flash.geom.Point;

	public class Circle
	{
		public var center:Point;
		public var radius:Number;
		
		public function Circle(center:Point, radius:Number)
		{
			this.center = center;
			this.radius = radius
		}
		
		public function containsPoint(point:Point):Boolean
		{
			var dx:Number = this.center.x - point.x;
			var dy:Number = this.center.y - point.y;
			var distance:Number = Math.sqrt(dx * dx + dy * dy);
			
			return (distance <= this.radius)? true : false;
		}
		
		public function intersects(object:Circle):Boolean
		{
			var dx:Number = this.center.x - object.center.x;
			var dy:Number = this.center.y - object.center.y;
			var distance:Number = Math.sqrt(dx * dx + dy * dy);

			return (distance <= this.radius + object.radius)? true : false
		}
	}
}