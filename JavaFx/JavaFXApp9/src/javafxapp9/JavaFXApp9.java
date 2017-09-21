/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package javafxapp9;

import javafx.application.Application;
import javafx.event.ActionEvent;
import javafx.event.EventHandler;
import javafx.scene.Group;
import javafx.scene.Scene;
import javafx.scene.control.Button;
import javafx.scene.control.Menu;
import javafx.scene.control.MenuBar;
import javafx.scene.control.MenuItem;
import javafx.scene.control.SeparatorMenuItem;
import javafx.scene.input.KeyCombination;
import javafx.scene.layout.StackPane;
import javafx.scene.layout.VBox;
import javafx.scene.paint.Color;
import javafx.scene.text.Font;
import javafx.scene.text.FontWeight;
import javafx.scene.text.Text;
import javafx.stage.Stage;

/**
 *
 * @author mhcrnl
 */
public class JavaFXApp9 extends Application {
    
    @Override
    public void start(Stage primaryStage) {
/**        
        Button btn = new Button();
        btn.setText("Say 'Hello World'");
        btn.setOnAction(new EventHandler<ActionEvent>() {
            
            @Override
            public void handle(ActionEvent event) {
                System.out.println("Hello World!");
            }
        });
        
        StackPane root = new StackPane();
        root.getChildren().add(btn);
*/       
        //Group group = new Group();
        Scene scene = new Scene(new VBox(), 400, 350);
        
        scene.setFill(Color.ANTIQUEWHITE);
        primaryStage.setTitle("Aplicatie");
        //--MenuBar from application
        MenuBar menuBar = new MenuBar();
        //----Menu File
        Menu menuFile = new Menu("File");
        menuFile.setAccelerator(KeyCombination.keyCombination("Ctrl+F"));
        //------MenuItem
        MenuItem miNew = new MenuItem("New");
        MenuItem exit = new MenuItem("Exit");
        exit.setAccelerator(KeyCombination.keyCombination("Ctrl+E"));//acelerator
        //--------MenuItem add event with anonimus inner class 
        exit.setOnAction(new EventHandler<ActionEvent>(){ 
            @Override
            public void handle(ActionEvent event) {
                 System.exit(0);
            }
            
        });
        menuFile.getItems().addAll(miNew, new SeparatorMenuItem(), exit);
        
        Menu menuEdit = new Menu("Edit");
        Menu menuView = new Menu("View");
        Menu menuHelp = new Menu("Help");
        
        Text text = new Text("JavaFX");
        text.setFont(Font.font("Sherif", FontWeight.BOLD, 100));
        
        text.setId("text");
        //primaryStage.setId("root");
        
        scene.getStylesheets().add(this.getClass().getResource("text.css")
                .toExternalForm());
        
        menuBar.getMenus().addAll(menuFile, menuEdit, menuView, menuHelp);
        ((VBox) scene.getRoot()).getChildren().addAll(menuBar, text);
        
        
        
        //primaryStage.setTitle("Hello World!");
        primaryStage.setScene(scene);
        primaryStage.show();
    }

    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {
        launch(args);
    }
    
}
