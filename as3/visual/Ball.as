package visual {
	/* Ball */
	import flash.display.Sprite;

	public class Ball extends Sprite {

		public function Ball () {
			/* Rendering */
			graphics.beginFill(0xAA5230);
			graphics.drawCircle(-8, -8, 8);
			graphics.endFill();
		}
	}
}
