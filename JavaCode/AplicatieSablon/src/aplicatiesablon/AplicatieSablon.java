/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package aplicatiesablon;

//import FereastraAplicatieSablon;

import java.util.logging.Level;
import java.util.logging.Logger;


/**
 *
 * @author mhcrnl
 */
public class AplicatieSablon {

    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {
        // TODO code application logic here
        javax.swing.SwingUtilities.invokeLater(new Runnable(){
            public void run() {
                FereastraAplicatieSablon jblc;
                try {
                    jblc = new FereastraAplicatieSablon();
                    jblc.setVisible(true);
                } catch (Exception ex) {
                    Logger.getLogger(AplicatieSablon.class.getName()).log(Level.SEVERE, null, ex);
                }
                
            }
        });
    }
    
}
