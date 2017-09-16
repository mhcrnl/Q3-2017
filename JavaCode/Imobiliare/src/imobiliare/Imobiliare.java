/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package imobiliare;

//import javax.swing.text.Document;
import java.io.IOException;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;

/**
 *
 * @author mhcrnl
 */
public class Imobiliare {
    public static void incarcaUrl(String url) throws IOException{
       Document doc = Jsoup.connect(url).get();
       String title = doc.title();
       System.out.println(title);
       
       Element content = doc.getElementById("content");
       Elements links = content.getElementsByTag("a");
       for (Element link : links) {
            String linkHref = link.attr("href");
            //System.out.println(linkHref);
            String linkText = link.text();
            System.out.println(linkHref+"<<>>"+linkText);
        }
       Elements preturi = content.getElementsByClass("pret");
       for(Element pret: preturi){
           String pretul = pret.text();
           System.out.println(pretul);
       }
        Elements titluri = content.getElementsByClass("titlu-anunt hidden-xs");
       for(Element titlul: titluri){
           String pretul = titlul.text();
           System.out.println(pretul);
       }
        Elements loc = content.getElementsByClass("localizare");
       for(Element locul: loc){
           String pretul = locul.text();
           System.out.println(pretul);
       }
        Elements row = content.getElementsByClass("row");
       for(Element dat: row){
           String pretul = dat.text();
           System.out.println(pretul);
       }
    }

    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) throws IOException {
        // TODO code application logic here
        System.out.println("Aplicatia Imobiliare se executa!");
        String html = "<html><head><title>First parse</title></head>"
  + "<body><p>Parsed HTML into a doc.</p></body></html>";
    Document doc = (Document) Jsoup.parse(html);
    Element body = doc.body();
    
    incarcaUrl("https://www.imobiliare.ro/vanzare-apartamente/bucuresti");
    }
    
}
