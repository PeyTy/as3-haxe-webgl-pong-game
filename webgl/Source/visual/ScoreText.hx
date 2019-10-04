package visual;
/* Visualize scores of player and enemy */
import openfl.display.*;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;
import openfl.text.AntiAliasType;
import openfl.text.TextField;

import openfl.gl.*;
import openfl.geom.*;
import openfl.utils.*;

class ScoreText {

	/* Text alignment */
	public static var ALIGN_LEFT = "left";
	public static var ALIGN_RIGHT = "right";

	/* Text fields visuals */
	var textField:TextField;
	public var width(get,null):Float;
	private var texture:GLTexture;

	public function new (aligment:String) {

		/* Font */
		var format = new TextFormat();
		format.font = "Arial";
		format.size = 15;
		if(aligment == ALIGN_LEFT)
			format.align = TextFormatAlign.LEFT;
		else
			format.align = TextFormatAlign.RIGHT;

		/* Text field creation */
		textField = new TextField();
		textField.textColor = 0x00000000;
		textField.selectable = textField.border = textField.embedFonts = textField.wordWrap = false;
		textField.width = 300;
		textField.height = 25;
		textField.text = "";
		textField.defaultTextFormat = format;
	}

	/* Readonly class field */
	public var text(null, set):String;
	/* Setter implementation */
	public function set_text (value:String):String {
		textField.text = value;

		/* (Re)creation of texture from text */
		if(texture != null) GL.deleteTexture(texture);

		var bitmapData = new BitmapData(
		Math.round(textField.width),
		Math.round(textField.height),
		true, 0x00000000);
		bitmapData.draw(textField);

		var invertTransform:ColorTransform = new ColorTransform(-1,-1,-1,1,255,255,255,0);
		bitmapData.colorTransform(bitmapData.rect, invertTransform);

		#if lime
		var pixelData = @:privateAccess (bitmapData.__image).data;
		#else
		var pixelData = new UInt8Array (bitmapData.getPixels (bitmapData.rect));
		#end
		// create texture
		texture = GL.createTexture ();
		// make texture active
		GL.bindTexture(GL.TEXTURE_2D, texture);
		// set texture sampling
		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.CLAMP_TO_EDGE);
		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.CLAMP_TO_EDGE);
		// upload pixels
		GL.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA,
		               bitmapData.width, bitmapData.height,
		               0, GL.RGBA, GL.UNSIGNED_BYTE, pixelData);
		// set linear filtering (pixel interpolation)
		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.LINEAR);
		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.LINEAR);
		// deactivate texture
		GL.bindTexture(GL.TEXTURE_2D, null);

		return value;
	}

	/* Text width property */
	public function get_width ():Float {
		return textField.width;
	}

	/* Position */
	public var x:Float;
	public var y:Float;

	/* Rendering */
	public function draw () {
		if(texture == null) text = ""; // force texture creation
		Plane.draw(65, y, x + textField.width/2, -2*textField.width/Main.SCREEN_W, 2*textField.height/Main.SCREEN_H, texture);
	}
}
