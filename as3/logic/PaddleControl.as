package logic {
	/* Player's paddle logic */
	import visual.Paddle;

	public class PaddleControl {

		var playerPaddle:Paddle;

		public function PaddleControl (playerPaddle:Paddle) {
			this.playerPaddle = playerPaddle;
		}

		/* Action on every frame */
		public function move () {
			/* Move to mouse pointer */
			playerPaddle.y = playerPaddle.stage.mouseY;

			/* Keep paddle on screen */
			if(playerPaddle.y - playerPaddle.height/2 < 0){
				playerPaddle.y = playerPaddle.height/2;
			} else if(playerPaddle.y + playerPaddle.height/2 > Main.SCREEN_H){
				playerPaddle.y = Main.SCREEN_H - playerPaddle.height/2;
			}
		}
	}
}
