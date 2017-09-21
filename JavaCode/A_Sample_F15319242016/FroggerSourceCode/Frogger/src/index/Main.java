package index;

import javax.swing.JFrame;

import view.LeaderBoard;
import view.Level1;
import view.Level2;
import view.LevelSelect;
import view.LoadScreenGraphics;
import view.Menu;

/**
 * @author Ryan, Gurveer, Manveer
 * 
 *         FROGGER: Frogger is a game played from the POV of a frog trying to
 *         get to a lilypad on the other side of the pond. The player will have
 *         to dodge cars and leap over logs to successfully make it to the
 *         lilypad.
 *
 *         The main class creates the JFrame and draws the board
 */
public class Main {

	// Window Variables
	public static final int MENU_WIDTH = 800, MENU_HEIGHT = 600, GAME_WIDTH = 490, GAME_HEIGHT = 860;
	private static final String TITLE = "Frogger";

	// boolean for which window, menu is true by default so that the game starts on the menu
	private static boolean menuRun = true, levelSelectRun = false, leaderBoardRun = false, level1Run = false,
			level2Run = false;

	// Jpanels
	private static Level1 level1 = new Level1();
	private static Level2 level2 = new Level2();
	private static LeaderBoard board = new LeaderBoard();
	private static Menu menu = new Menu();
	private static LoadScreenGraphics load = new LoadScreenGraphics();
	private static LevelSelect select = new LevelSelect();

	// game JFrame
	private static JFrame frame = new JFrame(TITLE);
	// loading screen JFrame
	private static JFrame loadScreen = new JFrame("Loading");

	/**
	 * @param args
	 */
	public static void main(String[] args) {

		// creates the loading screen, but does not show it
		getLoadScreen().setSize(400, 250);
		getLoadScreen().setLocationRelativeTo(null);
		getLoadScreen().setDefaultCloseOperation(JFrame.DO_NOTHING_ON_CLOSE);
		getLoadScreen().setResizable(false);
		getLoadScreen().add(load); // adding JPanel

		// Game window
		// no focus on frame so that the JPanels can use the keyevents
		getFrame().setFocusable(false);

		getFrame().setSize(MENU_WIDTH, MENU_HEIGHT);
		getFrame().setLocationRelativeTo(null); // centers window
		getFrame().setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE); // closes program when you hit x
		getFrame().setResizable(false); // not resizable

		windowOption(); // choosing which panel to show

		getFrame().setVisible(true); // shows the window
		
		// loading audio
		Music.backgroundLoop(); // plays music after showing the window
	}

	public static void windowOption() {
		// if showing menu
		if (isMenuRun()) {
			// JPanel
			getFrame().getContentPane().removeAll();
			getFrame().add(getMenu());

			// JFrame
			getFrame().setSize(MENU_WIDTH, MENU_HEIGHT);
			getFrame().setLocationRelativeTo(null);

			// Focus
			getMenu().requestFocus(true);
			getMenu().setVisible(true);
		}
		// if leaderboard
		else if (isLeaderBoardRun()) {
			getMenu().setVisible(false);
			// JPanel
			getFrame().getContentPane().removeAll();
			getFrame().getContentPane().add(getBoard());
			// Jframe
			getFrame().setTitle(TITLE + " | Leader Board");
			getFrame().setLocationRelativeTo(null);
			// Focus
			getBoard().requestFocus(true);
			LeaderBoard.reset();
		}
		// if level select
		else if (isLevelSelectRun()) {
			getMenu().setVisible(false);
			// JPanel
			getFrame().getContentPane().removeAll();
			getFrame().getContentPane().add(getSelect());
			// JFrame
			getFrame().setTitle(TITLE + " | Leader Board");
			getFrame().setLocationRelativeTo(null);
			// Focus
			getSelect().requestFocus(true);
		}
		// if showing level1
		else if (isLevel1Run()) {
			frame.setVisible(false);
			loadScreen.setVisible(true);
			LoadScreen.load(); // showing loading screen

			// JPanel
			getFrame().getContentPane().removeAll();
			getFrame().getContentPane().add(level1);
			// JFrame
			getFrame().setTitle(TITLE + " | Level 1");
			getFrame().setSize(GAME_WIDTH, GAME_HEIGHT);
			getFrame().setLocationRelativeTo(null);

			Score.newScore(); // creating a new score to calculate both level 1 and 2 scores

			// Focus
			level1.requestFocus(true);

			level1.setVisible(true);

		}
		// if showing level2
		else if (isLevel2Run()) {
			frame.setVisible(false);
			loadScreen.setVisible(true);
			LoadScreen.load(); // showing loading screen
			// JPanel
			level1.setVisible(false);
			getFrame().getContentPane().removeAll();
			getFrame().getContentPane().add(level2);

			// JFrame
			getFrame().setTitle(TITLE + " | Level 2");
			getFrame().setSize(GAME_WIDTH, GAME_HEIGHT);
			getFrame().setLocationRelativeTo(null);

			// Focus
			level2.requestFocus(true);
			Level2.reset();
		}
	}

	/**
	 * Getters and Setters
	 */
	public static boolean isMenuRun() {
		return menuRun;
	}

	public static void setMenuRun(boolean menuRun) {
		Main.menuRun = menuRun;
	}

	public static boolean isLevel1Run() {
		return level1Run;
	}

	public static void setLevel1Run(boolean level1Run) {
		Main.level1Run = level1Run;
	}

	public static boolean isLeaderBoardRun() {
		return leaderBoardRun;
	}

	public static void setLeaderBoardRun(boolean leaderBoardRun) {
		Main.leaderBoardRun = leaderBoardRun;
	}

	/**
	 * @return the levelSelectRun
	 */
	public static boolean isLevelSelectRun() {
		return levelSelectRun;
	}

	/**
	 * @param levelSelectRun
	 *            the levelSelectRun to set
	 */
	public static void setLevelSelectRun(boolean levelSelectRun) {
		Main.levelSelectRun = levelSelectRun;
	}

	/**
	 * @return the level2Run
	 */
	public static boolean isLevel2Run() {
		return level2Run;
	}

	/**
	 * @param level2Run
	 *            the level2Run to set
	 */
	public static void setLevel2Run(boolean level2Run) {
		Main.level2Run = level2Run;
	}

	public static JFrame getLoadScreen() {
		return loadScreen;
	}

	public static void setLoadScreen(JFrame loadScreen) {
		Main.loadScreen = loadScreen;
	}

	public static JFrame getFrame() {
		return frame;
	}

	public static void setFrame(JFrame frame) {
		Main.frame = frame;
	}

	public static LeaderBoard getBoard() {
		return board;
	}

	public static void setBoard(LeaderBoard board) {
		Main.board = board;
	}

	public static LevelSelect getSelect() {
		return select;
	}

	public static void setSelect(LevelSelect select) {
		Main.select = select;
	}

	public static Menu getMenu() {
		return menu;
	}

	public static void setMenu(Menu menu) {
		Main.menu = menu;
	}

}
