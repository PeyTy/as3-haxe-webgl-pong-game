package logic {
	/* Enemy paddle logic */
	import visual.Paddle;
	import visual.Ball;

	public class PaddleAI {

		/* Paddle speed */
		var paddleSpeed:int = 3;
		var enemyPaddle:Paddle;
		var ball:Ball;

		public function PaddleAI (enemyPaddle:Paddle, ball:Ball) {
			this.enemyPaddle = enemyPaddle;
			this.ball = ball;
		}

		/* Action on every frame */
		public function move () {
			/* Move paddle to ball step-by-step */
			if(enemyPaddle.y < ball.y - 10){
				enemyPaddle.y += paddleSpeed;
			} else if(enemyPaddle.y > ball.y + 10){
				enemyPaddle.y -= paddleSpeed;
			}

			/* Keep paddle on screen */
			if(enemyPaddle.y - enemyPaddle.height/2 < 0){
				enemyPaddle.y = enemyPaddle.height/2;
			} else if(enemyPaddle.y + enemyPaddle.height/2 > Main.SCREEN_H){
				enemyPaddle.y = Main.SCREEN_H - enemyPaddle.height/2;
			}
		}
	}
}
