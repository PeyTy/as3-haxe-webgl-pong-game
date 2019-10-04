package ;

import openfl.display.Bitmap;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.Assets;

import visual.*;
import logic.*;

class Main extends Sprite {

	/* Screen sizes */
	public static var SCREEN_W = 640;
	public static var SCREEN_H = 480;

	/* Score texts */
	var playerScoreTxt:ScoreText;
	var enemyScoreTxt:ScoreText;

	/* Visual objects */
	var ball = new Ball();
	var playerPaddle = new Paddle();
	var enemyPaddle = new Paddle();

	/* Score amounts */
	public static var playerScore = 0;
	public static var enemyScore = 0;

	/* Logic objects */
	var ballLogic:logic.BallLogic;
	var playerLogic:logic.PaddleControl;
	var enemyLogic:logic.PaddleAI;

	public function new () {
		super (); /* Required */
		addEventListener(Event.ADDED_TO_STAGE, added);
	}

	/* Event of adding to screen */
	private function added (event) {
		removeEventListener(Event.ADDED_TO_STAGE, added);

		/* Set smooth frame rate */
		stage.frameRate = 60;

		/* Background obtained by OpenFL */
		var bitmap = new Bitmap (Assets.getBitmapData ("assets/openfl.png"));
		addChild (bitmap);

		bitmap.x = (stage.stageWidth - bitmap.width) / 2;
		bitmap.y = (stage.stageHeight - bitmap.height) / 2;

		/* Place paddles */
		playerPaddle.x = 15;
		enemyPaddle.x = SCREEN_W - 15;

		playerPaddle.y = enemyPaddle.y = SCREEN_H / 2;

		addChild(playerPaddle);
		addChild(enemyPaddle);

		/* Place ball onto screen */
		ball.x = SCREEN_W / 2;
		ball.y = SCREEN_H / 2;

		addChild(ball);

		/* Create logic objects */
		ballLogic = new BallLogic(enemyPaddle, ball, playerPaddle);
		playerLogic = new PaddleControl(playerPaddle);
		enemyLogic = new PaddleAI(enemyPaddle, ball);

		/* Create texts */
		playerScoreTxt = new ScoreText(ScoreText.ALIGN_LEFT);
		enemyScoreTxt = new ScoreText(ScoreText.ALIGN_RIGHT);

		playerScoreTxt.x = 0;
		playerScoreTxt.y = 0;

		enemyScoreTxt.x = SCREEN_W - enemyScoreTxt.width;
		enemyScoreTxt.y = 0;

		enemyScoreTxt.text = "";
		playerScoreTxt.text = "";

		addChild(enemyScoreTxt);
		addChild(playerScoreTxt);

		/* Start updating */
		addEventListener(Event.ENTER_FRAME, frame);
	}

	/* Action on every frame */
	private function frame (event) {
		playerLogic.move();
		enemyLogic.move();
		ballLogic.move();
		updateTextFields();
	}

	/* Update score texts */
	function updateTextFields ()
	{
		playerScoreTxt.text = " Player Score: " + playerScore + " ";
		enemyScoreTxt.text = " Enemy Score: " + enemyScore + " ";
	}
}
