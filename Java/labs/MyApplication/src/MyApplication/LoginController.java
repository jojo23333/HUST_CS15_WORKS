package MyApplication;

import javafx.fxml.FXML;
import javafx.fxml.FXMLLoader;
import javafx.scene.Scene;
import javafx.scene.control.Alert;
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
    public void onClick(ActionEvent e) {
        System.out.println(userid.getText());
        System.out.println(userpwd.getText());
        String uid = userid.getText();
        String pwd = userpwd.getText();
        if (uid.equals("") || pwd.equals("")) {
            Alert alert = new Alert(Alert.AlertType.INFORMATION);
            alert.setTitle("Information Dialog");
            alert.setHeaderText("字段不合法！");
            alert.setContentText("用户名或者密码不能为空！");
            alert.showAndWait();
        }
        else if (isUser && pwd.equals(SqlConnector.getUserPassword(uid))) {
            userLoginSuccess(uid);
        } else if (!isUser && pwd.equals(SqlConnector.getDocPassword(uid))){
            docLoginSuccess(userid.getText());
        } else {
            Alert alert = new Alert(Alert.AlertType.INFORMATION);
            alert.setTitle("Information Dialog");
            alert.setHeaderText("登录失败！");
            alert.setContentText("用户名不存在或密码不正确");
            alert.showAndWait();
        }
    }

    private void userLoginSuccess(String pid) {
        try {
            Stage curStage = myApp.curStage;
            curStage.close();

            FXMLLoader loader;
            loader = new FXMLLoader(getClass().getResource("UserRegisterView.fxml"));
            Pane root = loader.load();

            RegisterController registerController = loader.getController();
            registerController.setMyApp(this.myApp,pid);

            Scene scene = new Scene(root);
            curStage.setScene(scene);
            curStage.show();
        }
        catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void docLoginSuccess(String pid) {
        try {
            Stage curStage = myApp.curStage;
            curStage.close();

            FXMLLoader loader;
            loader = new FXMLLoader(getClass().getResource("DocView.fxml"));
            Pane root = loader.load();

            DocViewController docViewController = loader.getController();
            docViewController.setMyApp(this.myApp,pid);

            Scene scene = new Scene(root);
            curStage.setScene(scene);
            curStage.show();
        }
        catch (Exception e){
            e.printStackTrace();
        }
    }

}
