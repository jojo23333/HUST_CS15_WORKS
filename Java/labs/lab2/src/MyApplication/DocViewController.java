package MyApplication;

import javafx.beans.value.ObservableValue;
import javafx.collections.FXCollections;
import javafx.fxml.FXML;
import javafx.scene.control.Button;
import javafx.scene.control.TableColumn;
import javafx.scene.control.TableView;
import javafx.stage.Stage;
import javafx.util.Callback;

import java.util.ArrayList;
import java.util.List;

public class DocViewController {
    private MyApplication myApp;
    private String docId;
    @FXML public TableView patientTable, incomeTable;
    @FXML public TableColumn <DocViewRegisterModel,String> patient_regid, patient_name, patient_date, patient_cat;
    @FXML public TableColumn <DocViewIncomeModel, String> income_dep, income_docid, income_docname, income_cat, income_num, income_fee;
    @FXML public Button refresh , exit;

    public void setMyApp(MyApplication myApp, String docid)
    {
        this.myApp = myApp;
        this.docId = docid;
        patient_regid.setCellValueFactory(
                new Callback<TableColumn.CellDataFeatures<DocViewRegisterModel, String>, ObservableValue<String>>() {
                    public ObservableValue<String> call(TableColumn.CellDataFeatures<DocViewRegisterModel, String> p) {
                        // p.getValue() returns the Person instance for a particular TableView row
                        return p.getValue().regid();
                    }
                }
        );
        patient_name.setCellValueFactory(
                new Callback<TableColumn.CellDataFeatures<DocViewRegisterModel, String>, ObservableValue<String>>() {
                    public ObservableValue<String> call(TableColumn.CellDataFeatures<DocViewRegisterModel, String> p) {
                        // p.getValue() returns the Person instance for a particular TableView row
                        return p.getValue().name();
                    }
                }
        );
        patient_date.setCellValueFactory(
                new Callback<TableColumn.CellDataFeatures<DocViewRegisterModel, String>, ObservableValue<String>>() {
                    public ObservableValue<String> call(TableColumn.CellDataFeatures<DocViewRegisterModel, String> p) {
                        // p.getValue() returns the Person instance for a particular TableView row
                        return p.getValue().date();
                    }
                }
        );
        patient_cat.setCellValueFactory(
                new Callback<TableColumn.CellDataFeatures<DocViewRegisterModel, String>, ObservableValue<String>>() {
                    public ObservableValue<String> call(TableColumn.CellDataFeatures<DocViewRegisterModel, String> p) {
                        // p.getValue() returns the Person instance for a particular TableView row
                        return p.getValue().cat();
                    }
                }
        );

        income_dep.setCellValueFactory(
                new Callback<TableColumn.CellDataFeatures<DocViewIncomeModel, String>, ObservableValue<String>>() {
                    public ObservableValue<String> call(TableColumn.CellDataFeatures<DocViewIncomeModel, String> p) {
                        // p.getValue() returns the Person instance for a particular TableView row
                        return p.getValue().dep();
                    }
                }
        );
        income_docid.setCellValueFactory(
                new Callback<TableColumn.CellDataFeatures<DocViewIncomeModel, String>, ObservableValue<String>>() {
                    public ObservableValue<String> call(TableColumn.CellDataFeatures<DocViewIncomeModel, String> p) {
                        // p.getValue() returns the Person instance for a particular TableView row
                        return p.getValue().docid();
                    }
                }
        );
        income_docname.setCellValueFactory(
                new Callback<TableColumn.CellDataFeatures<DocViewIncomeModel, String>, ObservableValue<String>>() {
                    public ObservableValue<String> call(TableColumn.CellDataFeatures<DocViewIncomeModel, String> p) {
                        // p.getValue() returns the Person instance for a particular TableView row
                        return p.getValue().docname();
                    }
                }
        );
        income_cat.setCellValueFactory(
                new Callback<TableColumn.CellDataFeatures<DocViewIncomeModel, String>, ObservableValue<String>>() {
                    public ObservableValue<String> call(TableColumn.CellDataFeatures<DocViewIncomeModel, String> p) {
                        // p.getValue() returns the Person instance for a particular TableView row
                        return p.getValue().cat();
                    }
                }
        );
        income_num.setCellValueFactory(
                new Callback<TableColumn.CellDataFeatures<DocViewIncomeModel, String>, ObservableValue<String>>() {
                    public ObservableValue<String> call(TableColumn.CellDataFeatures<DocViewIncomeModel, String> p) {
                        // p.getValue() returns the Person instance for a particular TableView row
                        return p.getValue().num();
                    }
                }
        );
        income_fee.setCellValueFactory(
                new Callback<TableColumn.CellDataFeatures<DocViewIncomeModel, String>, ObservableValue<String>>() {
                    public ObservableValue<String> call(TableColumn.CellDataFeatures<DocViewIncomeModel, String> p) {
                        // p.getValue() returns the Person instance for a particular TableView row
                        return p.getValue().fee();
                    }
                }
        );
        reset();
    }

    void reset()
    {
        List x = new ArrayList();
        SqlConnector.getPatientList(this.docId,x);
        patientTable.setItems(FXCollections.observableList(x));
        List y = new ArrayList();
        SqlConnector.getDocIncome(y);
        incomeTable.setItems(FXCollections.observableList(y));
    }



    @FXML void onRefresh() {

    }

    @FXML void onExit() {
        Stage curStage = this.myApp.curStage;
        curStage.close();
    }
}


