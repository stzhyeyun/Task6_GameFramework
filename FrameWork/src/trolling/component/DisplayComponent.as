package trolling.component
{
	import flash.display3D.textures.Texture;
	
	import trolling.object.GameObject;
	
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