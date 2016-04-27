package trolling.component
{
	import flash.display.BitmapData;
	
	import trolling.object.GameObject;
	
	public class DisplayComponent extends Component
	{
		public function DisplayComponent(type:String, name:String, parent:GameObject)
		{
			super(type, name, parent);
		}
		
		public virtual function getRenderingResource():BitmapData
		{
			return null;
		}
	}
}