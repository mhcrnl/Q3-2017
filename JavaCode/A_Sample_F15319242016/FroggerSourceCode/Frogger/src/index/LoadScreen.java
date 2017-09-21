package index;

import view.Level1;
import view.Level2;

public class LoadScreen {

	/**
	 * loads the level by reseting it and shows a loading screen while that
	 * happens
	 */
	public static void load() {
		// first thread loads level
		Thread load = new Thread() {
			public void run() {
				if (Main.isLevel1Run()) {
					Level1.reset();
				} else if (Main.isLevel2Run()) {
					Level2.reset();
				}
			}
		};
		// second thread just shows loading screen
		Thread loadScreen = new Thread() {
			public void run() {
				try {
					Thread.sleep(1000); // keeps loading screen up for 1 second
					
					// after one second it hides the loading screen and shows the game window
					Main.getFrame().setVisible(true);
					Main.getLoadScreen().setVisible(false);
				} catch (InterruptedException e) {
					e.printStackTrace();
				}
			}
		};
		
		load.start(); // first thread
		loadScreen.start(); // second thread
	}
}
