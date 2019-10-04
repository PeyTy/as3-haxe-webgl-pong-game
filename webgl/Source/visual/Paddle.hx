package visual;
/* Paddle */
import openfl.display.*;
import openfl.gl.*;
import openfl.geom.*;
import openfl.Assets;
import openfl.utils.*;

class Paddle {

	/* Position & size */
	public var x:Float = 0;
	public var y:Float = 0;
	public var z:Float = 240;
	public var height:Float = 100;
	public var width:Float = 10;
	/* Texture - same for both paddles */
	private static var texture:GLTexture;

	public function new () {
		/* Create texture only once */
		if (texture != null) return ;

		var bitmapData = Assets.getBitmapData ("assets/new-05.png");

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
	}

	/* Rendering */
	public function draw () {
		Plane.draw(x, y, z, 0.3, 0.2, texture);
	}

	/* Ball collision check */
	public function hitTestObject (ball:Ball):Bool {
		if(ball.x > x - width/2 && ball.x < x + width/2) // depth
		if(ball.y > y - 1.5*height/2 && ball.y < y + 1.5*height/2)
		if(ball.z > z - height/2 && ball.z < z + height/2)
		return true;

		return false;
	}
}
