package logic {
	/* Ball logic */
	import visual.Paddle;
	import visual.Ball;

	public class BallLogic {

		/* Ball speed */
		var ballSpeedX:Number = -3;
		var ballSpeedY:Number = -2;
		var ball:Ball;
		var enemyPaddle:Paddle;
		var playerPaddle:Paddle;

		public function BallLogic (enemyPaddle:Paddle, ball:Ball, playerPaddle:Paddle) {
			this.playerPaddle = playerPaddle;
			this.enemyPaddle = enemyPaddle;
			this.ball = ball;
		}

		/* Action on every frame */
		public function move () {

			/* Check ball collision with paddle */
			if( playerPaddle.hitTestObject(ball) == true ){
			if(ballSpeedX < 0){
				ballSpeedX *= -1;
				ballSpeedY = recalculateSpeed(playerPaddle.y, ball.y);
			}

			} else if(enemyPaddle.hitTestObject(ball) == true ){
				if(ballSpeedX > 0){
					ballSpeedX *= -1;
					ballSpeedY = recalculateSpeed(enemyPaddle.y, ball.y);
				}
			}

			/* Move ball on current frame */
			ball.x += ballSpeedX;
			ball.y += ballSpeedY;

			/* Reflect the ball from the right and left edges of the screen */
			/* And increase the score to the winner */
			if(ball.x <= ball.width/2){
				ball.x = ball.width/2;
				ballSpeedX *= -1;
				Main.enemyScore ++;
			} else if(ball.x >= Main.SCREEN_W-ball.width/2){
				ball.x = Main.SCREEN_W-ball.width/2;
				ballSpeedX *= -1;
				Main.playerScore++;
			}

			/* Reflect the ball from the upper and lower edges of the screen */
			if(ball.y <= ball.height/2){
				ball.y = ball.height/2;
				ballSpeedY *= -1;

			} else if(ball.y >= Main.SCREEN_H-ball.height/2){
				ball.y = Main.SCREEN_H-ball.height/2;
				ballSpeedY *= -1;
			}
		}

		/* Calculation of the new direction angle after collision with the paddle */
		function recalculateSpeed(paddleY:Number, ballY:Number)
		{
			var ySpeed = 5 * ( (ballY-paddleY) / 25 );
			return ySpeed;
		}
	}
}
