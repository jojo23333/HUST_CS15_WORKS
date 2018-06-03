package MyApplication;

import javafx.beans.property.SimpleStringProperty;

public class DocViewRegisterModel {
    private final SimpleStringProperty patient_regid;
    private final SimpleStringProperty patient_name;
    private final SimpleStringProperty patient_date;
    private final SimpleStringProperty patient_cat;

    public DocViewRegisterModel(String patient_regid, String patient_name, String patient_date, String patient_cat) {
        this.patient_regid = new SimpleStringProperty(patient_regid);
        this.patient_name = new SimpleStringProperty(patient_name);
        this.patient_date = new SimpleStringProperty(patient_date);
        this.patient_cat = new SimpleStringProperty(patient_cat);
    }

    public SimpleStringProperty regid() {
        return patient_regid;
    }

    public SimpleStringProperty name() {
        return patient_name;
    }

    public SimpleStringProperty date() {
        return patient_date;
    }

    public SimpleStringProperty cat() {
        return patient_cat;
    }

}
