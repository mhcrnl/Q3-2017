package salut01;

import java.io.*;

public class salut {
	
	public static void afiseazaCodare(){
		//File fisier = new File("fisier.in", "rw");
		try{
			FileInputStream fis = new FileInputStream("fisier.in");
			InputStreamReader isr = new InputStreamReader(fis);
			System.out.println("Codarea este: "+isr.getEncoding());
		} catch (IOException e){
			System.out.println("Eroare scriere fisier: "+e);
		}
		//close(fisier);
	}
	public static void main(String args[]){
		System.out.println("Primul program java");
		afiseazaCodare();
	}
}
