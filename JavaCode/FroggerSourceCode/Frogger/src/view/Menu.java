package view;

import java.awt.Color;
import java.awt.Graphics;

import javax.swing.ImageIcon;
import javax.swing.JPanel;

import controller.InputKeyEvents;
import controller.InputMouseEvents;

public class Menu extends JPanel {
	private static final long serialVersionUID = -646549002494383003L;
	
	private ImageIcon menuIcon;
	
		public Menu() {
			addMouseListener(new InputMouseEvents()); // for mouse clicks
			addKeyListener(new InputKeyEvents()); // for key clicks
			setFocusable(true); // allows keyboard input on the board
			loadMenu(); // loads all object images
		}
		
		private void loadMenu() {
			menuIcon = new ImageIcon("images/mainMenu.gif");
		}
		
		public void paintComponent(Graphics g) {
			super.paintComponent(g);
			// drawing background
			menuIcon.paintIcon(this, g, 0, 0);
			
			// drawing clickable boxes
			Color myColour = new Color(255, 0, 0, 0);
			g.setColor(myColour);
			g.fillRect(130, 210, 550, 100);
			g.fillRect(130, 330, 560, 100);
			g.fillRect(310, 450, 200, 100);
		}
}
