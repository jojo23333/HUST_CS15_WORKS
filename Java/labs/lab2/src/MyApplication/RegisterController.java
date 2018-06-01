package MyApplication;

import javafx.beans.value.ChangeListener;
import javafx.beans.value.ObservableValue;
import javafx.fxml.FXML;
import javafx.scene.control.*;
import javafx.scene.input.KeyCode;
import javafx.scene.input.KeyEvent;
import javafx.stage.Stage;
import javafx.util.StringConverter;

import java.util.ArrayList;
import java.util.List;

public class RegisterController {
    @FXML private ComboBox officeName, docName, registerClass, registerName;
    @FXML private TextField payment;
    @FXML private Label payDemand, payChange, registerId;
    @FXML private Button submit, clear, quit;

    private MyApplication myApp;
    private String pid;
    private loginSqlDataConnector data;

    private String showString(String x[]) {
        String t = new String("");
//        for (String i : x)
//            t = t + " " + i;
        t = x[0] + "(" + x[1] + ")"+ " ID: " + x[2];
        return t;
    }

    public void setMyApp(MyApplication myApp, String pid)
    {
        this.myApp = myApp;
        this.data = new loginSqlDataConnector(pid);
        this.pid = pid;
        this.setOfficeNameHandler();
        this.setDocNameHandler();
        this.setRegisterNameHandler();
        payment.textProperty().addListener(new ChangeListener<String>() {
            @Override
            public void changed(ObservableValue<? extends String> observable, String oldValue,
                                String newValue) {
                if (!newValue.matches("\\d*")) {
                    payment.setText(newValue.replaceAll("[^\\d]", ""));
                }
            }
        });
//        this.registerClass.setValue("普通号");
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
        payDemand.setText(String.valueOf(data.getfee()) + " ￥ / 余额： " + data.balance + " ￥");
        if (data.fee <= data.balance) {
            payment.setDisable(true);
        }
        else {
            payment.setDisable(false);
        }
    }

    @FXML void onPaymentEntered() {
        System.out.println("payment: " + payment.getText());
        if (!payment.getText().equals("")) {
            data.payment = Integer.parseInt(payment.getText());
            if (data.balance + data.payment >= data.fee)
                payChange.setText(String.valueOf(data.balance - data.fee >= 0 ?
                        0 : data.balance + data.payment - data.fee) + " ￥ ");
            else
                payChange.setText("金额不足");
        }
    }

    @FXML void onClear() {
        officeName.setValue(null);
        docName.setValue(null);
        registerClass.setValue(null);
        registerName.setValue(null);
        payment.setText("");
        payDemand.setText("");
        payChange.setText("");
        data.officeId = data.docId = data.registerNameId = "";
        data.payment = 0; data.fee = 0;
    }

    @FXML void onQuit() {
        Stage curStage = this.myApp.curStage;
        curStage.close();
    }

    @FXML void onRegister() {
        onPaymentEntered();
        String title = null,context = null,id = null;
        title = "有未选择字段";
        if (data.officeId.equals("")) context = "请选择科室";
        else if (data.docId.equals("")) context = "请选择医生";
        else if (data.registerNameId.equals("")) context = "请选择号种";
        else if (data.balance+data.payment < data.fee) context = "金额不足";
        else {
            String[] msg = new String[2];
            if (data.register(msg)) {
                id = msg[1];
                title = "挂号成功";
                registerId.setText(id);
                submit.setDisable(true);
                clear.setDisable(true);
            }
            else{
                title = "挂号失败";
            }
            context = msg[0];
        }
        Alert alert = new Alert(Alert.AlertType.INFORMATION);
        alert.setTitle("");
        alert.setHeaderText(title);
        alert.setContentText(context);

        alert.showAndWait();

    }
}

class loginSqlDataConnector{
    private String pid;
    public List<String[]> officeNameList, docNameList, registerNameList;
    public boolean isExpert, isExpertClass;
    public String officeId, docId, registerNameId;
    public int payment ,fee, balance;

    public loginSqlDataConnector(String pid) {
        this.pid = pid;
        officeNameList = new ArrayList<String[]>();
        docNameList = new ArrayList<String[]>();
        registerNameList = new ArrayList<String[]>();
        officeId = "";
        docId = "";
        registerNameId = "";
        this.balance = SqlConnector.getUserBalance(pid);
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

    public int getfee(){
        for (String[] x : registerNameList) {
            if (x[2].equals(registerNameId)) {
                this.fee = Integer.parseInt(x[3]);
                break;
            }
        }
        return this.fee;
    }

    public boolean register(String[] args) {

        int uplimit = SqlConnector.getRegUplimit(registerNameId);
        int curAmount = SqlConnector.getRegCurAmount(registerNameId);
        if (curAmount >= uplimit) {
            args[0] = "已达到该号种单日申请上限";
        } else {
            args[1] = SqlConnector.register(pid,docId,registerNameId,curAmount,fee);
            if (args[1] != null) {
                args[0] = "挂号成功！您的挂号号码为：" + args[1];
//                System.out.println(msg);
                SqlConnector.updateUserBanlance(this.pid, Math.max(this.balance-this.fee, 0));
                return true;
            }
        }
        return false;
    }
}
