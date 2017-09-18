/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package fereastra;

import java.awt.BorderLayout;
import java.awt.Dimension;
import javax.swing.JFrame;
import javax.swing.JLabel;

/**
 * Template for JFrame
 * @author mhcrnl
 */
public class Fereastra {
    
    private void createAndShowGUI() {
        //JFrame.setDefaultLookAndFeelDecoreted(true);
        //Create and setup the window
        JFrame frame = new JFrame("Fereastra principala");
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        
        JLabel emptyLabel = new JLabel("");
        emptyLabel.setPreferredSize(new Dimension(575,300));
        frame.getContentPane().add(emptyLabel, BorderLayout.CENTER);
        
        //Display the window
        frame.pack();
        frame.setVisible(true);
    }

    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {
        // TODO code application logic here
        javax.swing.SwingUtilities.invokeLater(new Runnable(){
            public void run() {
                Fereastra f = new Fereastra();
                f.createAndShowGUI();
            }
        });
    }
    
}
