/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package examplecom;

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
public class ExampleCom {
    
    public static void incarcaUrl(String url) throws IOException{
        
        Document doc = Jsoup.connect(url).get();
        String titlu = doc.title();
        System.out.println(titlu);
        
        String continut = doc.getElementsByTag("h1").text();
        String continut1 = doc.getElementsByTag("p").text();
        String continut2 = doc.getElementsByTag("a").text();
        String continut3 = doc.getElementsByTag("a").attr("href");
        String continut4 = doc.getElementsByTag("style").toString();
        String continut5 = doc.getElementsByTag("meta").toString();
        String continut6 = doc.getElementsByTag("meta").attr("charset");
        String continut7 = doc.getElementsByTag("div").toString();
        //Elements 
        System.out.println(continut);
        System.out.println(continut2);
        System.out.println(continut1);
        System.out.println(continut3);
        System.out.println(continut4);
        System.out.println(continut5);
        System.out.println(continut6);
        System.out.println(continut7);
        
        Elements elem = doc.getElementsByTag("p");
        for(Element el: elem){
            String str = el.text();
            System.out.println(str);
        }
    }

    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {
        // TODO code application logic here
        System.out.println("Jsoup situl example.com!");
        
        String url = "http://example.com/";
        try {
            incarcaUrl(url);
        } catch (IOException ex) {
            Logger.getLogger(ExampleCom.class.getName()).log(Level.SEVERE, null, ex);
        }
    }
    
}
