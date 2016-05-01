package trolling.core
{

	public class SceneManager
	{
		public function SceneManager()
		{
		}
		
		public static function addScene(scene:Class, key:String):void
		{
			Trolling.current.addScene(scene, key);
		}
		
		public static function switchScene(key:String):void
		{
			Trolling.current.switchScene(key);
		}
	}
}