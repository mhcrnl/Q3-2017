/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package emaglaptop;

import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;

/**
 *
 * @author mhcrnl
 */
public class EmagLaptop {
    
    public static void incarcaUrl(String url) throws IOException{
        //incarcarea documentului din adresa url
        Document doc = Jsoup.connect(url).get();
        String title = doc.title();
        System.out.println(title);
        
        Element content = doc.getElementById("content");
        System.out.println(content);
        
        Elements titluri = content.getElementsByClass("card-item js-product-data").first();
        for(Element titlul: titluri){
           String pretul = titlul.text();
           System.out.println(pretul);
        }
    } 

    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {
        // TODO code application logic here
        System.out.println("Preturi laptopuri la Emag.");
        
        String url = "https://www.emag.ro/laptopuri/c?tree_ref=2172&ref=cat_tree_91";
        try {
            incarcaUrl(url);
        } catch (IOException ex) {
            Logger.getLogger(EmagLaptop.class.getName()).log(Level.SEVERE, null, ex);
        }
        
    }
    
}
