package trolling.component
{
	import trolling.rendering.Texture;
	
	public class DisplayComponent extends Component
	{
		public function DisplayComponent(type:String, name:String)
		{
			super(type, name);
		}
		
		public virtual function getRenderingResource():Texture
		{
			return null;
		}
	}
}