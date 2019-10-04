package visual {
	/* Visualize scores of player and enemy */
	import flash.display.Sprite;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.text.AntiAliasType;
	import flash.text.TextField;

	public class ScoreText extends Sprite {

		/* Text alignment */
		public static var ALIGN_LEFT = "left";
		public static var ALIGN_RIGHT = "right";

		/* Text fields visuals */
		var textField:TextField;

		public function ScoreText (aligment:String) {

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
			textField.textColor = 0x001122;
			textField.selectable = textField.border = textField.embedFonts = textField.wordWrap = false;
			textField.width = 300;
			textField.height = 25;
			textField.text = "";
			textField.defaultTextFormat = format;
			addChild(textField);
		}

		/* Readonly class field */
		public function set text (value:String) {
			textField.text = value;
		}
	}
}
