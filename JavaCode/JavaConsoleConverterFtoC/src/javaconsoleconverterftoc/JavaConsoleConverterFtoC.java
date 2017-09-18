/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package javaconsoleconverterftoc;

import java.util.Scanner;

/**
 *
 * @author mhcrnl
 */
public class JavaConsoleConverterFtoC {

    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {
        // TODO code application logic here
        System.out.println("Welcome to Converter Fahrenheit To Celsius");
        float temperatura;
        Scanner in = new Scanner(System.in);
        System.out.print("Enter the temperature in Fahrenheit: ");
        temperatura = in.nextInt();
        temperatura = ((temperatura - 32) * 5) / 9;
        System.out.println("The temperature in Celsius is: " + temperatura);
    }

}
