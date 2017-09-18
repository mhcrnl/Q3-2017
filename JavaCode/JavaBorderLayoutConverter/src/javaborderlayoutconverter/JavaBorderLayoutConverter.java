/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package javaborderlayoutconverter;

import java.awt.BorderLayout;
import java.awt.Container;
import java.awt.Dimension;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import javax.swing.*;
/**
 *
 * @author mhcrnl
 */
public class JavaBorderLayoutConverter {
    
    public static boolean RIGHT_TO_LEFT = false;
    //ButtonClose BHClose = new ButtonClose();
    private JTextField tfCelsius, tfFahrenheit;
    
    public void addComponentsToPane(Container pane){
        
        if(!(pane.getLayout() instanceof BorderLayout)) {
            pane.add(new JLabel("Container doesn't use BorderLayout!"));
            return;
        }
        
        if(RIGHT_TO_LEFT) {
            pane.setComponentOrientation(
                    java.awt.ComponentOrientation.RIGHT_TO_LEFT);
        }
        
        JButton bCalculeaza = new JButton("Calculeaza");
        pane.add(bCalculeaza, BorderLayout.PAGE_START);
        ButtonCalculeaza bhCalculeaza = new ButtonCalculeaza();
        bCalculeaza.addActionListener(bhCalculeaza);
        
        JButton bClose = new JButton("Inchide");
        pane.add(bClose, BorderLayout.PAGE_END);
        //Adauga evenimet inchiderea ferestrei
        ButtonClose BHClose = new ButtonClose();
        bClose.addActionListener(BHClose);
        
        JLabel lCelsius= new JLabel("Celsius to Fahrenheit");
        lCelsius.setPreferredSize(new Dimension(100, 100));
        pane.add(lCelsius, BorderLayout.LINE_START);
        
        tfCelsius = new JTextField();
        tfCelsius.setPreferredSize(new Dimension(100,100));
        pane.add(tfCelsius, BorderLayout.CENTER);
    /**  
        JLabel lFahrenheit= new JLabel("Fahrenheit");
        lFahrenheit.setPreferredSize(new Dimension(100, 100));
        pane.add(lFahrenheit, BorderLayout.AFTER_LINE_ENDS);
    */    
        tfFahrenheit = new JTextField();
        tfFahrenheit.setPreferredSize(new Dimension(100,100));
        pane.add(tfFahrenheit, BorderLayout.LINE_END);
        
    }

    class ButtonCalculeaza implements ActionListener{

        @Override
        public void actionPerformed(ActionEvent ae) {
            //System.exit(0);
            double celsius = Double.parseDouble(tfCelsius.getText());
            double fahrenheit = (celsius * 9.0/5.0)+32;
            tfFahrenheit.setText(String.valueOf(fahrenheit));
        }
        
    }

    private static void createAndShowGUI() {
        JFrame frame = new JFrame("JavaBorderLayoutConverter");
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        JavaBorderLayoutConverter jblc = new JavaBorderLayoutConverter();
        jblc.addComponentsToPane(frame.getContentPane());
        frame.pack();
        frame.setVisible(true);
    }
    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {
        // TODO code application logic here
        try {
            UIManager.setLookAndFeel("javax.swing.plaf.metal.MetalLookAndFeel");
          
        } catch(UnsupportedLookAndFeelException ex) {
            ex.printStackTrace();
            
        } catch (IllegalAccessException ex){
            ex.printStackTrace();
        } catch (InstantiationException ex) {
            ex.printStackTrace();
        }catch (ClassNotFoundException ex) {
            ex.printStackTrace();
        }
        
        UIManager.put("swing.boldMetal", Boolean.FALSE);
        
        javax.swing.SwingUtilities.invokeLater(new Runnable(){
            public void run() {
                createAndShowGUI();
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