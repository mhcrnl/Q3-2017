
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
   JTextField tfDecimal, tfHexadecimal, tfBinary, tfOctal;
   
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
       JMenuItem o1= new JMenuItem("Calculeaza");
       JMenuItem sterge = new JMenuItem("Sterge");
       JMenuItem o2= new JMenuItem("Exit");
       
       o1.addActionListener(new ActionListener() { 

           @Override
           public void actionPerformed(ActionEvent ae) {
               String decimalValue = tfDecimal.getText();
               int value = Integer.parseInt(decimalValue);
               String hexadecimalvalue =Integer.toHexString(value);
               tfHexadecimal.setText(hexadecimalvalue);
               String binaryValue = Integer.toBinaryString(value);
               tfBinary.setText(binaryValue);
               String octalValue = Integer.toOctalString(value);
               tfOctal.setText(octalValue);
           }       
        });
       o2.addActionListener(new ActionListener() { 

           @Override
           public void actionPerformed(ActionEvent ae) {
               System.exit(0);
           }       
        });
       sterge.addActionListener(new ActionListener() { 

           @Override
           public void actionPerformed(ActionEvent ae) {
               //System.exit(0);
               tfDecimal.setText("");
               tfHexadecimal.setText("");
               tfBinary.setText("");
               tfOctal.setText("");
           }       
        });
       
       unelte.add(o1);
       unelte.add(sterge);
       unelte.addSeparator();
       unelte.add(o2);
       return unelte;
    }
    
    protected void faContinut() throws Exception{
        JPanel continut = new JPanel();
        this.getContentPane().add(continut, BoxLayout.X_AXIS);
        
        JLabel lDecimal = new JLabel("Decimal");
        continut.add(lDecimal);
        
        tfDecimal = new  JTextField();
        tfDecimal.setPreferredSize(new Dimension(150,30));
        continut.add(tfDecimal);
        
        JLabel lHexadecimal = new JLabel("To Hexadecimal");
        continut.add(lHexadecimal);
        
        tfHexadecimal = new  JTextField();
        tfHexadecimal.setPreferredSize(new Dimension(150,30));
        continut.add(tfHexadecimal);
        
        JLabel lBinary = new JLabel("And Binary");
        continut.add(lBinary);
        
        tfBinary = new  JTextField();
        tfBinary.setPreferredSize(new Dimension(150,30));
        continut.add(tfBinary);
        
        JLabel lOctal = new JLabel(", Octal");
        continut.add(lOctal);
        
        tfOctal = new  JTextField();
        tfOctal.setPreferredSize(new Dimension(150,30));
        continut.add(tfOctal);
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
