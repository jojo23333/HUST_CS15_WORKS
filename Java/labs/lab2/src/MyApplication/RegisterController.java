package MyApplication;

import javafx.fxml.FXML;
import javafx.scene.control.Button;
import javafx.scene.control.ComboBox;
import javafx.scene.control.Label;
import javafx.scene.control.TextField;
import javafx.scene.input.KeyCode;
import javafx.scene.input.KeyEvent;
import javafx.util.StringConverter;

import java.util.ArrayList;
import java.util.List;

public class RegisterController {
    @FXML private ComboBox officeName, docName, registerClass, registerName;
    @FXML private TextField payment;
    @FXML private Label payDemand, payChange, registerId;
    @FXML private Button submit, clear, quit;

    private MyApplication myApp;
    private String username;
    private loginSqlDataConnector data;

    private String showString(String x[]) {
        String t = new String("");
//        for (String i : x)
//            t = t + " " + i;
        t = x[0] + "(" + x[1] + ")"+ " ID: " + x[2];
        return t;
    }

    public void setMyApp(MyApplication myApp, String username)
    {
        this.myApp = myApp;
        this.data = new loginSqlDataConnector(username);
        this.username = username;
        this.setOfficeNameHandler();
        this.setDocNameHandler();
        this.setRegisterNameHandler();
    }

    @FXML void onOfficeNameClicked(){
        if (officeName.getValue() == null) {
            officeName.getItems().clear();
            for (String x[] : data.officeNameList) {
                officeName.getItems().add(showString(x));
            }
        }
    }
    @FXML void onDocNameClicked(){
        if (docName.getValue() == null) {
            docName.getItems().clear();
            for (String x[] : data.docNameList) {
                docName.getItems().add(showString(x));
            }
        }
    }
    @FXML void onRegisterClassClicked(){
        registerClass.getItems().clear();
        registerClass.getItems().add(new String("普通号"));
        if (this.data.isExpert)
            registerClass.getItems().add(new String("专家号"));
    }
    @FXML void onRegisterNameClicked(){

        if (registerName.getValue() == null) {
            registerName.getItems().clear();
            for (String x[] : data.registerNameList) {
                registerName.getItems().add(showString(x));
            }
        }
    }


    void setOfficeNameHandler() {
        this.officeName.addEventHandler(KeyEvent.KEY_PRESSED, t -> this.officeName.hide());
        this.officeName.addEventHandler(KeyEvent.KEY_RELEASED, t -> {
            String val = officeName.getEditor().getText();
            if (t.getCode() == KeyCode.ESCAPE)
                officeName.hide();
            else
                officeName.show();
            if (!t.getCode().isDigitKey() && !t.getCode().isLetterKey() &&
                    t.getCode() != KeyCode.BACK_SPACE) return;

            officeName.getItems().clear();
            for (String[] x : this.data.officeNameList) {
                if (x[0].startsWith(val) || x[1].toLowerCase().startsWith(val.toLowerCase()))
                    officeName.getItems().add(showString(x));
            }
            // if val is cleared reinsert
            val = officeName.getEditor().getText();
            if (val.equals("")) {
                officeName.getItems().clear();
                for (String x[] : data.officeNameList) {
                    officeName.getItems().add(showString(x));
                }
            }
        });
    }

    @FXML void onOfficeNameSelected(){
        // if it's not a valid option clear the input
        if (!officeName.getItems().contains(officeName.getEditor().getText())) {
            officeName.setValue(null);
            return;
        }
        String choice = officeName.getEditor().getText();
        String id = choice.substring(choice.lastIndexOf(" ")+1);
//        System.out.println("Choice is: " + choice + " Id is: " + id);
        data.officeId = id;
        data.registerNameId = "";
        data.docId = "";
        registerName.setValue(null);
        docName.setValue(null);
        registerClass.setValue(null);
        data.update();
    }

