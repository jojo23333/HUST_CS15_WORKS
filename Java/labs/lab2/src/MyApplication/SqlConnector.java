package MyApplication;

import java.sql.*;
import java.util.List;

public class SqlConnector {
    static private Connection connection;
    static private String sql, id, name, bref;
    static private Statement stmt;
    static private ResultSet res;


    public SqlConnector(String nurl, String nUserName, String nPassword){
        String url = "jdbc:mysql://localhost:3306/javalab?characterEncoding=utf8&useSSL=false&serverTimezone=UTC";
        String username = "root";
        String password = "li83916386";
        
        url = nurl.equals("")? url : nurl;
        username = nUserName.equals("")? username : nUserName;
        password = nPassword.equals("")? password : nPassword;
        

        System.out.println("Connecting database...");
        try {
            this.connection = DriverManager.getConnection(url, username, password);
            System.out.println("Database connected!");
            sql =   "create view income_view as select doctor.docid,register_category.speciallist, count(*) as num, sum(register.reg_fee) as fee " +
                    "from register join register_category on register_category.catid = register.catid right join doctor on register.docid = doctor.docid " +
                    "group by doctor.docid, speciallist;";
            stmt = connection.createStatement();
            stmt.execute(sql);
            System.out.println("Income view created!");
            stmt.close();
        }
        catch (SQLSyntaxErrorException e){
            System.out.println("Income view exist!");
        }
        catch(SQLException e)
        {
            throw new IllegalStateException("Cannot connect the database!", e);
        }
    }

    public SqlConnector(String nurl, String nUserName, String nPassword){
	    String url = "jdbc:mysql://localhost:3306/javalab?characterEncoding=utf8&useSSL=false&serverTimezone=UTC";
	    String username = "root";
	    String password = "li83916386";
	    
	    url = nurl.equals("")? url : nurl;
	    username = nUserName.equals("")? username : nUserName;
	    password = nPassword.equals("")? password : nPassword;
	    
	
	    System.out.println("Connecting database...");
	    try {
	        this.connection = DriverManager.getConnection(url, username, password);
	        System.out.println("Database connected!");
	        sql =   "create view income_view as select doctor.docid,register_category.speciallist, count(*) as num, sum(register.reg_fee) as fee " +
	                "from register join register_category on register_category.catid = register.catid right join doctor on register.docid = doctor.docid " +
	                "group by doctor.docid, speciallist;";
	        stmt = connection.createStatement();
	        stmt.execute(sql);
	        System.out.println("Income view created!");
	        stmt.close();
	    }
	    catch (SQLSyntaxErrorException e){
	        System.out.println("Income view exist!");
	    }
	    catch(SQLException e)
	    {
	        throw new IllegalStateException("Cannot connect the database!", e);
	    }
	}

	static public void getOfficeName(List<String[]> ans) {
        try {
            stmt = connection.createStatement();
            sql = new String("SELECT * FROM department;");
//                    new String("select department.* from department join doctor on department.depid = doctor.depid where doctor.id=\""+docId+"\";");
            res = stmt.executeQuery(sql);
            while (res.next()) {
                id = res.getString("depid");
                name = res.getString("name");
                bref = res.getString("py");
                ans.add(new String[]{name,bref,id});
            }
            stmt.close();
        } catch(SQLException se){
            // 处理 JDBC 错误
            se.printStackTrace();
        }
    }

    static public void getDocName(String officeId, List<String[]> ans) {
        try {
            stmt = connection.createStatement();
            sql = officeId.equals("") ? new String("SELECT * FROM doctor;") :
                    new String("select * from doctor where depid = \""+ officeId +"\";");
            res = stmt.executeQuery(sql);
            while (res.next()) {
                id = res.getString("docid");
                name = res.getString("name");
                bref = res.getString("py");
                ans.add(new String[]{name,bref,id});
            }
            stmt.close();
        } catch(SQLException se){
            // 处理 JDBC 错误
            se.printStackTrace();
        }
    }

    static public boolean isExpert(String docid){
        try {
            stmt = connection.createStatement();
            sql = "select speciallist from doctor where docid = \"" + docid + "\";";
            res = stmt.executeQuery(sql);
            if (!res.next()) {
                stmt.close();
                return true;
            }
            else {
                boolean expert =  res.getBoolean("speciallist");
                stmt.close();
                return expert;
            }
        } catch(SQLException se){
            // 处理 JDBC 错误
            se.printStackTrace();
        }
        return true;
    }

    static public void getRegisterName(String depid, boolean isExpertClass, List<String[]> ans) {
        int fee;
        try {
            stmt = connection.createStatement();
            sql = depid.equals("")? "select * from register_category":
                    isExpertClass ? "select * from register_category where speciallist = true and depid = \""+ depid + "\";":
            "select * from register_category where depid = \""+ depid + "\";";
            res = stmt.executeQuery(sql);
            while (res.next()) {
                id = res.getString("catid");
                name = res.getString("name");
                bref = res.getString("py");
                fee = res.getInt("reg_fee");
                ans.add(new String[]{name,bref,id,String.valueOf(fee)});
            }
            stmt.close();
        } catch(SQLException se){
            // 处理 JDBC 错误
            se.printStackTrace();
        }
    }

    static public int getUserBalance(String pid){
        int balance = 0;
        try {
            stmt = connection.createStatement();
            sql = "select * from patient where pid= \"" + pid + "\";";
            res = stmt.executeQuery(sql);
            if (!res.next())
                balance = 0;
            else
                balance = res.getInt("balance");
            stmt.close();
        } catch(SQLException se){
            // 处理 JDBC 错误
            se.printStackTrace();
        }
        return balance;
    }

