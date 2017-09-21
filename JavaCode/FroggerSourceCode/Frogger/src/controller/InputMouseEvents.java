package controller;

import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;

import index.Main;
import index.Score;
import view.Level1;

public class InputMouseEvents extends MouseAdapter {

	/**
	 * when the mouse is clicked it will get the x, y coordinates and do
	 * different actions based on where the click occured
	 */
	public void mousePressed(MouseEvent e) {
		int clickY = e.getY(), clickX = e.getX();

		// if menu is running
		if (Main.isMenuRun()) {
			// level select
			if (clickY > 210 && clickY < 310 && clickX > 130 && clickX < 680) {
				Main.setMenuRun(false);
				Main.setLevelSelectRun(true);
				Main.windowOption();
			}
			// leader board
			else if (clickY > 330 && clickY < 430 && clickX > 130 && clickX < 690) {
				Main.setLeaderBoardRun(true);
				Main.setMenuRun(false);
				Main.windowOption();
			}
			// play
			else if (clickY > 450 && clickY < 550 && clickX > 300 && clickX < 500) {
				Main.setMenuRun(false);
				Main.setLevel1Run(true);
				Main.windowOption();
				Level1.reset(); // starts level1
			}
		}
		// if leader board is running
		else if (Main.isLeaderBoardRun()) {
			// back to menu
			if (clickY > Main.MENU_HEIGHT - 100 && clickY < Main.MENU_HEIGHT && clickX > 600 && clickX < 800) {
				Main.setMenuRun(true);
				Main.setLeaderBoardRun(false);
				Main.windowOption();
			}
		}
		// if level selection is running
		else if (Main.isLevelSelectRun()) {
			// level 1 click box
			if (clickY > 120 && clickX > 150 && clickX < 370 && clickY < 500) {
				Main.setLevel1Run(true);
				Main.setLevelSelectRun(false);
				Main.windowOption();
			}
			// level 2 click box
			else if (clickY > 120 && clickY < 500 && clickX > 430 && clickX < 650) {
				Main.setLevel2Run(true);
				Main.setLevelSelectRun(false);
				Score.newScore();
				Main.windowOption();
			}
		}
	}
}
