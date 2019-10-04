package visual;
/* Ball */
import openfl.display.Sprite;

class Ball extends Sprite {

	public function new () {
		/* Rendering */
		super ();
		graphics.beginFill(0xAA5230);
		graphics.drawCircle(-8, -8, 8);
		graphics.endFill();
	}
}
