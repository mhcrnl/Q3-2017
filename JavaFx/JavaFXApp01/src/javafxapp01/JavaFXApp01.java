/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package javafxapp01;

import javafx.application.Application;
import javafx.event.ActionEvent;
import javafx.event.EventHandler;
import javafx.scene.Scene;
import javafx.scene.control.Button;
import javafx.scene.layout.BorderPane;
import javafx.scene.layout.Pane;
import javafx.scene.layout.StackPane;
import javafx.scene.paint.Color;
import javafx.scene.shape.Circle;
import javafx.scene.shape.Line;
import javafx.scene.shape.Rectangle;
import javafx.stage.Stage;

/**
 *
 * @author mhcrnl
 */
public class JavaFXApp01 extends Application {
    
    @Override
    public void start(Stage primaryStage) {
        Button btn = new Button();
        btn.setText("Say 'Hello World'");
        btn.setOnAction(new EventHandler<ActionEvent>() {
            
            @Override
            public void handle(ActionEvent event) {
                System.out.println("Hello World!");
            }
        });
        
        Button bClose = new Button();
        bClose.setText("Close");
        bClose.setOnAction(new EventHandler<ActionEvent>(){ 
            @Override
            public void handle(ActionEvent event) {
                //To change body of generated methods, choose Tools | Templates.
                System.exit(0);
            }
            
        });
        
        Pane root = new Pane();
        
        Rectangle rect = new Rectangle(45,45,50,50);
        rect.setFill(Color.CADETBLUE);
        
        Line line = new Line(90, 40, 230, 40);
        line.setStroke(Color.BLACK);
        
        Circle circle = new Circle(130,130,30);
        circle.setFill(Color.CHOCOLATE);
        
        root.getChildren().addAll(rect, line, circle, bClose);
        //root.setTop(btn);
        //root.setCenter(bClose);
        
        Scene scene = new Scene(root, 300, 250, Color.AQUAMARINE);
        scene.setFill(Color.ANTIQUEWHITE);
        
        primaryStage.setTitle("Hello World!");
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
