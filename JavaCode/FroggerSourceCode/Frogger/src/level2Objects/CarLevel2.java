package level2Objects;

import java.awt.Graphics;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

import javax.swing.ImageIcon;
import javax.swing.JPanel;
import javax.swing.Timer;

import index.Main;
import view.Level2;

public class CarLevel2 extends JPanel implements ActionListener {
	private static final long serialVersionUID = 310222907486068444L;

	// car 1
	private static int car1XPos = 140, car1YPos = Main.GAME_HEIGHT - 160, carVel = 6;
	// car 2
	private static int car2XPos = -70, car2YPos = Main.GAME_HEIGHT - 160;
	// car 3
	private static int car3XPos = 70, car3YPos = Main.GAME_HEIGHT - 300;
	// car 4
	private static int car4XPos = -140, car4YPos = Main.GAME_HEIGHT - 300;
	// car 5
	private static int car5XPos = Main.GAME_WIDTH - 70, car5YPos = Main.GAME_HEIGHT - 370;
	// car 6
	private static int car6XPos = Main.GAME_WIDTH + 70, car6YPos = Main.GAME_HEIGHT - 370;
	// car 7
	private static int car7XPos = Main.GAME_WIDTH + 210, car7YPos = Main.GAME_HEIGHT - 370;

	private Timer carTimer = new Timer(25, this);

	public void paintComponent(Graphics g) {
		super.paintComponent(g);
		// drawing cars
		ImageIcon car = new ImageIcon("images/car.png");
		car.paintIcon(this, g, car1XPos, car1YPos);
		car.paintIcon(this, g, car2XPos, car2YPos);
		car.paintIcon(this, g, car3XPos, car3YPos);
		car.paintIcon(this, g, car4XPos, car4YPos);
		car.paintIcon(this, g, car5XPos, car5YPos);
		car.paintIcon(this, g, car6XPos, car6YPos);
		car.paintIcon(this, g, car7XPos, car7YPos);

		carTimer.start();
	}

	@Override
	public void actionPerformed(ActionEvent e) {
		// collision with player (car 1)
		if (car1XPos < Level2.getPlayerX() + 65 && car1XPos + 65 > Level2.getPlayerX()
				&& car1YPos < Level2.getPlayerY() + 65 && car1YPos > Level2.getPlayerY()) {
			Level2.setGameOver(true);
			carTimer.stop();
		} else if (car1XPos > Main.GAME_WIDTH) {
			car1XPos = -70;
		} else {
			car1XPos += carVel;
		}
		// collision with player (car 2)
		if (car2XPos < Level2.getPlayerX() + 65 && car2XPos + 65 > Level2.getPlayerX()
				&& car2YPos < Level2.getPlayerY() + 65 && car2YPos > Level2.getPlayerY()) {
			Level2.setGameOver(true);
			carTimer.stop();
		} else if (car2XPos > Main.GAME_WIDTH) {
			car2XPos = -70;
		} else {
			car2XPos += carVel;
		}
		// collision with player (car 3)
		if (car3XPos < Level2.getPlayerX() + 65 && car3XPos + 65 > Level2.getPlayerX()
				&& car3YPos < Level2.getPlayerY() + 65 && car3YPos > Level2.getPlayerY()) {
			Level2.setGameOver(true);
			carTimer.stop();
		} else if (car3XPos > Main.GAME_WIDTH) {
			car3XPos = -70;
		} else {
			car3XPos += carVel;
		}
		// collision with player (car 4)
		if (car4XPos < Level2.getPlayerX() + 65 && car4XPos + 65 > Level2.getPlayerX()
				&& car4YPos < Level2.getPlayerY() + 65 && car4YPos > Level2.getPlayerY()) {
			Level2.setGameOver(true);
			carTimer.stop();
		} else if (car4XPos > Main.GAME_WIDTH) {
			car4XPos = -70;
		} else {
			car4XPos += carVel;
		}
		// collision with player (car 5)
		if (car5XPos < Level2.getPlayerX() + 65 && car5XPos + 65 > Level2.getPlayerX()
				&& car5YPos < Level2.getPlayerY() + 65 && car5YPos > Level2.getPlayerY()) {
			Level2.setGameOver(true);
			carTimer.stop();
		} else if (car5XPos < -70) {
			car5XPos = Main.GAME_WIDTH;
		} else {
			car5XPos -= carVel;
		}
		// collision with player (car 6)
		if (car6XPos < Level2.getPlayerX() + 65 && car6XPos + 65 > Level2.getPlayerX()
				&& car6YPos < Level2.getPlayerY() + 65 && car6YPos > Level2.getPlayerY()) {
			Level2.setGameOver(true);
			carTimer.stop();
		} else if (car6XPos < -70) {
			car6XPos = Main.GAME_WIDTH;
		} else {
			car6XPos -= carVel;
		}
		// collision with player (car 7)
		if (car7XPos < Level2.getPlayerX() + 65 && car7XPos + 65 > Level2.getPlayerX()
				&& car7YPos < Level2.getPlayerY() + 65 && car7YPos > Level2.getPlayerY()) {
			Level2.setGameOver(true);
			carTimer.stop();
		} else if (car7XPos < -70) {
			car7XPos = Main.GAME_WIDTH;
		} else {
			car7XPos -= carVel;
		}
	}

