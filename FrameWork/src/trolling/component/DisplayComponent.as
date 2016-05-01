package trolling.component
{
	import trolling.rendering.Texture;
	
	public class DisplayComponent extends Component
	{
		public function DisplayComponent(type:String)
		{
			super(type);
		}
		
		public virtual function getRenderingResource():Texture
		{
			return null;
		}
	}
}