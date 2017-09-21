package level1Objects;

import java.awt.Graphics;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

import javax.swing.ImageIcon;
import javax.swing.JPanel;
import javax.swing.Timer;

import index.Main;
import view.Level1;

public class SemiLevel1 extends JPanel implements ActionListener {
	private static final long serialVersionUID = 6789461514097052926L;

	// semi 1
	private static int semi1XPos = Main.GAME_WIDTH, semi1YPos = Main.GAME_HEIGHT - 440,
			semiVel = -3;
	// semi 2
	private static int semi2XPos = Main.GAME_WIDTH + 280,
			semi2YPos = Main.GAME_HEIGHT - 440;

	private Timer semiTimer = new Timer(25, this);

	public void paintComponent(Graphics g) {
		super.paintComponent(g);
		// drawing semis
		ImageIcon semi = new ImageIcon("images/semi.png");
		semi.paintIcon(this, g, semi1XPos, semi1YPos);
		semi.paintIcon(this, g, getsemi2XPos(), getsemi2YPos());

		semiTimer.start();
	}

	public void actionPerformed(ActionEvent e) {
		// collision with player (semi 1)
		if (getsemi1XPos() < Level1.getPlayerX() + 70
				&& getsemi1XPos() + 140 > Level1.getPlayerX()
				&& getsemi1YPos() < Level1.getPlayerY() + 70
				&& getsemi1YPos() > Level1.getPlayerY()) {
			Level1.setGameOver(true);
			semiTimer.stop();
		} else if (getsemi1XPos() < -140) {
			setsemi1XPos(Main.GAME_WIDTH);
		} else {
			setsemi1XPos(getsemi1XPos() + semiVel);
		}

		// collision with player (semi 2)
		if (getsemi2XPos() < Level1.getPlayerX() + 70
				&& getsemi2XPos() + 140 > Level1.getPlayerX()
				&& getsemi2YPos() < Level1.getPlayerY() + 70
				&& getsemi2YPos() > Level1.getPlayerY()) {
			Level1.setGameOver(true);
			semiTimer.stop();
		} else if (getsemi2XPos() < -140) {
			setsemi2XPos(Main.GAME_WIDTH);
		} else {
			setsemi2XPos(getsemi2XPos() + semiVel);
		}

		

		semiTimer.stop();
		repaint();
	}

	public static int getsemi1XPos() {
		return semi1XPos;
	}

	public static void setsemi1XPos(int semi1XPos) {
		SemiLevel1.semi1XPos = semi1XPos;
	}

	public static int getsemi1YPos() {
		return semi1YPos;
	}

	public static void setsemi1YPos(int semi1YPos) {
		SemiLevel1.semi1YPos = semi1YPos;
	}

	public static int getsemi2XPos() {
		return semi2XPos;
	}

	public static void setsemi2XPos(int semi2xPos) {
		semi2XPos = semi2xPos;
	}

	public static int getsemi2YPos() {
		return semi2YPos;
	}

	public static void setsemi2YPos(int semi2yPos) {
		semi2YPos = semi2yPos;
	}

}
