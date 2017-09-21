/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package end;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.ObjectOutputStream;
import java.io.Serializable;
import java.io.StringReader;

/**
 *
 * @author Bruno Ramalhete
 */
public class Account{
    private String actName, username, password, cPassword, name, email, sQues, sAns, bday, phoneNum;
    public static String defaultLoc="/home/bruno/Documents/passVault"; // Don't forget to modify the location, depending on your system.
    
    
    public String getActName() {
        return actName;
    }
    
    public String getUsername() {
        return username;
    }
    
    public String getPassword() {
        return password;
    }
    
    public String getCPassword() {
        return cPassword;
    }
    
    public String getName() {
        return name;
    }
    
    public String getEmail() {
        return email;
    }
    
    public String getSQues() {
        return sQues;
    }
    
    public String getSAns() {
        return sAns;
    }
    
    public String getBday() {
        return bday;
    }
    
    public String getPhonenumber() {
        return phoneNum;
    }
    
    public void setActName(String a) {
        this.actName = a;
    }
    
    public void setUsername(String a) {
        this.username = a;
    }
    
    public void setPassword(String a) {
        this.password = a;
    }
    
    public void setCPassword(String a) {
        this.cPassword = a;
    }
    
    public void setName(String a) {
        this.name = a;
    }
    
    public void setEmail(String a) {
        this.email = a;
    }
    
    public void setSQues(String a) {
        this.sQues = a;
    }
    
    public void setSAns(String a) {
        this.sAns = a;
    }
    
    public void setBday(String a) {
        this.bday = a;
    }
    
    public void setPhonenumber(String a) {
        this.phoneNum = a;
    }
    
    public void recordInText() {
        try {
            
            FileWriter fw = new FileWriter(defaultLoc, true);
            BufferedWriter bw = new BufferedWriter(fw);
            bw.append("\n");
            bw.append("\n");
            bw.append("\n");
            bw.append("Account Number: " + End.getAccountNum() + "\n");
            bw.append("Account Name: ".concat(this.getActName()).concat("\n"));
            bw.append("Username: ".concat(this.getUsername()).concat("\n"));
            bw.append("Password: ".concat(new String(this.getPassword())).concat("\n"));
            bw.append("Name: ".concat(this.getName()).concat("\n"));
            bw.append("Email Address: ".concat(this.getEmail()).concat("\n"));
            bw.append("Security Question: ".concat(this.getSQues()).concat("\n"));
            bw.append("Security Question Answer: ".concat(this.getSAns()).concat("\n"));
            bw.append("Birthday: ".concat(this.getBday()).concat("\n"));
            bw.append("Phone Number: ".concat(this.getPhonenumber()).concat("\n"));
            bw.flush();
            bw.close();
            
        }
        catch(Exception e) {
            e.printStackTrace();
        }
        
        
        
        
    }
    
    
    public static void findActFromFile(String sentinel) {
        try{
            BufferedReader br = new BufferedReader(new FileReader(defaultLoc));
            int linecount=0;
            String line;
            String[] words=null;
            while (( line = br.readLine()) != null) {
                linecount++;
                words = line.split("\n");
                
            }
           System.out.println(linecount);
           System.out.println(words);

            for (String word : words) {
                    //if the sentinel is found in the split up reading
                    if(word.equals(sentinel)) {
                        System.out.println("sentinel found");
                        String[] accountInfoArr=new String[8];
                        gui.ShowActInfo sai = new gui.ShowActInfo();
                        String tempText = "Account Name:" + sentinel;
                        for(int counter=0;counter<7;counter++) {
                            //accountInfoArr[counter]=words[]
                            //tempText= tempText.concat(sai.field.getText() + "\n");
                            ///sai.field.setText(tempText + accountInfoArr[counter]);
                        }
                      
                        
                        sai.setVisible(true);
                        
                        //todo create showAct class w/ just a title and large jTextArea
                        //in the textArea just read the next lines and mirror them in the program
                        //to display the info for that account
                    } else {
                        System.out.println("sentinel not found");
                    }
                }
            } catch(Exception e) {
            e.printStackTrace();
            }
    }
     
    
}
