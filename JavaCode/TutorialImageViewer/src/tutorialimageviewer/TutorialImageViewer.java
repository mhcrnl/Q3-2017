/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package tutorialimageviewer;

import java.awt.BorderLayout;
import java.awt.Dimension;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.File;
//import java.io.FileFilter;
import javax.swing.*;
import javax.swing.filechooser.FileFilter;

/**
 *
 * @author mhcrnl
 */
public class TutorialImageViewer extends JFrame {

    /**
     * @param args the command line arguments
     */
    public TutorialImageViewer() {
        this.setDefaultCloseOperation(EXIT_ON_CLOSE);

        this.setTitle("Image Viewer");
        this.setSize(240, 100);
        JButton openButton = new JButton("Open Image");
        this.getContentPane().add(openButton);

        openButton.addActionListener(new ActionListener() {

            @Override
            public void actionPerformed(ActionEvent ae) {
                JFileChooser chooser = new JFileChooser(".");
                ExtensionFileFilter ff = new ExtensionFileFilter("Images Files",
                        new String[]{"jpg", "png", "gif"});
                chooser.setFileFilter((javax.swing.filechooser.FileFilter) ff);
                int status = chooser.showOpenDialog(TutorialImageViewer.this);

                if (status == JFileChooser.APPROVE_OPTION) {

                    try {
                        JFrame frame = new JFrame();
                        JLabel label = new JLabel();
                        JScrollPane sp = new JScrollPane(label);
                        sp.setPreferredSize(new Dimension(560, 480));
                        ImageIcon icon = new ImageIcon(chooser.getSelectedFile().toURL());
                        label.setIcon(icon);
                        frame.add(sp, BorderLayout.CENTER);
                        frame.pack();
                        String imgpath = chooser.getSelectedFile().toString();
                        frame.setTitle(imgpath);
                        frame.setVisible(true);

                    } catch (Exception e) {
                        System.err.println("Error: " + e);
                    }
                }
                repaint();
            }
        });
    }

    public static void main(String[] args) {
        TutorialImageViewer tim = new TutorialImageViewer();
        tim.setVisible(true);
    }
}

class ExtensionFileFilter extends FileFilter {

    String description;
    String extensions[];

    public ExtensionFileFilter(String description, String extension) {
        this(description, new String[]{extension});
    }

    public ExtensionFileFilter(String description, String extensions[]) {

        if (description == null) {
            this.description = extensions[0];

        } else {
            this.description = description;
        }
        this.extensions = (String[]) extensions.clone();
        toLower(this.extensions);
    }

    private void toLower(String array[]) {

        for (int i = 0, n = array.length; i < n; i++) {
            array[i] = array[i].toLowerCase();
        }
    }

    public String getDescription() {
        return description;
    }

    public boolean accept(File file) {

        if (file.isDirectory()) {
            return true;

        } else {
            String path = file.getAbsolutePath().toLowerCase();

            for (int i = 0, n = extensions.length; i < n; i++) {
                String extension = extensions[i];
                if ((path.endsWith(extension)
                        && (path.charAt(path.length() - extension.length() - 1)) == '.')) {
                    return true;
                }
            }
        }
        return false;
    }
}
