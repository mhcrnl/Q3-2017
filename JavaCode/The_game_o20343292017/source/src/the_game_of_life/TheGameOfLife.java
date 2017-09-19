/**
 * The game of life
 *
 * @author Marc Oliveras Galvez <admin@oligalma.com> 
 * @link http://www.oligalma.com
 * @copyright 2017 Oligalma
 * @license GPL License v3
 */

package the_game_of_life;

import java.awt.*;
import java.awt.event.*;
import javax.swing.*;
import javax.swing.border.*;

public class TheGameOfLife extends JApplet {
	private static final long serialVersionUID = 1L;
	private boolean stationary;
	private boolean black;
	private boolean change = false;
	private boolean clic = false;
	private boolean isStandalone = false;
	private Vivarium v = null;
	private JLabel[][] area = new JLabel[25][45];
	private boolean[][] area2 = new boolean[25][45];
	private JPanel jPanel1 = new JPanel();
	private JPanel jPanel2 = new JPanel();
	private GridLayout gridLayout1 = new GridLayout();
	private JPanel jPanel3 = new JPanel();
	private JButton nextgen = new JButton();
	private JButton about = new JButton();
	private JButton erase = new JButton();
	private ActionListener al = new ActionListener() {
		@Override
		public void actionPerformed(ActionEvent e) {
			Object o = e.getSource();

			if (o == erase) {
				for (int i = 0; i < area.length; i++)
					for (int j = 0; j < area[0].length; j++)
						area[i][j].setBackground(Color.white);
				change = true;
			}

			else if (o == about)
				showAbout();

			else if (o == nextgen) {
				if (change || v == null) {
					for (int i = 0; i < area2.length; i++)
						for (int j = 0; j < area2[0].length; j++) {
							if (area[i][j].getBackground().equals(Color.red))
								area2[i][j] = true;
							else
								area2[i][j] = false;
						}
					change = false;
					v = new Vivarium(area2, jCheckBox1.isSelected());
					est.setText(Integer.toString(v.calculateStationary()));
					stationary = true;
					if (est.getText().equals("1000")) {
						est.setText("NO");
						stationary = false;
					}
				}
				area2 = v.nextGen();

				if (stationary) {
					if (Integer.parseInt(est.getText()) > 0)
						est.setText(Integer.toString(Integer.parseInt(est
								.getText()) - 1));
				}

				for (int i = 0; i < area2.length; i++)
					for (int j = 0; j < area2[0].length; j++) {
						if (area2[i][j] == true)
							area[i][j].setBackground(Color.red);
						else
							area[i][j].setBackground(Color.white);
					}
			} else if (o == jCheckBox1) {
				change = true;
			}

		}
	};

	MouseListener ml = new MouseListener() {
		@Override
		public void mouseExited(MouseEvent e) {
		}

		@Override
		public void mouseEntered(MouseEvent e) {
			if (clic) {
				Object o = e.getSource();
				if (black)
					((JLabel) o).setBackground(Color.red);
				else
					((JLabel) o).setBackground(Color.white);
			}
		}

		@Override
		public void mouseReleased(MouseEvent e) {
			clic = false;
		}

		@Override
		public void mouseClicked(MouseEvent e) {

		}

		@Override
		public void mousePressed(MouseEvent e) {
			change = true;
			clic = true;
			Object o = e.getSource();
			if (e.getButton() == MouseEvent.BUTTON1) {
				black = true;
				((JLabel) o).setBackground(Color.red);
			} else if (e.getButton() == MouseEvent.BUTTON3) {
				black = false;
				((JLabel) o).setBackground(Color.white);
			}
		}
	};

	MouseMotionListener mml = new MouseMotionListener() {
		@Override
		public void mouseMoved(MouseEvent e) {

		}

		@Override
		public void mouseDragged(MouseEvent e) {

		}
	};
	JCheckBox jCheckBox1 = new JCheckBox();
	JLabel est = new JLabel();
	JPanel jPanel4 = new JPanel();
	TitledBorder titledBorder1;

	// Get a parameter value
	public String getParameter(String key, String def) {
		return isStandalone ? System.getProperty(key, def)
				: (getParameter(key) != null ? getParameter(key) : def);
	}

