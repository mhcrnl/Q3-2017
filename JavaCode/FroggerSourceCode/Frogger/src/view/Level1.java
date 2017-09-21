package view;

import java.awt.Color;
import java.awt.Font;
import java.awt.Graphics;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

import javax.swing.ImageIcon;
import javax.swing.JPanel;
import javax.swing.Timer;

import controller.InputKeyEvents;
import index.Main;
import index.Score;
import level1Objects.CarLevel1;
import level1Objects.LogsLevel1;
import level1Objects.MotorbikeLevel1;
import level1Objects.SemiLevel1;

/**
 * This class creates all objects on the board
 */
public class Level1 extends JPanel implements ActionListener {
	private static final long serialVersionUID = 7704761091317274700L;

	// object icons
	private ImageIcon backgroundIcon, playerIcon, lily1, lily2, lily3;

	// variables used to animate player
	private static String playerIconPath = "images/player_still_up.png";
	private static int playerX = 210, playerY = Main.GAME_HEIGHT - 92, score = 2500;
	private static String strScore = String.valueOf(score);

	// game booleans
	private static boolean gameOver = false;

	// game timer
	private static Timer gameTimer;

	// loading objects
	private CarLevel1 car = new CarLevel1();
	private MotorbikeLevel1 bike = new MotorbikeLevel1();
	private SemiLevel1 semi = new SemiLevel1();
	private LogsLevel1 log = new LogsLevel1();

	/**
	 * loads board, sets in focus, starts game timer
	 */
	public Level1() {
		addKeyListener(new InputKeyEvents()); // for keyboard imput
		setFocusable(true); // allows keyboard input on the board
		setGameTimer(new Timer(10, this));
		Score.newScore();
		loadImages(); // loads all object images
		getGameTimer().start();
	}

	/**
	 * all of the images for each object gets loaded here
	 */
	private void loadImages() {
		backgroundIcon = new ImageIcon("images/level1.jpg");
		playerIcon = new ImageIcon(playerIconPath);
		lily1 = new ImageIcon("images/lilypad.png");
		lily2 = new ImageIcon("images/lilypad.png");
		lily3 = new ImageIcon("images/lilypad.png");
	}

	/*
	 * Reloading player
	 */
	private void loadPlayer() {
		playerIcon = new ImageIcon(playerIconPath);
	}

	/**
	 * @param g
	 * 
	 *            paints the board
	 */
	public void paintComponent(Graphics g) {
		super.paintComponent(g);
		// drawing background
		backgroundIcon.paintIcon(this, g, 0, 0);
		// drawing lilypads for victory
		lily1.paintIcon(this, g, 70, 70);
		lily2.paintIcon(this, g, 210, 70);
		lily3.paintIcon(this, g, 350, 70);
		// drawing car
		car.paintComponent(g);
		// drawing motorbike
		bike.paintComponent(g);
		// drawing semi
		semi.paintComponent(g);
		// drawing logs
		log.paintComponent(g);
		// drawing player
		loadPlayer();
		playerIcon.paintIcon(this, g, playerX, playerY);
		// new font for score
		Font scoreFont = new Font("TimesRoman", Font.BOLD, 30);
		Font gameFont = new Font("TimesRoman", Font.PLAIN, 25);
		// updating strScore to value of score
		strScore = String.valueOf(score);
		// drawing top text
		g.setFont(gameFont);
		g.drawString("Esc: Menu", 20, 40);
		g.setFont(scoreFont);
		g.drawString("Score: " + strScore, 165, 40);
		g.setFont(gameFont);
		g.drawString("R: Restart", 360, 40);
		// game over/won screens
		if (isGameOver()) {
			g.setColor(Color.RED);
			g.drawString("GAME OVER", 150, 420);
			getGameTimer().stop();
		}
	}

