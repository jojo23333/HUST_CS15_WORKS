package MyApplication;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;

import javafx.application.Application;
import javafx.application.Platform;
import javafx.event.EventHandler;
import javafx.fxml.FXMLLoader;
import javafx.scene.Scene;
import javafx.scene.layout.Pane;
import javafx.stage.Stage;
import javafx.stage.WindowEvent;

public class MyApplication extends Application{

    public static Stage curStage;
    public SqlConnector mysql;

    public static void main(String[] args) {
        launch(args);
    }

    @Override
    public void start(Stage primaryStage) {
        try {
            System.out.println("hello");
            FXMLLoader loader = new FXMLLoader(getClass().getResource("Welcome.fxml"));
            Pane root = loader.load();

            WelcomeController welcomeController = loader.getController();
//            welcomeController.setMyApp(this);

            Scene scene = new Scene(root);
            primaryStage.setScene(scene);
            primaryStage.show();
            curStage = primaryStage;
            
            System.out.println(System.getProperty("user.dir"));
            String url = "", port = "", password = "";
            try {
                File file = new File("config.txt");  
            	BufferedReader reader = new BufferedReader(new FileReader(file));  
                // 一次读入一行，直到读入null为文件结束  
                url = reader.readLine();
                port = reader.readLine();
                password = reader.readLine();
                reader.close();  
            } catch (IOException e) {
            	System.out.println("Not valid config file or no config file");
                e.printStackTrace();  
            }
            
            mysql = new SqlConnector( url, port, password);
            curStage.setOnCloseRequest(new EventHandler<WindowEvent>() {
                @Override
                public void handle(WindowEvent t) {
                	mysql.deleteView();
                    Platform.exit();
                    System.exit(0);
                }
            });
        }catch (Exception e){
            e.printStackTrace();
        }
    }


}
