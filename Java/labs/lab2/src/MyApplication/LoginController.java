package MyApplication;

import javafx.fxml.FXML;
import javafx.fxml.FXMLLoader;
import javafx.scene.Scene;
import javafx.scene.control.PasswordField;
import javafx.scene.control.TextField;
import javafx.scene.control.Button;
import javafx.event.ActionEvent;
import javafx.scene.layout.Pane;
import javafx.stage.Stage;
//import java.awt.*;

public class LoginController{
    @FXML private TextField userid;
    @FXML private PasswordField userpwd;
    @FXML private Button login;

    private MyApplication myApp;
    private boolean isUser;

    public void setMyApp(MyApplication myApp, boolean isUser)
    {
        this.myApp = myApp;
        this.isUser = isUser;
    }

    @FXML
    public void onClick(ActionEvent e){
        System.out.println(userid.getText());
        System.out.println(userpwd.getText());
    }

    private void userLoginSuccess() {
        try {
            Stage curStage = myApp.curStage;
            curStage.close();

            FXMLLoader loader;
            loader = new FXMLLoader(getClass().getResource("UserRegisterView.fxml"));
            Pane root = loader.load();

            RegisterController registerController = loader.getController();
            registerController.setMyApp(this.myApp);

            Scene scene = new Scene(root);
            curStage.setScene(scene);
            curStage.show();
        }
        catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void docLoginSuccess() {
        try {
            Stage curStage = myApp.curStage;
            curStage.close();

            FXMLLoader loader;
            loader = new FXMLLoader(getClass().getResource("DocView.fxml"));
            Pane root = loader.load();

            RegisterController registerController = loader.getController();
            registerController.setMyApp(this.myApp);

            Scene scene = new Scene(root);
            curStage.setScene(scene);
            curStage.show();
        }
        catch (Exception e){
            e.printStackTrace();
        }
    }

}