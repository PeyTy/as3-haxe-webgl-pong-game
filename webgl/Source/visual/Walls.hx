package visual;
/* Walls */
import openfl.display.*;
import openfl.gl.*;
import openfl.geom.*;
import openfl.Assets;
import openfl.utils.*;

class Walls {

	private static var bitmapData:BitmapData;
	private static var imageUniform:GLUniformLocation;
	private static var modelViewMatrixUniform:GLUniformLocation;
	private static var projectionMatrixUniform:GLUniformLocation;
	private static var ballPosUniform:GLUniformLocation;
	private static var shaderProgram:GLProgram;
	private static var texCoordAttribute:Int;
	private static var texCoordBuffer:GLBuffer;
	private static var texture:GLTexture;
	private static var view:OpenGLView;
	private static var vertexAttribute:Int;
	private static var vertexBuffer:GLBuffer;

	public static function init () {
		bitmapData = Assets.getBitmapData ("assets/openfl.png");

		#if lime
		var pixelData = @:privateAccess (bitmapData.__image).data;
		#else
		var pixelData = new UInt8Array (bitmapData.getPixels (bitmapData.rect));
		#end
		texture = GL.createTexture ();
		GL.bindTexture (GL.TEXTURE_2D, texture);
		GL.texParameteri (GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.CLAMP_TO_EDGE);
		GL.texParameteri (GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.CLAMP_TO_EDGE);
		GL.texImage2D (GL.TEXTURE_2D, 0, GL.RGBA, bitmapData.width, bitmapData.height, 0, GL.RGBA, GL.UNSIGNED_BYTE, pixelData);
		GL.texParameteri (GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.LINEAR);
		GL.texParameteri (GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.LINEAR);
		GL.bindTexture (GL.TEXTURE_2D, null);

		var vertices = [
			1, 1, 0,
			-1, 1, 0,
			1, -1, 0,
			-1, -1, 0
		];
		vertexBuffer = GL.createBuffer ();
		GL.bindBuffer (GL.ARRAY_BUFFER, vertexBuffer);
		GL.bufferData (GL.ARRAY_BUFFER, new Float32Array (cast vertices), GL.STATIC_DRAW);
		GL.bindBuffer (GL.ARRAY_BUFFER, null);
		var texCoords = [
			1, 1,
			0, 1,
			1, 0,
			0, 0
		];
		texCoordBuffer = GL.createBuffer ();
		GL.bindBuffer (GL.ARRAY_BUFFER, texCoordBuffer);
		GL.bufferData (GL.ARRAY_BUFFER, new Float32Array (cast texCoords), GL.STATIC_DRAW);
		GL.bindBuffer (GL.ARRAY_BUFFER, null);

		var vertexShaderSource =
		"	attribute vec3 aVertexPosition;
			attribute vec2 aTexCoord;
			varying vec2 vTexCoord;
			varying vec3 vPos;
			uniform mat4 uModelViewMatrix;
			uniform mat4 uProjectionMatrix;
			void main(void) {
			vTexCoord = aTexCoord;
			vPos = (uModelViewMatrix * vec4 (aVertexPosition, 1.0)).xyz;
			gl_Position = uProjectionMatrix * uModelViewMatrix * vec4 (aVertexPosition, 1.0);
		}";
		var vertexShader = GL.createShader (GL.VERTEX_SHADER);
		GL.shaderSource (vertexShader, vertexShaderSource);
		GL.compileShader (vertexShader);
		if (GL.getShaderParameter (vertexShader, GL.COMPILE_STATUS) == 0) {
			throw "Error compiling vertex shader";
		}
		var fragmentShaderSource =
		#if !desktop
		"precision mediump float;" +
		#end
		"	varying vec2 vTexCoord;
			varying vec3 vPos;
			uniform sampler2D uImage0;
			uniform vec3 uBallPos;
			void main(void)
			{"
			#if lime_legacy
			+ "gl_FragColor = texture2D (uImage0, vTexCoord).gbar;" +
			#else
			+ "gl_FragColor = texture2D (uImage0, vTexCoord);" +
			#end
			"gl_FragColor.a = 1.0;" +
			"
			float distance = length(uBallPos - vPos.xyz);
			gl_FragColor.rgb *= (1.0 - distance + 1.0) / 2.0;
			" +
		"}";
		var fragmentShader = GL.createShader (GL.FRAGMENT_SHADER);
		GL.shaderSource (fragmentShader, fragmentShaderSource);
		GL.compileShader (fragmentShader);
		if (GL.getShaderParameter (fragmentShader, GL.COMPILE_STATUS) == 0) {
			throw "Error compiling fragment shader";
		}
		shaderProgram = GL.createProgram ();
		GL.attachShader (shaderProgram, vertexShader);
		GL.attachShader (shaderProgram, fragmentShader);
		GL.linkProgram (shaderProgram);
		if (GL.getProgramParameter (shaderProgram, GL.LINK_STATUS) == 0) {
			throw "Unable to initialize the shader program.";
		}
		vertexAttribute = GL.getAttribLocation (shaderProgram, "aVertexPosition");
		texCoordAttribute = GL.getAttribLocation (shaderProgram, "aTexCoord");
		projectionMatrixUniform = GL.getUniformLocation (shaderProgram, "uProjectionMatrix");
		modelViewMatrixUniform = GL.getUniformLocation (shaderProgram, "uModelViewMatrix");
		ballPosUniform = GL.getUniformLocation (shaderProgram, "uBallPos");
		imageUniform = GL.getUniformLocation (shaderProgram, "uImage0");
	}

	public static function draw (ball:Ball) {
		var projectionMatrix = Main.perspectiveMatrix();

		// wall rendering
		function drawWall(modelViewMatrix) {
			GL.uniformMatrix4fv (modelViewMatrixUniform, false, new Float32Array (modelViewMatrix.rawData));
			GL.drawArrays (GL.TRIANGLE_STRIP, 0, 4);
		}

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
		GL.uniform1i (imageUniform, 0);

		// set the coordinates of the ball (as a light source)
		GL.uniform3f(ballPosUniform,
			-(-1 + 2 * ball.z/Main.SCREEN_W),
			-1 + 2 * ball.y/Main.SCREEN_H,
			3.95 + (Main.SCREEN_DEPTH - 4) * ball.x/Main.SCREEN_W
		);

		// farest wall
		var modelViewMatrix = new Matrix3D();
		modelViewMatrix.identity();
		modelViewMatrix.appendScale(-1, 1, 1);
		modelViewMatrix.appendTranslation(0 + 0.25, 0, 19.9);
		drawWall(modelViewMatrix);

		// left
		var modelViewMatrix = new Matrix3D();
		modelViewMatrix.identity();
		modelViewMatrix.appendScale(-10, 1, 1);
		modelViewMatrix.appendRotation(-90, Vector3D.Y_AXIS, Vector3D.X_AXIS);
		modelViewMatrix.appendTranslation(-2.0 + 0.25, 0, 10);
		drawWall(modelViewMatrix);

		// right
		var modelViewMatrix = new Matrix3D();
		modelViewMatrix.identity();
		modelViewMatrix.appendScale(10, 1, 1);
		modelViewMatrix.appendRotation(-90, Vector3D.Y_AXIS, Vector3D.X_AXIS);
		modelViewMatrix.appendTranslation(0 + 0.25, 0, 10);
		drawWall(modelViewMatrix);

		// bottom
		var modelViewMatrix = new Matrix3D();
		modelViewMatrix.identity();
		modelViewMatrix.appendScale(1, 10, 1);
		modelViewMatrix.appendRotation(-90, Vector3D.X_AXIS, Vector3D.X_AXIS);
		modelViewMatrix.appendTranslation(-1 + 0.25, -1, 10);
		drawWall(modelViewMatrix);

		// upper
		var modelViewMatrix = new Matrix3D();
		modelViewMatrix.identity();
		modelViewMatrix.appendScale(1, 10, 1);
		modelViewMatrix.appendRotation(-90, Vector3D.X_AXIS, Vector3D.X_AXIS);
		modelViewMatrix.appendTranslation(-1 + 0.25, 1, 10);
		drawWall(modelViewMatrix);

		// states cleanup
		GL.bindBuffer (GL.ARRAY_BUFFER, null);
		GL.bindTexture (GL.TEXTURE_2D, null);
		#if desktop
		GL.disable (GL.TEXTURE_2D);
		#end
		GL.disableVertexAttribArray (vertexAttribute);
		GL.disableVertexAttribArray (texCoordAttribute);
		GL.useProgram (null);
	}
}
