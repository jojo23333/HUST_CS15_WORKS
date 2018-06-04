package MyApplication;

import javafx.beans.property.SimpleStringProperty;

public class DocViewIncomeModel {
    private final SimpleStringProperty income_dep, income_docid, income_docname, income_cat, income_num, income_fee;

    public DocViewIncomeModel(String income_dep,String income_docid,String income_docname,String income_cat,String income_num,String income_fee) {
        this.income_dep = new SimpleStringProperty(income_dep);
        this.income_docid = new SimpleStringProperty(income_docid);
        this.income_docname = new SimpleStringProperty(income_docname);
        this.income_cat = new SimpleStringProperty(income_cat);
        this.income_num = new SimpleStringProperty(income_num);
        this.income_fee = new SimpleStringProperty(income_fee);
    }

    public SimpleStringProperty dep() {
        return this.income_dep;
    }
    public SimpleStringProperty docid() {
        return this.income_docid;
    }
    public SimpleStringProperty docname() {
        return this.income_docname;
    }
    public SimpleStringProperty cat() {
        return this.income_cat;
    }
    public SimpleStringProperty num() {
        return this.income_num;
    }
    public SimpleStringProperty fee() {
        return this.income_fee;
    }

}
