package level2Objects;

import java.awt.Graphics;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

import javax.swing.ImageIcon;
import javax.swing.JPanel;
import javax.swing.Timer;

import index.Main;
import view.Level2;

public class SemiLevel2 extends JPanel implements ActionListener {
	private static final long serialVersionUID = 6789461514097052926L;

	// semi 1
	private static int semi1XPos = Main.GAME_WIDTH, semi1YPos = Main.GAME_HEIGHT - 440, semiVel = -3;
	// semi 2
	private static int semi2XPos = Main.GAME_WIDTH + 70, semi2YPos = Main.GAME_HEIGHT - 510;

	private Timer semiTimer = new Timer(25, this);

	public void paintComponent(Graphics g) {
		super.paintComponent(g);
		// drawing semis
		ImageIcon semi = new ImageIcon("images/semi.png");
		semi.paintIcon(this, g, semi1XPos, semi1YPos);
		semi.paintIcon(this, g, semi2XPos, semi2YPos);

		semiTimer.start();
	}

	public void actionPerformed(ActionEvent e) {
		// collision with player (semi 2)
		if (getSemi2XPos() < Level2.getPlayerX() + 70 && getSemi2XPos() + 140 > Level2.getPlayerX()
				&& getSemi2YPos() < Level2.getPlayerY() + 70 && getSemi2YPos() > Level2.getPlayerY()) {
			Level2.setGameOver(true);
			semiTimer.stop();
		} else if (getSemi2XPos() < -140) {
			setSemi2XPos(Main.GAME_WIDTH);
		} else {
			setSemi2XPos(getSemi2XPos() + semiVel);
		}
		// collision with player (semi 1)
		if (getsemi1XPos() < Level2.getPlayerX() + 70 && getsemi1XPos() + 140 > Level2.getPlayerX()
				&& getsemi1YPos() < Level2.getPlayerY() + 70 && getsemi1YPos() > Level2.getPlayerY()) {
			Level2.setGameOver(true);
			semiTimer.stop();
		} else if (getsemi1XPos() < -140) {
			setsemi1XPos(Main.GAME_WIDTH);
		} else {
			setsemi1XPos(getsemi1XPos() + semiVel);
		}

		semiTimer.stop();
		repaint();
	}

	public static int getsemi1XPos() {
		return semi1XPos;
	}

	public static void setsemi1XPos(int semi1XPos) {
		SemiLevel2.semi1XPos = semi1XPos;
	}

	public static int getsemi1YPos() {
		return semi1YPos;
	}

	public static void setsemi1YPos(int semi1YPos) {
		SemiLevel2.semi1YPos = semi1YPos;
	}

	/**
	 * @return the semi2XPos
	 */
	public static int getSemi2XPos() {
		return semi2XPos;
	}

	/**
	 * @param semi2xPos the semi2XPos to set
	 */
	public static void setSemi2XPos(int semi2xPos) {
		semi2XPos = semi2xPos;
	}

	/**
	 * @return the semi2YPos
	 */
	public static int getSemi2YPos() {
		return semi2YPos;
	}

	/**
	 * @param semi2yPos the semi2YPos to set
	 */
	public static void setSemi2YPos(int semi2yPos) {
		semi2YPos = semi2yPos;
	}
}
