package level2Objects;

import java.awt.Graphics;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

import javax.swing.ImageIcon;
import javax.swing.JPanel;
import javax.swing.Timer;

import index.Main;
import view.Level2;

public class MotorbikeLevel2 extends JPanel implements ActionListener {
	private static final long serialVersionUID = 6789461514097052926L;

	// bike 1
	private static int bike1XPos = -70, bike1YPos = Main.GAME_HEIGHT - 230, bikeVel = 20;

	private Timer bikeTimer = new Timer(25, this);

	public void paintComponent(Graphics g) {
		super.paintComponent(g);
		// drawing bikes
		ImageIcon bike = new ImageIcon("images/motorbike.png");
		bike.paintIcon(this, g, bike1XPos, bike1YPos);

		bikeTimer.start();
	}

	public void actionPerformed(ActionEvent e) {
		// new thread
		Thread bikeThread = new Thread() {
			public void run() {
				// collision with player (bike 1)
				if (getbike1XPos() < Level2.getPlayerX() + 65 && getbike1XPos() + 65 > Level2.getPlayerX()
						&& getbike1YPos() < Level2.getPlayerY() + 65 && getbike1YPos() > Level2.getPlayerY()) {
					Level2.setGameOver(true);
					bikeTimer.stop();
				} 
				// if bike goes off screen
				else if (getbike1XPos() > Main.GAME_WIDTH) {
					try {
						// sleep
						Thread.sleep(250);
						setbike1XPos(-70);
					} catch (InterruptedException e) {
						e.printStackTrace();
					}
				} 
				// moving bike
				else {
					setbike1XPos(getbike1XPos() + bikeVel);
				}
				bikeTimer.stop();
			}
		};
		bikeThread.start();
		repaint();
	}

	public static int getbike1XPos() {
		return bike1XPos;
	}

	public static void setbike1XPos(int bike1XPos) {
		MotorbikeLevel2.bike1XPos = bike1XPos;
	}

	public static int getbike1YPos() {
		return bike1YPos;
	}

	public static void setbike1YPos(int bike1YPos) {
		MotorbikeLevel2.bike1YPos = bike1YPos;
	}
}