    void setDocNameHandler(){
        this.docName.addEventHandler(KeyEvent.KEY_PRESSED, t -> this.docName.hide());
        this.docName.addEventHandler(KeyEvent.KEY_RELEASED, t -> {
            String val = docName.getEditor().getText();
            if (t.getCode() == KeyCode.ESCAPE)
                docName.hide();
            else
                docName.show();
            if (!t.getCode().isDigitKey() && !t.getCode().isLetterKey() &&
                    t.getCode() != KeyCode.BACK_SPACE) return;

            docName.getItems().clear();
            for (String x[] : this.data.docNameList) {
                if(x[0].startsWith(val) || x[1].toLowerCase().startsWith(val.toLowerCase()))
                    docName.getItems().add(showString(x));
            }
            // if val is cleared reinsert
            val = docName.getEditor().getText();
            if (val.equals("")) {
                docName.getItems().clear();
                for (String x[] : data.docNameList) {
                    docName.getItems().add(showString(x));
                }
            }
        });
    }

    @FXML void onDocNameSelected(){
        if (!docName.getItems().contains(docName.getEditor().getText())) {
            docName.setValue(null);
            return;
        }
        String choice = docName.getEditor().getText();
        String id = choice.substring(choice.lastIndexOf(" ")+1);
        data.docId = id;
        registerClass.setValue(null);
        data.update();
    }

    @FXML void onRegisterClassSelected(){
        if (registerClass.getValue() == null) return;
        System.out.println(registerClass.getValue().toString());
        if (registerClass.getValue().toString().equals("专家号"))
            data.isExpertClass = true;
        else
            data.isExpertClass = false;
        data.registerNameId = "";
        registerName.setValue(null);
        data.update();
    }

    void setRegisterNameHandler(){
        this.registerName.addEventHandler(KeyEvent.KEY_PRESSED, t -> this.registerName.hide());
        this.registerName.addEventHandler(KeyEvent.KEY_RELEASED, t -> {
            String val = registerName.getEditor().getText();
            if (t.getCode() == KeyCode.ESCAPE )
                registerName.hide();
            else
                registerName.show();
            if (!t.getCode().isDigitKey() && !t.getCode().isLetterKey() &&
                    t.getCode() != KeyCode.BACK_SPACE) return;

            registerName.getItems().clear();
            for (String x[] : this.data.registerNameList) {
                if(x[0].startsWith(val) || x[1].toLowerCase().startsWith(val.toLowerCase()))
                    registerName.getItems().add(showString(x));
            }
            // if val is cleared reinsert
            val = registerName.getEditor().getText();
            if (val.equals("")) {
                registerName.getItems().clear();
                for (String x[] : data.registerNameList) {
                    registerName.getItems().add(showString(x));
                }
            }
        });
    }

    @FXML void onRegisterNameSelected(){
        if (!registerName.getItems().contains(registerName.getEditor().getText())) {
            registerName.setValue(null);
            return;
        }
        String choice = registerName.getEditor().getText();
        String id = choice.substring(choice.lastIndexOf(" ")+1);
        data.registerNameId = id;
    }
}

class loginSqlDataConnector{
    private String username;
    public List<String[]> officeNameList, docNameList, registerNameList;
    public boolean isExpert, isExpertClass;
    public String officeId, docId, registerNameId;

    public loginSqlDataConnector(String username) {
        this.username = username;
        officeNameList = new ArrayList<String[]>();
        docNameList = new ArrayList<String[]>();
        registerNameList = new ArrayList<String[]>();
        officeId = "";
        docId = "";
        registerNameId = "";
        update();
    }

    public void update(){
        officeNameList.clear();
        docNameList.clear();
        registerNameList.clear();
        SqlConnector.getOfficeName(officeNameList);
        SqlConnector.getDocName(officeId,docNameList);
        SqlConnector.getRegisterName(officeId,isExpertClass,registerNameList);
        this.isExpert = SqlConnector.isExpert(docId);
    }
}
