/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
//package texttable;


//**************************************
// Name: Save Data in Text File
// Description:I found in www.java2s.com this code.
///Data in JTextField's.
//Add some lines in the code to check 
//if any data is complete (not empty).
//If not, let me know with a message.
//Then save the data in a text file.
// By: Leo
//
//
// Inputs:None
//
// Returns:None
//
//Assumes:None
//
//Side Effects:None
//**************************************

// Save Data in Text File
import java.awt.FlowLayout;
import java.awt.Frame;
import java.awt.GridLayout;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.FileWriter;
import java.io.IOException;
import javax.swing.JOptionPane;
import javax.swing.JButton;
import javax.swing.JDialog;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JTextField;


    class AddressDialog extends JDialog {
    private JLabel label1 = new JLabel("Address");
    private JLabel label2 = new JLabel("City");
    private JLabel label3 = new JLabel("State");
    private JLabel label4 = new JLabel("Zip Code");
    private JTextField addressField = new JTextField();
    private JTextField cityField = new JTextField();
    private JTextField stateField = new JTextField();
    private JTextField zipCodeField = new JTextField();
    private JButton buttonOk = new JButton("Ok");
    String[] address = new String[4];


        public AddressDialog(Frame owner, boolean modal) {
        super(owner, modal);


            ActionListener actionListener = new ActionListener() {


                	public void actionPerformed(ActionEvent ev) {
                	FileWriter writer;
                	//writer = new FileWriter("MyData.txt");
                	String addr = addressField.getText();
                	String city = cityField.getText();
                	String state = stateField.getText();
                	String zip = zipCodeField.getText();


                    	try {
                    		writer = new FileWriter("MyData.txt");
                    		if (
                    			(!addr.equals("")) & 
                    			(!city.equals("")) & 
                    			(!state.equals("")) & 
                    			(!zip.equals(""))


                        		) {
                        		writer.write("Address: " + addr + System.getProperty("line.separator"));
                        		writer.write("City :" + city + System.getProperty("line.separator"));
                        		writer.write("State: " + state + System.getProperty("line.separator"));
                        		writer.write("Zip: " + zip + System.getProperty("line.separator"));
                        		writer.flush();
                        		writer.close();
                        		}
                        		else { 
                        		writer.close(); 
                        		JOptionPane.showMessageDialog(null, "Some text box is empty!", 
                        			"Error!", JOptionPane.WARNING_MESSAGE);
                        		};


                            	} catch (IOException ex) {
                            		ex.printStackTrace();
                            	}
                            	}
                        };
                        buttonOk.addActionListener(actionListener);
                        init();
                    }


                        private void init() {
                        this.setTitle("Address Dialog");
                        this.setLayout(new GridLayout(5, 2));
                        this.add(label1);
                        this.add(addressField);
                        this.add(label2);
                        this.add(cityField);
                        this.add(label3);
                        this.add(stateField);
                        this.add(label4);
                        this.add(zipCodeField);
                        this.add(buttonOk);
                    }


                        public String[] getAddress() {
                        address[0] = addressField.getText();
                        address[1] = cityField.getText();
                        address[2] = stateField.getText();
                        address[3] = zipCodeField.getText();
                        return address;
                    }
                }
                //********************************************************


                    class JDialogTest extends JFrame {
                    AddressDialog dialog = new AddressDialog(this, false);


                        public JDialogTest(String title) {
                        super(title);
                        init();
                    }


                        public JDialogTest() {
                        super();
                        init();
                    }


                        private void init() {
                        this.getContentPane().setLayout(new FlowLayout());
                        this.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
                        final AddressDialog dialog = new AddressDialog(this, false);
                        JButton button = new JButton("Show Dialog");


                            button.addActionListener(new ActionListener() {


                                public void actionPerformed(ActionEvent ae) {
                                dialog.setSize(250, 120);
                                dialog.setVisible(true);
                            }
                        });
                        this.getContentPane().add(button);
                        JButton button2 = new JButton("Exit");


                            button2.addActionListener(new ActionListener() {


                                public void actionPerformed(ActionEvent ae) {
                                System.exit(0);
                            }
                        });
                        this.getContentPane().add(button2);
                    }


                        public static void main(String[] args) {
                        JFrame.setDefaultLookAndFeelDecorated(true);
                        JDialog.setDefaultLookAndFeelDecorated(true);
                        JDialogTest frame = new JDialogTest();
                        frame.pack();
                        frame.setVisible(true);
                    }
                }

		
