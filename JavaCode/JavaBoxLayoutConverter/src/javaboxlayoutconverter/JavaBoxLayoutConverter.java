/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package javaboxlayoutconverter;

import java.awt.BorderLayout;
import java.awt.Container;
import java.awt.Dimension;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.*;
/**
 *
 * @author mhcrnl
 */
public class JavaBoxLayoutConverter {
    
    private JTextField tfCel, tfFah;
    private ButtonCalculeaza bhCalc;
    
    public void addComponentsToPane(Container pane){
        pane.setLayout(new BoxLayout(pane, BoxLayout.Y_AXIS));
        
        JLabel lCel = new JLabel("Celsius");
        pane.add(lCel);
        
        tfCel = new JTextField();
        pane.add(tfCel);
        
        JLabel lFah = new JLabel("Fahrenheit");
        pane.add(lFah);
        
        tfFah = new JTextField();
        pane.add(tfFah);
        
        JButton bCalc = new JButton("Calculeaza");
        //bCalc.setPreferredSize(new Dimension(250,50));
        pane.add(bCalc);
        bhCalc = new ButtonCalculeaza();
        bCalc.addActionListener(bhCalc);
        
        JButton bClose = new JButton("Inchide");
        //bClose.setPreferredSize(new Dimension(250,50));
        pane.add(bClose);
        ButtonClose bc = new ButtonClose();
        bClose.addActionListener(bc);
    }
    
    class ButtonCalculeaza implements ActionListener{

        @Override
        public void actionPerformed(ActionEvent ae) {
            //System.exit(0);
            double celsius = Double.parseDouble(tfCel.getText());
            double fahrenheit = (celsius * 9.0/5.0)+32;
            tfFah.setText(String.valueOf(fahrenheit));
        }
        }
    /**
     * @param args the command line arguments
     */
   private void createAndShowGUI() {
        //JFrame.setDefaultLookAndFeelDecoreted(true);
        //Create and setup the window
        JFrame frame = new JFrame("Java BoxLayout Converter");
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        
        //JLabel emptyLabel = new JLabel("");
        //emptyLabel.setPreferredSize(new Dimension(575,300));
        frame.setPreferredSize(new Dimension(250,200));
        //frame.getContentPane().add(emptyLabel, BorderLayout.CENTER);
        addComponentsToPane(frame.getContentPane());
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
                JavaBoxLayoutConverter jblc = new JavaBoxLayoutConverter();
                jblc.createAndShowGUI();
            }
        });
    }
    
}

class ButtonClose implements ActionListener{

        @Override
        public void actionPerformed(ActionEvent ae) {
            System.exit(0);
        }
        
    }
