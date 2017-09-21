package level1Objects;

import java.awt.Graphics;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

import javax.swing.ImageIcon;
import javax.swing.JPanel;
import javax.swing.Timer;

import index.Main;

public class LogsLevel1 extends JPanel implements ActionListener {
	private static final long serialVersionUID = 6789461514097052926L;

	// log 1
	private static int log1XPos = Main.GAME_WIDTH, log1YPos = Main.GAME_HEIGHT - 580, logVel = -4;
	// log 2
	private static int log2XPos = Main.GAME_WIDTH + 280, log2YPos = Main.GAME_HEIGHT - 580;

	// log 3
	private static int log3XPos = -140, log3YPos = Main.GAME_HEIGHT - 650;
	// log 4
	private static int log4XPos = -420, log4YPos = Main.GAME_HEIGHT - 650;
	// log5
	private static int log5XPos = Main.GAME_WIDTH + 140, log5YPos = Main.GAME_HEIGHT - 720;

	private Timer logTimer = new Timer(20, this);

	public void paintComponent(Graphics g) {
		super.paintComponent(g);
		// drawing logs
		ImageIcon log = new ImageIcon("images/log.png");
		log.paintIcon(this, g, log1XPos, log1YPos);
		log.paintIcon(this, g, getlog2XPos(), getlog2YPos());
		log.paintIcon(this, g, log3XPos, log3YPos);
		log.paintIcon(this, g, log4XPos, log4YPos);
		log.paintIcon(this, g, log5XPos, log5YPos);

		logTimer.start();
	}

	public void actionPerformed(ActionEvent e) {
		// collision with window (log 1)
		if (getlog1XPos() < -140) {
			setlog1XPos(Main.GAME_WIDTH);
		} else {
			setlog1XPos(getlog1XPos() + logVel);
		}

		// collision with window (log 2)
		if (getlog2XPos() < -140) {
			setlog2XPos(Main.GAME_WIDTH);
		} else {
			setlog2XPos(getlog2XPos() + logVel);
		}
		// collision with window (log 3)
		if (getLog3XPos() > Main.GAME_WIDTH) {
			setLog3XPos(-140);
		} else {
			setLog3XPos(getLog3XPos() - logVel);
		}
		// collision with window (log 4)
		if (getLog4XPos() > Main.GAME_WIDTH) {
			setLog4XPos(-140);
		} else {
			setLog4XPos(getLog4XPos() - logVel);
		}
		// collision with window (log 5)
		if (getLog5XPos() < -140) {
			setLog5XPos(Main.GAME_WIDTH);
		} else {
			setLog5XPos(getLog5XPos() + logVel);
		}

		logTimer.stop();
		repaint();
	}

	public static int getlog1XPos() {
		return log1XPos;
	}

	public static void setlog1XPos(int log1XPos) {
		LogsLevel1.log1XPos = log1XPos;
	}

	public static int getlog1YPos() {
		return log1YPos;
	}

	public static void setlog1YPos(int log1YPos) {
		LogsLevel1.log1YPos = log1YPos;
	}

	public static int getlog2XPos() {
		return log2XPos;
	}

	public static void setlog2XPos(int log2xPos) {
		log2XPos = log2xPos;
	}

	public static int getlog2YPos() {
		return log2YPos;
	}

	public static void setlog2YPos(int log2yPos) {
		log2YPos = log2yPos;
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

	/**
	 * @return the log4XPos
	 */
	public static int getLog4XPos() {
		return log4XPos;
	}

	/**
	 * @param log4xPos
	 *            the log4XPos to set
	 */
	public static void setLog4XPos(int log4xPos) {
		log4XPos = log4xPos;
	}

	/**
	 * @return the log4YPos
	 */
	public static int getLog4YPos() {
		return log4YPos;
	}

	/**
	 * @param log4yPos
	 *            the log4YPos to set
	 */
	public static void setLog4YPos(int log4yPos) {
		log4YPos = log4yPos;
	}

	/**
	 * @return the log5XPos
	 */
	public static int getLog5XPos() {
		return log5XPos;
	}

	/**
	 * @param log5xPos
	 *            the log5XPos to set
	 */
	public static void setLog5XPos(int log5xPos) {
		log5XPos = log5xPos;
	}

	/**
	 * @return the log5YPos
	 */
	public static int getLog5YPos() {
		return log5YPos;
	}

	/**
	 * @param log5yPos
	 *            the log5YPos to set
	 */
	public static void setLog5YPos(int log5yPos) {
		log5YPos = log5yPos;
	}

}
