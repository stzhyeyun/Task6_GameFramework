package trolling.rendering 
{
	import com.adobe.utils.AGALMiniAssembler;
	
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Program3D;
	
	internal class Program
	{
		private var _vertexShaderAssembler : AGALMiniAssembler;
		private var _fragmentShaderAssembler : AGALMiniAssembler;
		
		private var _vertexShaderAssemblerTemp : AGALMiniAssembler;
		
		private var _fragmentShaderAssembler1 : AGALMiniAssembler;
		private var _fragmentShaderAssembler3 : AGALMiniAssembler;
		
		private var _program:Program3D;
		
		public function Program()
		{	
			_vertexShaderAssembler = new AGALMiniAssembler();
			_vertexShaderAssembler.assemble
				( 
					Context3DProgramType.VERTEX,
					"m44 op, va0, vc0 \n" + 
					"mov v0, va0 \n" + // tell fragment shader about XYZ
					"mov v1, va1 \n" + // tell fragment shader about UV
					"mov v2, va2\n"   // tell fragment shader about RGBA
				);
			
			// textured using UV coordinates AND colored by vertex RGB
			_fragmentShaderAssembler3 = new AGALMiniAssembler();
			_fragmentShaderAssembler3.assemble
				( 
					Context3DProgramType.FRAGMENT,	
					"tex ft0, v1, fs0 <2d,clamp,linear> \n" + 
					"mul ft1, v2, ft0\n" +
					"mov oc, ft1 \n" // move this value to the output color
				);
		}
		
		public function get program():Program3D
		{
			return _program;
		}
		
		public function initProgram(context:Context3D):void
		{
			_program = context.createProgram();
			
			_program.upload( _vertexShaderAssembler.agalcode, _fragmentShaderAssembler3.agalcode);
		}
	}
}