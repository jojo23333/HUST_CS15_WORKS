package MyApplication;

import javafx.application.Application;
import javafx.fxml.FXMLLoader;
import javafx.scene.Scene;
import javafx.scene.layout.Pane;
import javafx.stage.Stage;

public class MyApplication extends Application {

    public static void main(String[] args) {
        launch(args);
    }

    @Override
    public void start(Stage primaryStage) {
        try {
            System.out.println("hello");
            FXMLLoader loader = new FXMLLoader(getClass().getResource("loginView.fxml"));
            Pane root = loader.load();

            LoginController loginController = loader.getController();
            loginController.setMyApp(this);

            Scene scene = new Scene(root);
            primaryStage.setScene(scene);
            primaryStage.show();
            System.out.println("hello2");
        }catch (Exception e){
            e.printStackTrace();
        }
    }

}
