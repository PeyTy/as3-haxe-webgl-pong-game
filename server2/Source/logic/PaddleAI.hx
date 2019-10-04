package logic;
/* Enemy paddle logic */
import visual.Paddle;
import visual.Ball;

class PaddleAI {

	/* Paddle speed */
	var paddleSpeed:Int = 4;
	var enemyPaddle:Paddle;
	var ball:Ball;

	public function new (enemyPaddle:Paddle, ball:Ball) {
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

		if(enemyPaddle.z < ball.z - 10){
			enemyPaddle.z += paddleSpeed;
		} else if(enemyPaddle.z > ball.z + 10){
			enemyPaddle.z -= paddleSpeed;
		}
	}
}
