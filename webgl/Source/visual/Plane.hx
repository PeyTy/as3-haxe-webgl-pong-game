package visual;
/* Textured plane */
import openfl.display.*;
import openfl.gl.*;
import openfl.geom.*;
import openfl.Assets;
import openfl.utils.*;

class Plane {

	/* GL properties & objects */
	// fragment program property - texture
	private static var imageUniform:GLUniformLocation;
	// vertex program property - model matrix
	private static var modelViewMatrixUniform:GLUniformLocation;
	// vertex program property - projection matrix
	private static var projectionMatrixUniform:GLUniformLocation;
	// program
	private static var shaderProgram:GLProgram;
	// vertices properties
	private static var texCoordAttribute:Int;
	private static var texCoordBuffer:GLBuffer;
	private static var vertexAttribute:Int;
	private static var vertexBuffer:GLBuffer;

	/* Init */
	public static function init () {
		// vertices positions
		var vertices = [
			1, 1, 0,
			-1, 1, 0,
			1, -1, 0,
			-1, -1, 0
		];
		// vertices container
		vertexBuffer = GL.createBuffer ();
		GL.bindBuffer (GL.ARRAY_BUFFER, vertexBuffer);
		GL.bufferData (GL.ARRAY_BUFFER, new Float32Array (cast vertices), GL.STATIC_DRAW);
		GL.bindBuffer (GL.ARRAY_BUFFER, null);
		// texture positions
		var texCoords = [
			1, 1,
			0, 1,
			1, 0,
			0, 0
		];
		// texture coordinates buffer
		texCoordBuffer = GL.createBuffer ();
		GL.bindBuffer (GL.ARRAY_BUFFER, texCoordBuffer);
		GL.bufferData (GL.ARRAY_BUFFER, new Float32Array (cast texCoords), GL.STATIC_DRAW);
		GL.bindBuffer (GL.ARRAY_BUFFER, null);

		// vertex program
		var vertexShaderSource = "
			attribute vec3 aVertexPosition;
			attribute vec2 aTexCoord;

			varying vec2 vTexCoord;

			uniform mat4 uModelViewMatrix;
			uniform mat4 uProjectionMatrix;

			void main(void) {
				vTexCoord = aTexCoord;
				gl_Position = uProjectionMatrix * uModelViewMatrix * vec4 (aVertexPosition, 1.0);
			}
		";
		var vertexShader = GL.createShader (GL.VERTEX_SHADER);
		GL.shaderSource (vertexShader, vertexShaderSource);
		GL.compileShader (vertexShader);
		if (GL.getShaderParameter (vertexShader, GL.COMPILE_STATUS) == 0) {
			throw "Error compiling vertex shader";
		}
		// fragment (pixel) program
		var fragmentShaderSource =
		#if !desktop
		"precision mediump float;" +
		#end
		"
			varying vec2 vTexCoord;
			uniform sampler2D uImage0;

			void main(void)
			{"
				#if lime_legacy
				+ "gl_FragColor = texture2D (uImage0, vTexCoord).gbar;" +
				#else
				+ "gl_FragColor = texture2D (uImage0, vTexCoord);" +
				#end "
			}
		";
		var fragmentShader = GL.createShader (GL.FRAGMENT_SHADER);
		GL.shaderSource (fragmentShader, fragmentShaderSource);
		GL.compileShader (fragmentShader);
		if (GL.getShaderParameter (fragmentShader, GL.COMPILE_STATUS) == 0) {
			throw "Error compiling fragment shader";
		}
		// link program
		shaderProgram = GL.createProgram ();
		GL.attachShader (shaderProgram, vertexShader);
		GL.attachShader (shaderProgram, fragmentShader);
		GL.linkProgram (shaderProgram);
		if (GL.getProgramParameter (shaderProgram, GL.LINK_STATUS) == 0) {
			throw "Unable to initialize the shader program.";
		}
		// get pointers to attributes
		vertexAttribute = GL.getAttribLocation (shaderProgram, "aVertexPosition");
		texCoordAttribute = GL.getAttribLocation (shaderProgram, "aTexCoord");
		projectionMatrixUniform = GL.getUniformLocation (shaderProgram, "uProjectionMatrix");
		modelViewMatrixUniform = GL.getUniformLocation (shaderProgram, "uModelViewMatrix");
		imageUniform = GL.getUniformLocation (shaderProgram, "uImage0");
	}

	/* Rendering */
	public static function draw (x:Float, y:Float, z:Float, w:Float, h:Float, texture:GLTexture) {
		var projectionMatrix = Main.perspectiveMatrix();
		GL.blendFunc(GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA); // color mixing
		GL.blendColor(1, 1, 1, 1); // set the color mixing coefficients
		GL.blendEquation( GL.FUNC_ADD ); // function of blending on top of existing color
		GL.colorMask(true, true, true, true); // enable the recording of colors and alpha
		GL.enable(GL.BLEND); // activation of the color mixing mechanism

		// model matrix
		var modelViewMatrix = new Matrix3D();
		modelViewMatrix.identity();
		modelViewMatrix.appendScale(w, h, 1);
		modelViewMatrix.appendTranslation(
		                                  -(-1 + 2 * z/Main.SCREEN_W),
		                                  -1 + 2 * y/Main.SCREEN_H,
		                                  3.95 + (Main.SCREEN_DEPTH - 4) * x/Main.SCREEN_W);

		// setting up the GL state machine for rendering
		GL.useProgram (shaderProgram);
		GL.enableVertexAttribArray (vertexAttribute);
		GL.enableVertexAttribArray (texCoordAttribute);
		GL.activeTexture (GL.TEXTURE0);
		GL.bindTexture (GL.TEXTURE_2D, texture);
		#if desktop
		GL.enable (GL.TEXTURE_2D);
		#end
		GL.bindBuffer (GL.ARRAY_BUFFER, vertexBuffer);
		GL.vertexAttribPointer (vertexAttribute, 3, GL.FLOAT, false, 0, 0);
		GL.bindBuffer (GL.ARRAY_BUFFER, texCoordBuffer);
		GL.vertexAttribPointer (texCoordAttribute, 2, GL.FLOAT, false, 0, 0);
		GL.uniformMatrix4fv (projectionMatrixUniform, false, new Float32Array (projectionMatrix.rawData));
		GL.uniformMatrix4fv (modelViewMatrixUniform, false, new Float32Array (modelViewMatrix.rawData));
		GL.uniform1i (imageUniform, 0);

		GL.drawArrays (GL.TRIANGLE_STRIP, 0, 4); // actual rendering

		// states cleanup
		GL.bindBuffer (GL.ARRAY_BUFFER, null);
		GL.bindTexture (GL.TEXTURE_2D, null);
		#if desktop
		GL.disable (GL.TEXTURE_2D);
		#end
		GL.disableVertexAttribArray (vertexAttribute);
		GL.disableVertexAttribArray (texCoordAttribute);
		GL.useProgram (null);

		GL.disable(GL.BLEND); // disable blending
	}
}