	/**
	 * @return the car1XPos
	 */
	public static int getCar1XPos() {
		return car1XPos;
	}

	/**
	 * @param car1xPos
	 *            the car1XPos to set
	 */
	public static void setCar1XPos(int car1xPos) {
		car1XPos = car1xPos;
	}

	/**
	 * @return the car1YPos
	 */
	public static int getCar1YPos() {
		return car1YPos;
	}

	/**
	 * @param car1yPos
	 *            the car1YPos to set
	 */
	public static void setCar1YPos(int car1yPos) {
		car1YPos = car1yPos;
	}

	/**
	 * @return the car2XPos
	 */
	public static int getCar2XPos() {
		return car2XPos;
	}

	/**
	 * @param car2xPos
	 *            the car2XPos to set
	 */
	public static void setCar2XPos(int car2xPos) {
		car2XPos = car2xPos;
	}

	/**
	 * @return the car2YPos
	 */
	public static int getCar2YPos() {
		return car2YPos;
	}

	/**
	 * @param car2yPos
	 *            the car2YPos to set
	 */
	public static void setCar2YPos(int car2yPos) {
		car2YPos = car2yPos;
	}

	/**
	 * @return the car3XPos
	 */
	public static int getCar3XPos() {
		return car3XPos;
	}

	/**
	 * @param car3xPos
	 *            the car3XPos to set
	 */
	public static void setCar3XPos(int car3xPos) {
		car3XPos = car3xPos;
	}

	/**
	 * @return the car3YPos
	 */
	public static int getCar3YPos() {
		return car3YPos;
	}

	/**
	 * @param car3yPos
	 *            the car3YPos to set
	 */
	public static void setCar3YPos(int car3yPos) {
		car3YPos = car3yPos;
	}

	/**
	 * @return the car4XPos
	 */
	public static int getCar4XPos() {
		return car4XPos;
	}

	/**
	 * @param car4xPos
	 *            the car4XPos to set
	 */
	public static void setCar4XPos(int car4xPos) {
		car4XPos = car4xPos;
	}

	/**
	 * @return the car4YPos
	 */
	public static int getCar4YPos() {
		return car4YPos;
	}

	/**
	 * @param car4yPos
	 *            the car4YPos to set
	 */
	public static void setCar4YPos(int car4yPos) {
		car4YPos = car4yPos;
	}

	/**
	 * @return the car5XPos
	 */
	public static int getCar5XPos() {
		return car5XPos;
	}

	/**
	 * @param car5xPos the car5XPos to set
	 */
	public static void setCar5XPos(int car5xPos) {
		car5XPos = car5xPos;
	}

	/**
	 * @return the car5YPos
	 */
	public static int getCar5YPos() {
		return car5YPos;
	}

	/**
	 * @param car5yPos the car5YPos to set
	 */
	public static void setCar5YPos(int car5yPos) {
		car5YPos = car5yPos;
	}

	/**
	 * @return the car6XPos
	 */
	public static int getCar6XPos() {
		return car6XPos;
	}

	/**
	 * @param car6xPos the car6XPos to set
	 */
	public static void setCar6XPos(int car6xPos) {
		car6XPos = car6xPos;
	}

	/**
	 * @return the car6YPos
	 */
	public static int getCar6YPos() {
		return car6YPos;
	}

	/**
	 * @param car6yPos the car6YPos to set
	 */
	public static void setCar6YPos(int car6yPos) {
		car6YPos = car6yPos;
	}

	/**
	 * @return the car7XPos
	 */
	public static int getCar7XPos() {
		return car7XPos;
	}

	/**
	 * @param car7xPos the car7XPos to set
	 */
	public static void setCar7XPos(int car7xPos) {
		car7XPos = car7xPos;
	}

	/**
	 * @return the car7YPos
	 */
	public static int getCar7YPos() {
		return car7YPos;
	}

	/**
	 * @param car7yPos the car7YPos to set
	 */
	public static void setCar7YPos(int car7yPos) {
		car7YPos = car7yPos;
	}
}
