package trolling.rendering 
{
	import com.adobe.utils.AGALMiniAssembler;
	
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Program3D;
	
	public class Program
	{
		private var _vertexShaderAssembler : AGALMiniAssembler;
		private var _fragmentShaderAssembler : AGALMiniAssembler;
		
		private var _vertexShaderAssemblerTemp : AGALMiniAssembler;
		private var _fragmentShaderAssemblerTemp : AGALMiniAssembler;
		
		private var _program:Program3D;
		
		public function Program()
		{	
			_vertexShaderAssembler = new AGALMiniAssembler();
			_vertexShaderAssembler.assemble( Context3DProgramType.VERTEX,
				// Apply draw matrix (object -> clip space)
				"m44 op, va0, vc0\n" +
				
				// Scale texture coordinate and copy to varying
				"mov vt0, va1\n" +
				"div vt0.xy, vt0.xy, vc4.xy\n" +
				"mov v0, vt0\n"
			);
			
			_fragmentShaderAssembler = new AGALMiniAssembler();
			_fragmentShaderAssembler.assemble( Context3DProgramType.FRAGMENT,
				"tex oc, v0, fs0 <2d,linear,mipnone,clamp>"
			);
		}
		
		public function get program():Program3D
		{
			return _program;
		}
		
		public function initProgram(context:Context3D):void
		{
			_program = context.createProgram();
			
			_program.upload( _vertexShaderAssembler.agalcode, _fragmentShaderAssembler.agalcode);
		}
	}
}