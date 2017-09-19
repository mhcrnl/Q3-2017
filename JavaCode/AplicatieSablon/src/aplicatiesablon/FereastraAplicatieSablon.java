
package aplicatiesablon;

import java.awt.BorderLayout;
import java.awt.Dimension;
import java.awt.Image;
import java.awt.Toolkit;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;
import javax.swing.*;
import javax.swing.border.BevelBorder;
import javax.swing.border.SoftBevelBorder;


/**
 *
 * @author mhcrnl
 */
public class FereastraAplicatieSablon extends JFrame {
    
   static JMenuBar meniuBara;
   Image img;
   int pozitie = 230;
   //Constructorul
   public FereastraAplicatieSablon() throws Exception {
       super("Fereastra Aplicatie");
       Toolkit t = this.getToolkit();
       Dimension marimeEcran = Toolkit.getDefaultToolkit().getScreenSize();
       setBounds(pozitie, pozitie, marimeEcran.width-2*pozitie, 
               marimeEcran.height/2-30);
       this.getContentPane().setLayout(new BorderLayout());
       faMeniu();
       faContinut();
       faBaraStare();
       this.addWindowListener(new WindowAdapter(){ 
          public void windowClosing(WindowEvent e){
              iesire();
          } 
       });
    }
    public void iesire(){
        System.exit(0);
    }
    protected void faMeniu(){
        meniuBara = new JMenuBar();
        meniuBara.setOpaque(true);
        JMenu optiuni = faMeniuOptiuni();
        optiuni.setMnemonic('O');
        meniuBara.add(optiuni);
        setJMenuBar(meniuBara);
    }
    protected JMenu faMeniuOptiuni(){
       JMenu unelte = new JMenu("Optiuni");
       JMenuItem o1= new JMenuItem("Optiune 1");
       JMenuItem o2= new JMenuItem("Optiune 2");
       
       o1.addActionListener(new ActionListener() { 

           @Override
           public void actionPerformed(ActionEvent ae) {  
           }       
        });
       o2.addActionListener(new ActionListener() { 

           @Override
           public void actionPerformed(ActionEvent ae) {  
           }       
        });
       
       unelte.add(o1);
       unelte.addSeparator();
       unelte.add(o2);
       return unelte;
    }
    
    protected void faContinut() throws Exception{
        JPanel continut = new JPanel();
        this.getContentPane().add(continut, BorderLayout.CENTER);
    }
    
    protected void faBaraStare() {
        JPanel ajutor = new JPanel();
        ajutor.setBorder(new SoftBevelBorder(SoftBevelBorder.RAISED));
        ajutor.setLayout(new BorderLayout());
        JLabel stare = new JLabel("Bine ati venit! Wellcome!");
        ajutor.add(stare, BorderLayout.CENTER);
        this.getContentPane().add(ajutor, BorderLayout.SOUTH);
    }
}
