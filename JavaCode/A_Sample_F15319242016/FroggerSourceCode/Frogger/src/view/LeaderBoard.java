package view;

import java.awt.Color;
import java.awt.Font;
import java.awt.Graphics;

import javax.swing.ImageIcon;
import javax.swing.JPanel;

import controller.InputKeyEvents;
import controller.InputMouseEvents;
import index.Main;
import index.Score;

public class LeaderBoard extends JPanel {
	private static final long serialVersionUID = -646549002494383003L;

	private ImageIcon boardIcon;

	private static String[] topScores;

	private static int y = (Main.GAME_HEIGHT / 2) - 400;

	public LeaderBoard() {
		addMouseListener(new InputMouseEvents()); // for mouse clicks
		addKeyListener(new InputKeyEvents()); // for key clicks
		setFocusable(true); // allows keyboard input on the board
		topScores = Score.readFinalScores();
		loadBoard(); // loads all object images
	}

	private void loadBoard() {
		boardIcon = new ImageIcon("images/leaderboard.jpg");
	}

	public void paintComponent(Graphics g) {
		super.paintComponent(g);
		// drawing background
		boardIcon.paintIcon(this, g, 0, 0);

		g.setColor(Color.YELLOW);
		g.setFont(new Font("TimesRoman", Font.PLAIN, 50));
		for (int i = 0; i < topScores.length; i++) {
			if (topScores[i] != null) {
				g.drawString(i + ".........." + topScores[i], (Main.GAME_WIDTH / 2) + 25, y);
				y += 50;
			}
		}

		// drawing clickable boxes
		Color myColour = new Color(255, 0, 0, 0);
		g.setColor(myColour);
		g.fillRect(600, Main.MENU_HEIGHT - 100, 200, 100);
	}

	public static void reset() {
		y = (Main.GAME_HEIGHT / 2) - 200;
		topScores = Score.readFinalScores();
	}
}
