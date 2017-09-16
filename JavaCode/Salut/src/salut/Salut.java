/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package salut;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;

/**
 *
 * @author mhcrnl
 */
public class Salut {
    public static void scrieInFisier(String fila){
        
        File file = new File(fila);
        int b = 2344;
        try {
            file.createNewFile();// if file already exists will do nothing 
            FileOutputStream fos = new FileOutputStream(file);
            fos.write(b);
            //InputStreamReader isr = new InputStreamReader(fis);
            //System.out.println("Codificarea fisierului este: "+isr.getEncoding());
        } catch(IOException e) {
            System.out.println("Eroare scriere fisier "+ e);
        }
    }
    /**
     * Creaza o fila si afiseaza codarea acesteia
     * @param fisier 
     */
    public static void afisareCodare(String fisier){
        
        File file = new File(fisier);
        
        try {
            file.createNewFile();// if file already exists will do nothing 
            FileInputStream fis = new FileInputStream(file);
            InputStreamReader isr = new InputStreamReader(fis);
            System.out.println("Codificarea fisierului este: "+isr.getEncoding());
        } catch(IOException e) {
            System.out.println("Eroare scriere fisier "+ e);
        }
        
    }
    /**
     * Creaza un fisier "fisier.txt" si afiseaza codarea acestuia
     * @throws IOException 
     */
    public static void afiseazaCodare() throws IOException{
        
        File fisier = new File("fisier.txt");
        fisier.createNewFile();// if file already exists will do nothing 
        
        try {
            FileInputStream fis = new FileInputStream(fisier);
            InputStreamReader isr = new InputStreamReader(fis);
            System.out.println("Codificarea fisierului este: "+isr.getEncoding());
        } catch (IOException e) {
            System.out.println("Eroare scriere fisier "+ e);
        }
        
    }

    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) throws IOException {
        // TODO code application logic here
        System.out.println("SALUT!");
        afiseazaCodare();
        
        String f = "fila.txt";
        afisareCodare(f);
        
        String f1 = "scrie.txt";
        scrieInFisier(f1);
    }
    
}
