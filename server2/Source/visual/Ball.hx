package visual;
/* Ball */
import openfl.display.*;
import openfl.gl.*;
import openfl.geom.*;
import openfl.Assets;
import openfl.utils.*;

class Ball {

	/* Position & size */
	public var x:Float = 0;
	public var y:Float = 0;
	public var z:Float = 240;
	public var width:Float = 16;
	public var height:Float = 16;

	/* GL properties & objects */
	// texture image
	private var bitmapData:BitmapData;
	// graphics program (shader) parameters
	private var imageUniform:GLUniformLocation;
	private var modelViewMatrixUniform:GLUniformLocation;
	private var projectionMatrixUniform:GLUniformLocation;
	private var shaderProgram:GLProgram;
	private var texCoordAttribute:Int;
	private var texCoordBuffer:GLBuffer;
	// texture
	private var texture:GLTexture;
	// vertex attributes
	private var vertexAttribute:Int;
	private var vertexBuffer:GLBuffer;

	public function new () {
		// loading picture using OpenFL tools
		bitmapData = Assets.getBitmapData ("assets/divine.png");

		// texture creation
		#if lime
		var pixelData = @:privateAccess (bitmapData.__image).data;
		#else
		var pixelData = new UInt8Array (bitmapData.getPixels (bitmapData.rect));
		#end
		texture = GL.createTexture();
		GL.bindTexture(GL.TEXTURE_2D, texture);
		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.CLAMP_TO_EDGE);
		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.CLAMP_TO_EDGE);
		GL.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA,
		               bitmapData.width, bitmapData.height,
		               0, GL.RGBA, GL.UNSIGNED_BYTE, pixelData);
		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.LINEAR);
		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.LINEAR);
		GL.bindTexture(GL.TEXTURE_2D, null);

		// vertices - coordinates
		var vertices = [
			1, 1, 0,
			-1, 1, 0,
			1, -1, 0,
			-1, -1, 0
		];
		// vertex buffer creation
		vertexBuffer = GL.createBuffer ();
		GL.bindBuffer (GL.ARRAY_BUFFER, vertexBuffer);
		GL.bufferData (GL.ARRAY_BUFFER, new Float32Array (cast vertices), GL.STATIC_DRAW);
		GL.bindBuffer (GL.ARRAY_BUFFER, null);
		// vertices - texture positions
		var texCoords = [
			1, 1,
			0, 1,
			1, 0,
			0, 0
		];
		// buffer creation
		texCoordBuffer = GL.createBuffer ();
		GL.bindBuffer (GL.ARRAY_BUFFER, texCoordBuffer);
		GL.bufferData (GL.ARRAY_BUFFER, new Float32Array (cast texCoords), GL.STATIC_DRAW);
		GL.bindBuffer (GL.ARRAY_BUFFER, null);

		// vertex code
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
		// compilation
		var vertexShader = GL.createShader (GL.VERTEX_SHADER);
		GL.shaderSource (vertexShader, vertexShaderSource);
		GL.compileShader (vertexShader);
		if (GL.getShaderParameter (vertexShader, GL.COMPILE_STATUS) == 0) {
			throw "Error compiling vertex shader";
		}
		// fragment program code
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
				gl_FragColor.a = gl_FragColor.r;
			}
		";
		// compilation
		var fragmentShader = GL.createShader (GL.FRAGMENT_SHADER);
		GL.shaderSource (fragmentShader, fragmentShaderSource);
		GL.compileShader (fragmentShader);
		if (GL.getShaderParameter (fragmentShader, GL.COMPILE_STATUS) == 0) {
			throw "Error compiling fragment shader";
		}
		// assembly into a single program
		shaderProgram = GL.createProgram ();
		GL.attachShader (shaderProgram, vertexShader);
		GL.attachShader (shaderProgram, fragmentShader);
		GL.linkProgram (shaderProgram);
		if (GL.getProgramParameter (shaderProgram, GL.LINK_STATUS) == 0) {
			throw "Unable to initialize the shader program.";
		}
		// getting pointers to attributes and program parameters
		vertexAttribute = GL.getAttribLocation (shaderProgram, "aVertexPosition");
		texCoordAttribute = GL.getAttribLocation (shaderProgram, "aTexCoord");
		projectionMatrixUniform = GL.getUniformLocation (shaderProgram, "uProjectionMatrix");
		modelViewMatrixUniform = GL.getUniformLocation (shaderProgram, "uModelViewMatrix");
		imageUniform = GL.getUniformLocation (shaderProgram, "uImage0");
	}

	/* Rendering */
	public function draw () {
		var projectionMatrix = Main.perspectiveMatrix();
		// activate the depth test and color mixing (transparency)
		GL.enable(GL.DEPTH_TEST);
		GL.blendFunc(GL.SRC_ALPHA, GL.ONE);
		GL.enable(GL.BLEND);

		// build the model matrix
		var modelViewMatrix = new Matrix3D();
		modelViewMatrix.identity();
		var sc = 0.2;
		modelViewMatrix.appendScale(sc, sc, 1);
		modelViewMatrix.appendTranslation(
		                                  -(-1 + 2 * z/Main.SCREEN_W),
		                                  -1 + 2 * y/Main.SCREEN_H,
		                                  3.95 + (Main.SCREEN_DEPTH - 4) * x/Main.SCREEN_W);
		// activate the program and set attributes with parameters
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

		GL.drawArrays (GL.TRIANGLE_STRIP, 0, 4); // let's draw

		// clear the state of the GL pipeline
		GL.bindBuffer (GL.ARRAY_BUFFER, null);
		GL.bindTexture (GL.TEXTURE_2D, null);
		#if desktop
		GL.disable (GL.TEXTURE_2D);
		#end
		GL.disableVertexAttribArray (vertexAttribute);
		GL.disableVertexAttribArray (texCoordAttribute);
		GL.useProgram (null);

		GL.disable(GL.BLEND);
	}
}
