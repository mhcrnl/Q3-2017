package level1Objects;

import java.awt.Graphics;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

import javax.swing.ImageIcon;
import javax.swing.JPanel;
import javax.swing.Timer;

import index.Main;
import view.Level1;

public class CarLevel1 extends JPanel implements ActionListener {
	private static final long serialVersionUID = 6789461514097052926L;

	// car 1
	private static int car1XPos = -70, car1YPos = Main.GAME_HEIGHT - 160,
			carVel = 6;
	// car 2
	private static int car2XPos = Main.GAME_WIDTH,
			car2YPos = Main.GAME_HEIGHT - 230;
	// car 3
	private static int car3XPos = -280, car3YPos = Main.GAME_HEIGHT - 160;
	
	// car 4
	private static int car4XPos = Main.GAME_WIDTH + 350,
			car4YPos = Main.GAME_HEIGHT - 230;

	private Timer carTimer = new Timer(25, this);

	public void paintComponent(Graphics g) {
		super.paintComponent(g);
		// drawing cars
		ImageIcon car = new ImageIcon("images/car.png");
		car.paintIcon(this, g, car1XPos, car1YPos);
		car.paintIcon(this, g, getCar2XPos(), getCar2YPos());
		car.paintIcon(this, g, getCar3XPos(), getCar3YPos());
		car.paintIcon(this, g, getCar4XPos(), getCar4YPos());

		carTimer.start();
	}

	public void actionPerformed(ActionEvent e) {
		// collision with player (car 1)
		if (getCar1XPos() < Level1.getPlayerX() + 65
				&& getCar1XPos() + 65 > Level1.getPlayerX()
				&& getCar1YPos() < Level1.getPlayerY() + 65
				&& getCar1YPos() > Level1.getPlayerY()) {
			Level1.setGameOver(true);
			carTimer.stop();
		} else if (getCar1XPos() > Main.GAME_WIDTH) {
			setCar1XPos(-70);
		} else {
			setCar1XPos(getCar1XPos() + carVel);
		}

		// collision with player (car 2)
		if (getCar2XPos() < Level1.getPlayerX() + 65
				&& getCar2XPos() + 65 > Level1.getPlayerX()
				&& getCar2YPos() < Level1.getPlayerY() + 65
				&& getCar2YPos() > Level1.getPlayerY()) {
			Level1.setGameOver(true);
			carTimer.stop();
		} else if (getCar2XPos() < -70) {
			setCar2XPos(Main.GAME_WIDTH);
		} else {
			setCar2XPos(getCar2XPos() - carVel);
		}

		// collision with player (car 3)
		if (getCar3XPos() < Level1.getPlayerX() + 65
				&& getCar3XPos() + 65 > Level1.getPlayerX()
				&& getCar3YPos() < Level1.getPlayerY() + 65
				&& getCar3YPos() > Level1.getPlayerY()) {
			Level1.setGameOver(true);
			carTimer.stop();
		} else if (getCar3XPos() > Main.GAME_WIDTH) {
			setCar3XPos(-70);
		} else {
			setCar3XPos(getCar3XPos() + carVel);
		}
		
		// collision with player (car 4)
				if (getCar4XPos() < Level1.getPlayerX() + 65
						&& getCar4XPos() + 65 > Level1.getPlayerX()
						&& getCar4YPos() < Level1.getPlayerY() + 65
						&& getCar4YPos() > Level1.getPlayerY()) {
					Level1.setGameOver(true);
					carTimer.stop();
				} else if (getCar4XPos() < -70) {
					setCar4XPos(Main.GAME_WIDTH);
				} else {
					setCar4XPos(getCar4XPos() - carVel);
				}

		carTimer.stop();
		repaint();
	}

	public static int getCar1XPos() {
		return car1XPos;
	}

	public static void setCar1XPos(int car1XPos) {
		CarLevel1.car1XPos = car1XPos;
	}

	public static int getCar1YPos() {
		return car1YPos;
	}

	public static void setCar1YPos(int car1YPos) {
		CarLevel1.car1YPos = car1YPos;
	}

	public static int getCar2XPos() {
		return car2XPos;
	}

	public static void setCar2XPos(int car2xPos) {
		car2XPos = car2xPos;
	}

	public static int getCar2YPos() {
		return car2YPos;
	}

	public static void setCar2YPos(int car2yPos) {
		car2YPos = car2yPos;
	}

	public static int getCar3XPos() {
		return car3XPos;
	}

	public static void setCar3XPos(int car3xPos) {
		car3XPos = car3xPos;
	}

	public static int getCar3YPos() {
		return car3YPos;
	}

	public static void setCar3YPos(int car4yPos) {
		car4YPos = car4yPos;
	}
	
	public static int getCar4XPos() {
		return car4XPos;
	}

	public static void setCar4XPos(int car3xPos) {
		car4XPos = car3xPos;
	}

	public static int getCar4YPos() {
		return car4YPos;
	}

	public static void setCar4YPos(int car4yPos) {
		car4YPos = car4yPos;
	}

}
