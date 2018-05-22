package MyApplication;

import javafx.fxml.FXML;
import javafx.scene.control.PasswordField;
import javafx.scene.control.TextField;
import javafx.scene.control.Button;
import javafx.event.ActionEvent;
//import java.awt.*;

public class LoginController{
    @FXML private TextField userid;
    @FXML private PasswordField userpwd;
    @FXML private Button login;

    private MyApplication myApp;

    public void setMyApp(MyApplication myApp)
    {
        this.myApp = myApp;
    }

    @FXML
    public void onClick(ActionEvent e){
        System.out.println(userid.getText());
        System.out.println(userpwd.getText());
    }
}
