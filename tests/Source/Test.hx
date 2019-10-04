package ;

import openfl.display.Sprite;
import openfl.events.Event;
import haxe.Http;
import visual.*;
import logic.*;

class Test extends Sprite {

	public function new () {
		super (); /* Required */
		addEventListener(Event.ADDED_TO_STAGE, added);
	}

	/* Event of adding to screen */
	private function added (event) {
		removeEventListener(Event.ADDED_TO_STAGE, added);
		testPaddleAI();
		testPaddle();
		testServer();
		testBallLogic();
		trace("done.");
	}

	/* Print failed tests */
	function assert(assertIfNot:Bool, error:String) {
		if(assertIfNot == false) trace("test fail: " + error);
	}

	/* Test AI */
	function testPaddleAI() {
		trace("testing PaddleAI...");
		var paddle = new PaddleMock();
		var ball = new BallMock();
		var ai = new PaddleAI(cast paddle, cast ball);

		ball.y = -100;
		paddle.y = 0;
		ai.move();
		assert(paddle.y < 0, "paddle moved to incorrect position #0");

		ball.z = -100;
		paddle.z = 0;
		ai.move();
		assert(paddle.z < 0, "paddle moved to incorrect position #1");

		ball.y = 100;
		paddle.y = 0;
		ai.move();
		assert(paddle.y > 0, "paddle moved to incorrect position #2");

		ball.z = 100;
		paddle.z = 0;
		ai.move();
		assert(paddle.z > 0, "paddle moved to incorrect position #3");
	}

	/* Test paddle<->ball collisions */
	function testPaddle() {
		trace("testing Paddle...");
		var paddle = new Paddle();
		var ball = new BallMock();

		ball.z = paddle.z = 0; // Z

		ball.x = paddle.x = paddle.y = ball.y = 40;
		assert(paddle.hitTestObject(cast ball) == true, "paddle must hit #0");

		paddle.y = ball.y = 40;
		ball.x = paddle.x = 100;
		assert(paddle.hitTestObject(cast ball) == true, "paddle must hit #1");

		paddle.y = 140;
		ball.y = 40;
		ball.x = paddle.x = 100;
		assert(paddle.hitTestObject(cast ball) == false, "paddle must NOT hit #0");

		paddle.y = ball.y = 10;
		ball.x = 10;
		paddle.x = 100;
		assert(paddle.hitTestObject(cast ball) == false, "paddle must NOT hit #1");

		ball.z = paddle.z = 50; // Z

		ball.x = paddle.x = paddle.y = ball.y = 40;
		assert(paddle.hitTestObject(cast ball) == true, "paddle must hit #2");

		paddle.y = ball.y = 40;
		ball.x = paddle.x = 100;
		assert(paddle.hitTestObject(cast ball) == true, "paddle must hit #3");

		paddle.y = 140;
		ball.y = 40;
		ball.x = paddle.x = 100;
		assert(paddle.hitTestObject(cast ball) == false, "paddle must NOT hit #2");

		paddle.y = ball.y = 10;
		ball.x = 10;
		paddle.x = 100;
		assert(paddle.hitTestObject(cast ball) == false, "paddle must NOT hit #3");
	}

	/* Start ball logic test */
	function testBallLogic() {
		trace("testing BallLogic...");
		new BallLogicTest(assert);
	}

	/* Test scoring server */
	function testServer() {
		trace("testing server...");

		var req = new haxe.Http("http://localhost/scoresave.php");
		req.setParameter("best", "999");
		req.onError = function (error:String) trace(error);
		req.request(true);

		var req = new haxe.Http("http://localhost/scoresave.txt");
		req.onData = function (data:String) assert(Std.parseInt(data) == 999,
		                                         "score value incorrect ("+data+")");
		req.onError = function (error:String) trace(error);
		req.request(false);

		var req = new haxe.Http("http://localhost/scoresave.php");
		req.setParameter("best", "0");
		req.onError = function (error:String) trace(error);
		req.request(true);

		var req = new haxe.Http("http://localhost/scoresave.txt");
		req.onData = function (data:String) assert(Std.parseInt(data) == 0,
		                                         "score value incorrect ("+data+")");
		req.onError = function (error:String) trace(error);
		req.request(false);
	}
}

/* Class mock for spoofing */
class PaddleMock {
	public var x:Float = 0;
	public var y:Float = 0;
	public var z:Float = 240;
	public var height:Float = 100;
	public var width:Float = 10;
	public function new () {}
}

/* Class mock for spoofing */
class BallMock {
	public var x:Float = 0;
	public var y:Float = 0;
	public var z:Float = 240;
	public var width:Float = 16;
	public var height:Float = 16;
	public function new () {}
}

/* Class inherited to access private fields */
class BallLogicTest extends logic.BallLogic
{
	public function new(assert) {
		var enemyPaddle:Paddle = cast new PaddleMock();
		var ball:Ball = cast new BallMock();
		var playerPaddle:Paddle = cast new PaddleMock();
		super(enemyPaddle, ball, playerPaddle);

		/* Checking the function of calculating the new ball speed
		   after a collision with the board */
		var value;
		assert((value = Std.int(recalculateSpeed(0, 10000))) == 5,
		       "recalculateSpeed incorrect value ("+value+") #0");

		assert((value = Std.int(recalculateSpeed(0, -10000))) == -5,
		       "recalculateSpeed incorrect value ("+value+") #1");

		assert((value = Std.int(recalculateSpeed(10000, 0))) == -5,
		       "recalculateSpeed incorrect value ("+value+") #2");

		assert((value = Std.int(recalculateSpeed(-10000, 0))) == 5,
		       "recalculateSpeed incorrect value ("+value+") #3");

		assert((value = Std.int(recalculateSpeed(0, 0))) == 0,
		       "recalculateSpeed incorrect value ("+value+") #4");

		assert((value = Std.int(recalculateSpeed(0, 25))) == 5,
		       "recalculateSpeed incorrect value ("+value+") #5");

		assert((value = Std.int(recalculateSpeed(0, 5))) == 1,
		       "recalculateSpeed incorrect value ("+value+") #6");
	}
}
