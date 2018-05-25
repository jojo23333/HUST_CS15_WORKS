package MyApplication;

import javafx.collections.FXCollections;
import javafx.collections.ObservableList;
import javafx.fxml.FXML;
import javafx.scene.control.Button;
import javafx.scene.control.ComboBox;
import javafx.scene.control.Label;
import javafx.scene.control.TextField;

public class RegisterController {
    @FXML private ComboBox officeName, docName, registerClass, registerName;
    @FXML private TextField payment;
    @FXML private Label payDemand, payChange, registerId;
    @FXML private Button submit, clear, quit;

    private MyApplication myApp;

    public void setMyApp(MyApplication myApp)
    {
        this.myApp = myApp;
        ObservableList<String> options =
                FXCollections.observableArrayList(
                        "Option 1",
                        "Option 2",
                        "Option 3"
                );
        officeName.getItems().setAll(options);
        docName.getItems().setAll(options);
        registerClass.getItems().setAll(options);
        registerName.getItems().setAll(options);
    }

    @FXML
    void onOfficeNameChanged() {

    }

    @FXML
    void onDocNameChanged(){

    }

    @FXML
    void onRegisterClassChanged(){

    }

    @FXML
    void onRegisterNameChanged(){

    }
}