	/**
	 * @param e
	 * 
	 *            repaints and updates board
	 */
	@Override
	public void actionPerformed(ActionEvent e) {

		// checking valid score
		if (score == 0) {
			getGameTimer().stop();
			setGameOver(true);
		} else {
			// update score
			score -= 1;
		}

		// checking if won
		if (playerX > 35 && playerX < 105 && playerY < 71) {
			Score.addScore(score); // adding score to text file
			Main.setLevel2Run(true); // starting level2
			Main.setLevel1Run(false); // ending level1
			Level2.reset(); // reseting level 2
			getGameTimer().stop(); // stopping level1
			Main.windowOption(); // changing window view
		} else if (playerX > 175 && playerX < 245 && playerY < 71) {
			Score.addScore(score); // adding score to text file
			Main.setLevel2Run(true); // starting level2
			Main.setLevel1Run(false); // ending level1
			Level2.reset(); // reseting level 2
			getGameTimer().stop(); // stopping level1
			Main.windowOption(); // changing window view
		} else if (playerX > 315 && playerX < 385 && playerY < 71) {
			Score.addScore(score); // adding score to text file
			Main.setLevel2Run(true); // starting level2
			Main.setLevel1Run(false); // ending level1
			Level2.reset(); // reseting level 2
			getGameTimer().stop(); // stopping level1
			Main.windowOption(); // changing window view
		} 
		// checking if lost
		else if (playerY < 70) {
			getGameTimer().stop();
			setGameOver(true);
		}

		// player on logs
		if (playerY <= Main.GAME_HEIGHT - 580 && playerY >= Main.GAME_HEIGHT - 651 && playerX >= LogsLevel1.getlog1XPos() - 10
				&& playerX <= LogsLevel1.getlog1XPos() + 150) {
			playerX -= 2;
		} else if (playerY <= Main.GAME_HEIGHT - 580 && playerY >= Main.GAME_HEIGHT - 651
				&& playerX >= LogsLevel1.getlog2XPos() - 10 && playerX <= LogsLevel1.getlog2XPos() + 150) {
			playerX -= 2;
		} else if (playerY <= Main.GAME_HEIGHT - 650 && playerY >= Main.GAME_HEIGHT - 721
				&& playerX >= LogsLevel1.getLog3XPos() - 10 && playerX <= LogsLevel1.getLog3XPos() + 150) {
			playerX += 2;
		} else if (playerY <= Main.GAME_HEIGHT - 650 && playerY >= Main.GAME_HEIGHT - 721
				&& playerX >= LogsLevel1.getLog4XPos() - 10 && playerX <= LogsLevel1.getLog4XPos() + 150) {
			playerX += 2;
		} else if (playerY <= Main.GAME_HEIGHT - 720 && playerY >= Main.GAME_HEIGHT - 790
				&& playerX >= LogsLevel1.getLog5XPos() - 10 && playerX <= LogsLevel1.getLog5XPos() + 150) {
			playerX -= 2;
		} else if (playerY > Main.GAME_HEIGHT - 580) {

		} 
		// player off log
		else if (playerY > 70) {
			getGameTimer().stop();
			setGameOver(true);
		}

		// draw
		repaint();

	}

	/**
	 * Resets Level
	 */
	public static void reset() {
		// reset booleans
		gameOver = false;
		// reset player
		playerX = 210;
		playerY = Main.GAME_HEIGHT - 92;
		playerIconPath = "images/player_still_up.png";
		// reset score
		score = 2500;
		// reset cars
		CarLevel1.setCar1XPos(-70);
		CarLevel1.setCar2XPos(Main.GAME_WIDTH);
		CarLevel1.setCar3XPos(-280);
		CarLevel1.setCar4XPos(Main.GAME_WIDTH + 350);
		// reset bieks
		MotorbikeLevel1.setbike1XPos(-70);
		// resset semis
		SemiLevel1.setsemi1XPos(Main.GAME_WIDTH);
		SemiLevel1.setsemi2XPos(Main.GAME_WIDTH + 280);
		// reset logs
		LogsLevel1.setlog1XPos(Main.GAME_WIDTH);
		LogsLevel1.setlog2XPos(Main.GAME_WIDTH + 280);
		LogsLevel1.setLog3XPos(-140);
		LogsLevel1.setLog4XPos(-420);
		LogsLevel1.setLog5XPos(Main.GAME_WIDTH + 140);
		// restart game timer
		getGameTimer().start();
	}

	/**
	 * @return playerY
	 */
	public static int getPlayerY() {
		return playerY;
	}

	/**
	 * @param i
	 * 
	 *            sets playerY
	 */
	public static void setPlayerY(int i) {
		playerY = i;
	}

	/**
	 * @return playerX
	 */
	public static int getPlayerX() {
		return playerX;
	}

	/**
	 * @param i
	 * 
	 *            sets playerX
	 */
	public static void setPlayerX(int i) {
		playerX = i;
	}

	/**
	 * @param path
	 * 
	 *            sets playerIconPath
	 */
	public static void setPlayerIconPath(String path) {
		playerIconPath = path;
	}

	public static boolean isGameOver() {
		return gameOver;
	}

	public static void setGameOver(boolean gameOver) {
		Level1.gameOver = gameOver;
	}

	public static Timer getGameTimer() {
		return gameTimer;
	}

	public static void setGameTimer(Timer gameTimer) {
		Level1.gameTimer = gameTimer;
	}
}