    static public String getUserPassword(String pid){
        String pwd = "";
        try {
            stmt = connection.createStatement();
            sql = "select * from patient where pid = \"" + pid + "\";";
            res = stmt.executeQuery(sql);
            if (!res.next())
                pwd = "";
            else
                pwd = res.getString("password");
            stmt.close();
        } catch(SQLException se){
            // 处理 JDBC 错误
            se.printStackTrace();
        }
        return pwd;
    }

    static public String getDocPassword(String docid){
        String pwd = "";
        try {
            stmt = connection.createStatement();
            sql = "select * from doctor where docid = \"" + docid + "\";";
            res = stmt.executeQuery(sql);
            if (!res.next())
                pwd = "";
            else
                pwd = res.getString("password");
            stmt.close();
        } catch(SQLException se){
            // 处理 JDBC 错误
            se.printStackTrace();
        }
        return pwd;
    }

    static public int getRegUplimit(String catid) {
        int upLimit;
        try {
            stmt = connection.createStatement();

            sql = "select max_reg_number from register_category where catid = \"" + catid + "\";";
            res = stmt.executeQuery(sql);
            if (!res.next()) return -1;
            else upLimit = res.getInt(1);
            stmt.close();
            return upLimit;
        } catch(SQLException se){
            // 处理 JDBC 错误
            se.printStackTrace();
        }
        return -1;
    }

    static public int getRegCurAmount(String catid){
        int curAmount;
        try {
            stmt = connection.createStatement();

            sql = "select count(*) from register where to_days(reg_datetime) = to_days(now()) and unreg = false and catid = \""
                        + catid + "\";";
            res = stmt.executeQuery(sql);
            res.next();
            curAmount = res.getInt(1);
            stmt.close();
            return curAmount;
        } catch(SQLException se){
            // 处理 JDBC 错误
            se.printStackTrace();
        }
        return -1;
    }

    static public String register(String pid, String docid, String catid, int curRegAmount, int reg_fee) {
        int nxtId;
        String reg_id;
        try {
            stmt = connection.createStatement();

            sql = "select max(reg_id) from register;";
            res = stmt.executeQuery(sql);
            res.next();
            if ( res.getString(1) == null)
                nxtId = 1;
            else
                nxtId = Integer.parseInt(res.getString(1)) + 1;

            reg_id = String.format("%06d", nxtId);
            sql = "insert into register values(\"" + reg_id + "\",\"" + catid + "\",\"" + docid + "\",\"" + pid + "\","
                    + String.valueOf(curRegAmount) + ",FALSE," +  String.valueOf(reg_fee) + ", NOW());";
            System.out.println(sql);
            stmt.execute(sql);
            stmt.close();
            return reg_id;
        } catch(SQLException se){
            // 处理 JDBC 错误
            se.printStackTrace();
        }
        return null;
    }

    static public void updateUserBanlance(String pid,int balance) {
        try {
            stmt = connection.createStatement();
            sql = "update patient set balance = " + balance + " where pid = \"" + pid + "\";";
            System.out.println(sql);
            stmt.execute(sql);
            stmt.close();
        } catch(SQLException se){
            // 处理 JDBC 错误
            se.printStackTrace();
        }
    }

    static public void getDocIncome(List ans) {
        try {
            stmt = connection.createStatement();
            sql =  "select income_view.*, doctor.name as docname ,department.name as depname " +
                    "from doctor join department on doctor.depid = department.depid join income_view on income_view.docid = doctor.docid";
            res = stmt.executeQuery(sql);
            String offName, docId, docName, isSpecial, num, income;
            while (res.next()) {
                offName = res.getString("depname");
                docId = res.getString("docid");
                docName = res.getString("docname");
                isSpecial = res.getBoolean("speciallist") ? "专家号" : "普通号";
                num = String.valueOf(res.getInt("num"));
                income = String.valueOf(res.getInt("fee"));
                if (income.equals("0")) {
                	num = "0";
                	isSpecial = " ";
                }
                ans.add(new DocViewIncomeModel(offName, docId, docName, isSpecial, num, income));
            }
            stmt.close();
        } catch(SQLException se){
            // 处理 JDBC 错误
            se.printStackTrace();
        }
    }

    static public void getPatientList(String docid, List ans){
        try {
            stmt = connection.createStatement();
            sql =  "select register.reg_id, patient.name, register.reg_datetime, register_category.speciallist  " +
                    "from register join patient on register.pid = patient.pid join register_category on register.catid = register_category.catid" +
                    " where register.docid = \"" + docid + "\";";
            res = stmt.executeQuery(sql);
            String regid, patientname, regdate, isSpecial;
            while (res.next()) {
                regid = res.getString("reg_id");
                patientname = res.getString("name");
                regdate = res.getString("reg_datetime");
                isSpecial = res.getBoolean("speciallist") ? "专家号" : "普通号";
                ans.add(new DocViewRegisterModel(regid, patientname, regdate, isSpecial));
            }
            stmt.close();
        } catch(SQLException se){
            // 处理 JDBC 错误
            se.printStackTrace();
        }
    }
    
    static public void deleteView() {
    	try {
	        String sql = "drop view income_view;";
	        stmt = connection.createStatement();
	        stmt.execute(sql);
	        System.out.println("Delete View!");
	        stmt.close();
    	}
    	catch(SQLException se){
            // 处理 JDBC 错误
            se.printStackTrace();
        }
    }

//    @Override
//    protected void finalize() throws Throwable {
//        super.finalize();
//    }
}
