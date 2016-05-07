package trolling.core
{
	import trolling.component.physics.Collider;
	import trolling.event.TrollingEvent;
	
	internal class ColliderManager
	{
		private const TAG:String = "[ColliderManager]";
		
		private var _colliders:Vector.<Collider>;
		
		public function ColliderManager()
		{
			
		}
		
		/**
		 * ColliderManager에 Collider를 등록합니다. 
		 * @param collider 등록하고자 하는 Collider입니다.
		 * 
		 */
		public function addCollider(collider:Collider):void
		{
			if (!_colliders)
			{
				_colliders = new Vector.<Collider>();
			}
			_colliders.push(collider);
		}
		
		/**
		 * ColliderManager에서 Collider를 제거합니다. 
		 * @param collider 제거하고자 하는 Collider입니다.
		 * 
		 */
		public function removeCollider(collider:Collider):void
		{
			if (!_colliders || !collider)
			{
				return;
			}
			
			for (var i:int = 0; i < _colliders.length; i++)
			{
				if (_colliders[i] == collider)
				{
					_colliders.removeAt(i);
					break;
				}
			}
		}
		
		/**
		 * 등록된 Collider에 대해 충돌 검사를 수행합니다. 충돌한 Collider를 가진 GameObject에게는 충돌 대상(GameObject)에 대한 정보를 포함하는 충돌 이벤트를 dispatch합니다.
		 * 
		 */
		public function detectCollision():void
		{
			if (!_colliders || _colliders.length <= 1)
			{
				return;
			}
			
			var index:int = 0;
			var collidedIndices:Vector.<int>;
			var detectionObjects:Vector.<Collider> = new Vector.<Collider>();
			for (var i:int = 0; i < _colliders.length; i++)
			{
				detectionObjects.push(_colliders[i]);	
			}
			
			if (!detectionObjects)
			{
				throw new ArgumentError(TAG + " detectCollision : Failed to clone Colliders.");
			}
			
			while (index < detectionObjects.length - 1)
			{
				for (var i:int = index + 1; i < detectionObjects.length; i++)
				{
					if (detectionObjects[index].isCollision(detectionObjects[i]))
					{
						// Dispatch event
						detectionObjects[index].parent.dispatchEvent(
							new TrollingEvent(TrollingEvent.COLLIDE, detectionObjects[i].parent));
						detectionObjects[i].parent.dispatchEvent(
							new TrollingEvent(TrollingEvent.COLLIDE, detectionObjects[index].parent));
						
						// Store collided objects' indices for deletion from detectionObjects
						if (!collidedIndices)
						{
							collidedIndices = new Vector.<int>();
						}
						collidedIndices.push(i);
					}
				}
				
				// Remove collided objects from detectionObjects
				if (collidedIndices)
				{
					for (var j:int = collidedIndices.length - 1; j >= 0; j--)
					{
						detectionObjects.removeAt(collidedIndices[j]);
					}
				}
				collidedIndices = null;

				index++;
			}
			
			collidedIndices = null;
			detectionObjects = null;
		}
	}
}
