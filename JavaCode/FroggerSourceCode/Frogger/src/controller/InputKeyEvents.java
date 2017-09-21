package controller;

import java.awt.event.KeyAdapter;
import java.awt.event.KeyEvent;

import index.Main;
import index.Music;
import view.Level1;
import view.Level2;

/**
 * All keyboard input operations
 */
public class InputKeyEvents extends KeyAdapter {

	/**
	 * When a key is pressed.
	 * 
	 * arrows - move player
	 * space - plays level 1 from the menu
	 * r - resets current level
	 * m - mutes song
	 * esc - goes back to menu or closes program
	 */
	public void keyPressed(KeyEvent e) {
		// gets key code as an integer and will compare to key codes for different actions
		int key = e.getKeyCode();
		
		// seeing which key was pressed
		switch (key) {
		// arrow keys
		// up arrow
		case KeyEvent.VK_UP:
			// window barrier
			if (Main.isLevel1Run() && Level1.getPlayerY() < 100 || Main.isLevel2Run() && Level2.getPlayerY() < 100) {
				break;
			}
			// moving up
			else {
				if (Main.isLevel1Run()) {
					Level1.setPlayerY(Level1.getPlayerY() - 70);
					Level1.setPlayerIconPath("images/player_up.png");
				} else if (Main.isLevel2Run()) {
					Level2.setPlayerY(Level2.getPlayerY() - 70);
					Level2.setPlayerIconPath("images/player_up.png");
				}
			}
			break;
		// down arrow
		case KeyEvent.VK_DOWN:
			// window barrier
			if (Main.isLevel1Run() && Level1.getPlayerY() > 765 || Main.isLevel2Run() && Level2.getPlayerY() > 765) {
				break;
			}
			// moving down
			else {
				if (Main.isLevel1Run()) {
					Level1.setPlayerY(Level1.getPlayerY() + 70);
					Level1.setPlayerIconPath("images/player_down.png");
				} else if (Main.isLevel2Run()) {
					Level2.setPlayerY(Level2.getPlayerY() + 70);
					Level2.setPlayerIconPath("images/player_down.png");
				}
			}
			break;
		// right arrow
		case KeyEvent.VK_RIGHT:
			// window barrier
			if (Main.isLevel1Run() && Level1.getPlayerX() > 415 || Main.isLevel2Run() && Level2.getPlayerX() > 415) {
				break;
			}
			// moving right
			else {
				if (Main.isLevel1Run()) {
					Level1.setPlayerX(Level1.getPlayerX() + 70);
					Level1.setPlayerIconPath("images/player_right.png");
				} else if (Main.isLevel2Run()) {
					Level2.setPlayerX(Level2.getPlayerX() + 70);
					Level2.setPlayerIconPath("images/player_right.png");
				}
			}
			break;
		// left arrow
		case KeyEvent.VK_LEFT:
			// window barrier
			if (Main.isLevel1Run() && Level1.getPlayerX() < 70 || Main.isLevel2Run() && Level2.getPlayerX() < 70) {
				break;
			}
			// moving left
			else {
				if (Main.isLevel1Run()) {
					Level1.setPlayerX(Level1.getPlayerX() - 70);
					Level1.setPlayerIconPath("images/player_left.png");
				} else if (Main.isLevel2Run()) {
					Level2.setPlayerX(Level2.getPlayerX() - 70);
					Level2.setPlayerIconPath("images/player_left.png");
				}
			}
			break;

		// space key, plays level 1 from menu
		case KeyEvent.VK_SPACE:
			if (Main.isMenuRun()) {
				Main.setMenuRun(false);
				Main.setLeaderBoardRun(false);
				Main.setLevel1Run(true);
				Main.windowOption();
				Level1.reset();
			}

		// R key, resets game
		case KeyEvent.VK_R:
			if (Main.isLevel1Run()) {
				Level1.reset();
			} else if (Main.isLevel2Run()) {
				Level2.reset();
			}

			break;
			
		// M key, mutes/unmutes song
		case KeyEvent.VK_M:
			// if it isnt muted, mute it, else if it is muted it will unmute it
			if(Music.isMute() == false) {
				Music.setMute(true);
				Music.muteSetting();
			} else if (Music.isMute() == true) {
				Music.setMute(false);
				Music.muteSetting();
			}
			break;

		// escape key, goes back to menu, exits if on menu
		case KeyEvent.VK_ESCAPE:
			if (Main.isMenuRun()) {
				System.exit(0);
			} else if (Main.isLevel1Run()) {
				Main.setLevel1Run(false);
				Main.setMenuRun(true);
				Main.windowOption();
			} else if (Main.isLevel2Run()) {
				Main.setLevel2Run(false);
				Main.setMenuRun(true);
				Main.windowOption();
			} else if (Main.isLeaderBoardRun()) {
				Main.setLeaderBoardRun(false);
				Main.setMenuRun(true);
				Main.windowOption();
			} else if (Main.isLevelSelectRun()) {
				Main.setLevelSelectRun(false);
				Main.setMenuRun(true);
				Main.windowOption();
			}
			break;
		}
	}

	/**
	 * key releases:
	 * 
	 * arrow keys = player stand still image based on direction
	 */
	public void keyReleased(KeyEvent e) {
		int key = e.getKeyCode();
		switch (key) {
		case KeyEvent.VK_UP:
			if (Main.isLevel1Run()) {
				Level1.setPlayerIconPath("images/player_still_up.png");
			} else if (Main.isLevel2Run()) {
				Level2.setPlayerIconPath("images/player_still_up.png");
			}
			break;
		case KeyEvent.VK_DOWN:
			if (Main.isLevel1Run()) {
				Level1.setPlayerIconPath("images/player_still_down.png");
			} else if (Main.isLevel2Run()) {
				Level2.setPlayerIconPath("images/player_still_down.png");
			}
			break;
		case KeyEvent.VK_LEFT:
			if (Main.isLevel1Run()) {
				Level1.setPlayerIconPath("images/player_still_left.png");
			} else if (Main.isLevel2Run()) {
				Level2.setPlayerIconPath("images/player_still_left.png");
			}
			break;
		case KeyEvent.VK_RIGHT:
			if (Main.isLevel1Run()) {
				Level1.setPlayerIconPath("images/player_still_right.png");
			} else if (Main.isLevel2Run()) {
				Level2.setPlayerIconPath("images/player_still_right.png");
			}
			break;
		}
	}
}