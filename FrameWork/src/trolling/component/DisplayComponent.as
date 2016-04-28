package trolling.component
{
	import trolling.rendering.Texture;
	
	public class DisplayComponent extends Component
	{
		public function DisplayComponent(type:String, isActive:Boolean = false)
		{
			super(type, isActive);
		}
		
		public virtual function getRenderingResource():Texture
		{
			return null;
		}
	}
}