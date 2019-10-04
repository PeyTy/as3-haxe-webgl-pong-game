package logic;
/* Player's paddle logic */
import visual.Paddle;
import openfl.display.Stage;

class PaddleControl {

	var playerPaddle:Paddle;
	var stage:Stage;

	public function new (playerPaddle:Paddle, stage:Stage) {
		this.playerPaddle = playerPaddle;
		this.stage = stage;
	}

	/* Action on every frame */
	public function move () {
		/* Move to mouse pointer */
		playerPaddle.y = stage.mouseY;
		playerPaddle.z = stage.mouseX;

		/* Keep paddle on screen */
		if(playerPaddle.y - playerPaddle.height/2 < 0){
			playerPaddle.y = playerPaddle.height/2;
		} else if(playerPaddle.y + playerPaddle.height/2 > Main.SCREEN_H){
			playerPaddle.y = Main.SCREEN_H - playerPaddle.height/2;
		}
	}
}