	// Initialize the applet
	@Override
	public void init() {
		try {
			jbInit();
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	// Component initialization
	private void jbInit() throws Exception {
		jCheckBox1.addActionListener(al);
		titledBorder1 = new TitledBorder("");
		nextgen.addActionListener(al);
		this.setSize(new Dimension(420, 320));
		jPanel1.setLayout(null);
		jPanel2.setBackground(Color.blue);
		jPanel2.setBorder(BorderFactory.createLineBorder(Color.black));
		jPanel2.setBounds(new Rectangle(16, 11, 362, 227));
		jPanel2.setLayout(gridLayout1);
		gridLayout1.setColumns(45);
		gridLayout1.setHgap(0);
		gridLayout1.setRows(25);
		gridLayout1.setVgap(0);
		jPanel3.setBorder(BorderFactory.createRaisedBevelBorder());
		jPanel3.setBounds(new Rectangle(19, 268, 384, 39));
		jPanel3.setLayout(null);
		nextgen.setBounds(new Rectangle(182, 6, 83, 26));
		nextgen.setMargin(new Insets(2, 1, 2, 1));
		nextgen.setText("Next");
		about.setBounds(new Rectangle(345, 9, 28, 20));
		about.setToolTipText("");
		about.setMargin(new Insets(2, 1, 2, 1));
		about.setText("?");
		erase.setText("Clear");
		erase.setMargin(new Insets(2, 1, 2, 1));
		erase.setBounds(new Rectangle(86, 6, 83, 26));
		jCheckBox1.setText("Ball");
		jCheckBox1.setBounds(new Rectangle(10, 10, 71, 18));
		est.setFont(new java.awt.Font("Dialog", 1, 12));
		est.setBorder(BorderFactory.createRaisedBevelBorder());
		est.setPreferredSize(new Dimension(4, 4));
		est.setHorizontalAlignment(SwingConstants.CENTER);
		est.setText("0");
		est.setBounds(new Rectangle(283, 7, 42, 25));
		jPanel4.setBackground(new Color(192, 255, 192));
		jPanel4.setBorder(BorderFactory.createLoweredBevelBorder());
		jPanel4.setBounds(new Rectangle(14, 8, 392, 250));
		jPanel4.setLayout(null);
		jPanel1.setBorder(BorderFactory.createLineBorder(Color.black));
		this.getContentPane().add(jPanel1, BorderLayout.CENTER);
		jPanel3.add(jCheckBox1, null);
		jPanel3.add(est, null);
		jPanel3.add(erase, null);
		jPanel3.add(nextgen, null);
		jPanel3.add(about, null);
		jPanel1.add(jPanel4, null);
		jPanel4.add(jPanel2, null);
		jPanel1.add(jPanel3, null);
		for (int i = 0; i < area.length; i++)
			for (int j = 0; j < area[0].length; j++) {
				area[i][j] = new JLabel();
				area[i][j].setBackground(Color.white);
				area[i][j].setOpaque(true);
				area[i][j].setBorder(BorderFactory
						.createLineBorder(Color.black));
				area[i][j].addMouseListener(ml);
				area[i][j].addMouseMotionListener(mml);
				JLabel aux = area[i][j];
				jPanel2.add(aux);
			}
		erase.addActionListener(al);
		about.addActionListener(al);
	}

	// Start the applet
	@Override
	public void start() {
	}

	// Stop the applet
	@Override
	public void stop() {
	}

	// Destroy the applet
	@Override
	public void destroy() {
	}

	// Get Applet information
	@Override
	public String getAppletInfo() {
		return "Applet Information";
	}

	// Get parameter info
	@Override
	public String[][] getParameterInfo() {
		return null;
	}

	// Main method
	public static void main(String[] args) {
		TheGameOfLife applet = new TheGameOfLife();
		applet.isStandalone = true;
		JFrame frame = new JFrame();
		// EXIT_ON_CLOSE == 3
		frame.setDefaultCloseOperation(3);
		frame.setTitle("The game of life");
		frame.getContentPane().add(applet, BorderLayout.CENTER);
		applet.init();
		applet.start();
		frame.setSize(425, 350);
		Dimension d = Toolkit.getDefaultToolkit().getScreenSize();
		frame.setLocation((d.width - frame.getSize().width) / 2,
				(d.height - frame.getSize().height) / 2);
		frame.setVisible(true);
	}

	// static initializer for setting look & feel
	static {
		try {
			// UIManager.setLookAndFeel(UIManager.getSystemLookAndFeelClassName());
			// UIManager.setLookAndFeel(UIManager.getCrossPlatformLookAndFeelClassName());
		} catch (Exception e) {
		}
	}

	void showAbout() {
		JOptionPane
				.showMessageDialog(
						this,
						"THE GAME OF LIFE 1.0\n\nby Marc Oliveras Galvez, 2017. All rights reserved.\n\nadmin@oligalma.com\n\nhttp://www.oligalma.com",
						"About...", JOptionPane.PLAIN_MESSAGE);
	}

}