/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package end;

/**
 *
 * @author Bruno Ramalhete
 */
public class End {
    private static int accountNum=0;
    
    public static int getAccountNum() {
        return accountNum;
    }
    
    public static void increaseAccountNum() {
        accountNum++;
    }
}
