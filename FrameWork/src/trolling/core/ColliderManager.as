package trolling.core
{
	import trolling.component.physics.Collider;

	public class ColliderManager
	{
		public function ColliderManager()
		{
			
		}
		
		public static function addCollider(collider:Collider):void
		{
			Trolling.current.addCollider(collider);
		}
		
		public static function removeCollider(collider:Collider):void
		{
			Trolling.current.removeCollider(collider);
		}
		
		public static function activate():void
		{
			Trolling.current.colliderActivated = true;
		}
		
		public static function deactivate():void
		{
			Trolling.current.colliderActivated = false;
		}
	}
}