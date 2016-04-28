package trolling.component
{
	import trolling.object.GameObject;
	import trolling.rendering.Texture;
	
	public class DisplayComponent extends Component
	{
		public function DisplayComponent(type:String, name:String, parent:GameObject)
		{
			super(type, name, parent);
		}
		
		public virtual function getRenderingResource():Texture
		{
			return null;
		}
	}
}