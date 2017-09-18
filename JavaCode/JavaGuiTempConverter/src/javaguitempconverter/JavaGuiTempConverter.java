/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package javaguitempconverter;

import java.awt.Container;
import java.awt.GridLayout;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.text.DecimalFormat;
import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JTextField;

/**
 *
 * @author mhcrnl
 */
public class JavaGuiTempConverter extends JFrame {
    
    private static final double CelsiusToFahrenheit = 9.0/5.0;
    private static final double FahrenheitToCelsius = 5.0/9.0;
    private static final int offset = 32;
    private JLabel LFahrenheit, LCelsius;
    private JTextField TFFahrenheit, TFCelsius;
    private JButton BConvert, BClear;
    private ConvertButtonHandler ConvButtonHandler;
    private ClearHandlerClass ClearHandler;
    
    public void temperatureConverter(){
       setTitle("Temperature Converter");
       Container pane = getContentPane();
       pane.setLayout(new GridLayout(1,5));
       
       LFahrenheit = new JLabel("Fahrenheit:", JLabel.CENTER);
       pane.add(LFahrenheit);
       TFFahrenheit = new JTextField();
       pane.add(TFFahrenheit);
       
       BConvert = new JButton("Convert");
       pane.add(BConvert);
       ConvButtonHandler = new ConvertButtonHandler();
       BConvert.addActionListener(ConvButtonHandler);
       
       BClear = new JButton("Clear");
       pane.add(BClear);
       ClearHandler = new ClearHandlerClass();
       BClear.addActionListener(ClearHandler);
       
       LCelsius = new JLabel("Celsius:", JLabel.CENTER);
       pane.add(LCelsius);
       TFCelsius = new JTextField();
       pane.add(TFCelsius);
       
       setSize(600, 150);
       setVisible(true);
       setDefaultCloseOperation(EXIT_ON_CLOSE);
    }
    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {
        // TODO code application logic here
        JavaGuiTempConverter tc = new JavaGuiTempConverter();
        tc.temperatureConverter();
    }
    class ConvertButtonHandler implements ActionListener{
        public void actionPerformed(ActionEvent e){
            double celsius=0, fahrenheit=0;
            DecimalFormat towDigits = new DecimalFormat("0.00");
            
            if(TFCelsius.getText()==null || "".equals(TFCelsius.getText().trim())){
                fahrenheit = Double.parseDouble(TFFahrenheit.getText());
                celsius = (fahrenheit-offset)*FahrenheitToCelsius;
                TFCelsius.setText(" "+towDigits.format(celsius));
            } else if(TFFahrenheit.getText()==null || "".equals(TFFahrenheit.getText().trim())){
                celsius = Double.parseDouble(TFCelsius.getText());
                fahrenheit = celsius*CelsiusToFahrenheit + offset;
                TFFahrenheit.setText(" "+towDigits.format(fahrenheit));
            }
        }
    }
    class ClearHandlerClass implements ActionListener{

        @Override
        public void actionPerformed(ActionEvent ae) {
            //To change body of generated methods, choose Tools | Templates.
            TFCelsius.setText("");
            TFFahrenheit.setText("");
        }
        
    }
}

