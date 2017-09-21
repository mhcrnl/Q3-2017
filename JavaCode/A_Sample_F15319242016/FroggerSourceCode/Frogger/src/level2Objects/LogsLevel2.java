package level2Objects;

import java.awt.Graphics;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

import javax.swing.ImageIcon;
import javax.swing.JPanel;
import javax.swing.Timer;

import index.Main;

public class LogsLevel2 extends JPanel implements ActionListener {
	private static final long serialVersionUID = 6789461514097052926L;

	// log 1
	private static int log1XPos = Main.GAME_WIDTH, log1YPos = Main.GAME_HEIGHT - 650, logVel = -4;
	// log 3
	private static int log3XPos = -140, log3YPos = Main.GAME_HEIGHT - 720;

	private Timer logTimer = new Timer(20, this);

	public void paintComponent(Graphics g) {
		super.paintComponent(g);
		// drawing logs
		ImageIcon log = new ImageIcon("images/log.png");
		log.paintIcon(this, g, log1XPos, log1YPos);
		log.paintIcon(this, g, log3XPos, log3YPos);

		logTimer.start();
	}

	public void actionPerformed(ActionEvent e) {
		// collision with window (log 1)
		if (getlog1XPos() < -140) {
			setlog1XPos(Main.GAME_WIDTH);
		} else {
			setlog1XPos(getlog1XPos() + logVel);
		}
		// collision with window (log 3)
		if (getLog3XPos() > Main.GAME_WIDTH) {
			setLog3XPos(-140);
		} else {
			setLog3XPos(getLog3XPos() - logVel);
		}

		logTimer.stop();
		repaint();
	}

	public static int getlog1XPos() {
		return log1XPos;
	}

	public static void setlog1XPos(int log1XPos) {
		LogsLevel2.log1XPos = log1XPos;
	}

	public static int getlog1YPos() {
		return log1YPos;
	}

	public static void setlog1YPos(int log1YPos) {
		LogsLevel2.log1YPos = log1YPos;
	}

	/**
	 * @return the log3XPos
	 */
	public static int getLog3XPos() {
		return log3XPos;
	}

	/**
	 * @param log3xPos
	 *            the log3XPos to set
	 */
	public static void setLog3XPos(int log3xPos) {
		log3XPos = log3xPos;
	}

	/**
	 * @return the log3YPos
	 */
	public static int getLog3YPos() {
		return log3YPos;
	}

	/**
	 * @param log3yPos
	 *            the log3YPos to set
	 */
	public static void setLog3YPos(int log3yPos) {
		log3YPos = log3yPos;
	}

}
