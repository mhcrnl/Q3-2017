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
import level2Objects.CarLevel2;
import level2Objects.LogsLevel2;
import level2Objects.MotorbikeLevel2;
import level2Objects.SemiLevel2;

/**
 * This class creates all objects on the board
 */
public class Level2 extends JPanel implements ActionListener {
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
	private static Timer game2Timer;

	// loading objects
	private CarLevel2 car = new CarLevel2();
	private MotorbikeLevel2 bike = new MotorbikeLevel2();
	private SemiLevel2 semi = new SemiLevel2();
	private LogsLevel2 log = new LogsLevel2();
	
	/**
	 * loads board, sets in focus, starts game timer
	 */
	public Level2() {
		addKeyListener(new InputKeyEvents()); // for keyboard imput
		setFocusable(true); // allows keyboard input on the board
		setGame2Timer(new Timer(10, this));
		Score.newScore();
		loadImages(); // loads all object images
		Level2.reset();
		getGame2Timer().start();
	}

	/**
	 * all of the images for each object gets loaded here
	 */
	private void loadImages() {
		backgroundIcon = new ImageIcon("images/level2.png");
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
			getGame2Timer().stop();
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
			getGame2Timer().stop();
			setGameOver(true);
		} else {
			// update score
			score -= 1;
		}

		// checking if won
		if (playerX > 35 && playerX < 105 && playerY < 71) {
			Score.addScore(score);
			Main.setLevel2Run(false);
			Main.setMenuRun(true);
			Level2.reset();
			getGame2Timer().stop();
			Score.sumScore(); // sums all scores together
			Main.windowOption();
		} else if (playerX > 175 && playerX < 245 && playerY < 71) {
			Score.addScore(score);
			Main.setLevel2Run(false);
			Main.setMenuRun(true);
			Level2.reset();
			getGame2Timer().stop();
			Score.sumScore(); // sums all scores together
			Main.windowOption();
		} else if (playerX > 315 && playerX < 385 && playerY < 71) {
			Score.addScore(score);
			Main.setLevel2Run(false);
			Main.setMenuRun(true);
			Level2.reset();
			getGame2Timer().stop();
			Score.sumScore(); // sums all scores together
			Main.windowOption();
		} 
		// checking if lost
		else if (playerY < 70) {
			setGameOver(true);
		}

		// player on logs
		if (playerY <= Main.GAME_HEIGHT - 650 && playerY >= Main.GAME_HEIGHT - 721
				&& playerX >= LogsLevel2.getlog1XPos() - 10 && playerX <= LogsLevel2.getlog1XPos() + 150) {
			playerX -= 2;
		} else if (playerY <= Main.GAME_HEIGHT - 720 && playerY >= Main.GAME_HEIGHT - 790
				&& playerX >= LogsLevel2.getLog3XPos() - 10 && playerX <= LogsLevel2.getLog3XPos() + 150) {
			playerX += 2;
		} else if (playerY > Main.GAME_HEIGHT - 650) {

		} 
		// player off log
		else if (playerY > 70) {
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
		CarLevel2.setCar1XPos(140);
		CarLevel2.setCar2XPos(-70);
		CarLevel2.setCar3XPos(70);
		CarLevel2.setCar4XPos(-140);
		CarLevel2.setCar5XPos(Main.GAME_WIDTH - 70);
		CarLevel2.setCar6XPos(Main.GAME_WIDTH + 70);
		CarLevel2.setCar7XPos(Main.GAME_WIDTH + 210);
		// reset bikes
		MotorbikeLevel2.setbike1XPos(-70);
		// reset semis
		SemiLevel2.setsemi1XPos(Main.GAME_WIDTH);
		SemiLevel2.setSemi2XPos(Main.GAME_WIDTH + 70);
		// reset logs
		LogsLevel2.setlog1XPos(-140);
		LogsLevel2.setLog3XPos(Main.GAME_WIDTH + 140);
		// restart game timer
		getGame2Timer().start();
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
		Level2.gameOver = gameOver;
	}

	public static Timer getGame2Timer() {
		return game2Timer;
	}

	public static void setGame2Timer(Timer gameTimer) {
		Level2.game2Timer = gameTimer;
	}
}