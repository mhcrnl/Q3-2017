/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package javaconsoleconvertorctof;

import java.util.Scanner;

/**
 *
 * @author mhcrnl
 */
public class JavaConsoleConvertorCtoF {

    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {
        // TODO code application logic here
        System.out.println("Convertor  from Celsius to Fahrenheit.");
        double cel, far;
        Scanner in = new Scanner(System.in);
        System.out.print("Enter temp. in Fahrenheit: ");
        cel = in.nextInt();
        far = (cel*9/5.0) + 32;
        System.out.println("Temp. in Fahrenheit is: " + far);
    }
    
}
