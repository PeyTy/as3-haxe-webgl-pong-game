package ;

import openfl.display.Bitmap;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.Assets;

import openfl.display.OpenGLView;
import openfl.geom.Rectangle;
import openfl.geom.Matrix3D;
import openfl.gl.GL;
import haxe.Http;

import visual.*;
import logic.*;

class Main extends Sprite {

	/* Output of OpenGL */
	private var view:OpenGLView;

	/* Screen sizes */
	public static var SCREEN_W = 640;
	public static var SCREEN_H = 480;
	public static var SCREEN_DEPTH = 20.0;

	/* Score texts */
	var playerScoreTxt:ScoreText;
	var playerLivesTxt:ScoreText;

	/* Visual objects */
	var ball = new Ball();
	var playerPaddle = new Paddle();
	var enemyPaddle = new Paddle();

	/* Score amounts */
	public static var playerScore = 0;
	public static var playerLives = 5;
	public static var bestScore = 0;

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

		/* Init GL */
		if (OpenGLView.isSupported) {
			view = new OpenGLView ();
			visual.Walls.init();
			visual.Plane.init();
			view.render = renderView;
			addChild(view);
		}

		/* Place paddles */
		playerPaddle.x = 15;
		enemyPaddle.x = SCREEN_W - 15;

		playerPaddle.y = enemyPaddle.y = SCREEN_H / 2;

		/* Place ball onto screen */
		ball.x = SCREEN_W / 2;
		ball.y = SCREEN_H / 2;

		/* Create logic objects */
		ballLogic = new BallLogic(enemyPaddle, ball, playerPaddle);
		playerLogic = new PaddleControl(playerPaddle, stage);
		enemyLogic = new PaddleAI(enemyPaddle, ball);

		/* Create texts */
		playerScoreTxt = new ScoreText(ScoreText.ALIGN_LEFT);
		playerLivesTxt = new ScoreText(ScoreText.ALIGN_RIGHT);

		playerScoreTxt.x = 0;
		playerScoreTxt.y = 0;

		playerLivesTxt.x = SCREEN_W - playerLivesTxt.width;
		playerLivesTxt.y = 0;

		playerLivesTxt.text = "";
		playerScoreTxt.text = "";

		// download the best result from the server
		var req = new haxe.Http("http://localhost/scoresave.txt");
		req.onData = function (data:String) bestScore = Std.parseInt(data);
		req.onError = function (error:String) bestScore = 0;
		req.request(false);

		/* Start updating */
		addEventListener(Event.ENTER_FRAME, frame);
	}

	/* Action on every frame */
	private function frame (event) {
		if(playerLives < 1) {
			bestScore = Std.int(Math.max(bestScore, playerScore));

			// upload the best result to the server
			var req = new haxe.Http("http://localhost/scoresave.php");
			req.setParameter("best", "" + bestScore);
			req.onError = function (error:String) trace(error);
			req.request(true);

			playerLives = 5;
			playerScore = 0;
		}

		playerLogic.move();
		enemyLogic.move();
		ballLogic.move();
		updateTextFields();
	}

	/* Update score texts */
	function updateTextFields ()
	{
		playerScoreTxt.text = " Player Score: " + playerScore
							+ " Best Score: " + bestScore;
		playerLivesTxt.text = " Player Lives: " + playerLives + " ";
	}

	/* Creates perspective projection matrix */
	public static function perspectiveFieldOfViewLH(fieldOfViewY:Float, // how much to fit
													aspectRatio:Float, // screen format
													zNear:Float, // near limit
													zFar:Float) { // far limit
		var yScale = 1.0/Math.tan(fieldOfViewY/2.0);
		var xScale = yScale / aspectRatio;
		var m = new Matrix3D();
		m.copyRawDataFrom(([
						  xScale, 0.0, 0.0, 0.0,
						  0.0, yScale, 0.0, 0.0,
						  0.0, 0.0, zFar/(zFar-zNear), 1.0,
						  0.0, 0.0, (zNear*zFar)/(zNear-zFar), 0.0
						  ]));
		return m;
	}

	/* Matrix set to current game style */
	public static function perspectiveMatrix() {
		return perspectiveFieldOfViewLH(75, SCREEN_W/SCREEN_H, 0.1, SCREEN_DEPTH);
	}

	/* OpenGL rendering */
	private function renderView (rect:Rectangle):Void {
		// output zone
		GL.viewport(Std.int(rect.x), Std.int(rect.y), Std.int(rect.width), Std.int(rect.height));
		GL.enable(GL.DEPTH_TEST); // depth buffer
		GL.depthFunc(GL.LESS); // crop far planes, overdrawn by near ones
		GL.clearColor (0.0, 0.5, 0.0, 1.0); // screen cleanup (with green color)
		GL.clear(GL.COLOR_BUFFER_BIT | GL.DEPTH_BUFFER_BIT); // clear color buffer
		// and depth

		GL.enable(GL.DEPTH_TEST); // enable depth test
		Walls.draw(ball);
		enemyPaddle.draw();
		ball.draw();
		playerPaddle.draw();

		GL.disable(GL.DEPTH_TEST); // disable depth testing
		// allows to draw text above any geometry
		playerScoreTxt.draw();
		playerLivesTxt.draw();
	}
}
