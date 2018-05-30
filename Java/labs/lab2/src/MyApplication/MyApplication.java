package MyApplication;

import javafx.application.Application;
import javafx.fxml.FXMLLoader;
import javafx.scene.Scene;
import javafx.scene.layout.Pane;
import javafx.stage.Stage;

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
            mysql = new SqlConnector();
        }catch (Exception e){
            e.printStackTrace();
        }
    }



}
