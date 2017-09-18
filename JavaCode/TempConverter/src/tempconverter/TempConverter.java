/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package tempconverter;

import java.util.Scanner;

/**
 *
 * @author mhcrnl
 */
public class TempConverter {
    public static void convertTemperature(){
        Scanner input = new Scanner(System.in);
        print("\nEnter 1 for Fahrenheit to Celsius"
            + "\nEnter 2 for Celsius to Fahrenheit"
            + "\nEnter something else to exit"
            + "\nYour option: ");
        int selection = input.nextInt();
        if(selection == 1){
            print("Enter a degree in Fahrenheit: ");
            far2cel();
        } else if (selection == 2) {
            print("Enter a degree in Celsius: ");
            cel2far();
        } else {
            print("Bye....");
        }    
    }    
    public static void far2cel(){
        Scanner input = new Scanner(System.in);
        double Fahrenheit = input.nextDouble();
        print(Fahrenheit+" Fahrenheit is "+(Fahrenheit-32)*(5/9.0)+" Celsius");
        convertTemperature();
    }    
    public static void cel2far(){
        Scanner input = new Scanner(System.in);
        double Celsius = input.nextDouble();
        print(Celsius+" Celsius is "+((Celsius*9/5.0)+32)+" Fahrenheit");
        convertTemperature();
    }
    public static void print(String str){
        System.out.print("\n" + str);
    }
    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {
        // TODO code application logic here
        print ("==== CONVERTING TEMPERATURE ====\n");
        convertTemperature();
    }
    
}
