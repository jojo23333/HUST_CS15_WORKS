package MyApplication;

import javafx.fxml.FXML;

import javafx.fxml.FXMLLoader;
import javafx.scene.Scene;
import javafx.scene.control.Button;
import javafx.scene.layout.Pane;
import javafx.stage.Stage;

public class WelcomeController {
    @FXML private Button user, doc;

    private MyApplication myApp;

    public void setMyApp(MyApplication myApp, boolean isUser)
    {
        this.myApp = myApp;
    }

    public void toLogin(boolean isUser) {
        try {
            Stage curStage = myApp.curStage;
            curStage.close();

            String loginXml = isUser ? "UserLoginView.fxml" : "DocLoginView.fxml";

            FXMLLoader loader;
            loader = new FXMLLoader(getClass().getResource(loginXml));
            Pane root = loader.load();

            LoginController loginController = loader.getController();
            loginController.setMyApp(this.myApp, isUser);

            Scene scene = new Scene(root);
            curStage.setScene(scene);
            curStage.show();
        }
        catch (Exception e) {
            e.printStackTrace();
        }
    }

    @FXML
    void onClickUser()
    {
        this.toLogin(true);
    }

    @FXML
    void onClickDoc()
    {
        this.toLogin(false);
    }
}

