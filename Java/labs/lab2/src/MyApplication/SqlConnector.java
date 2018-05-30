package MyApplication;

import java.sql.*;
import java.util.List;

public class SqlConnector {
    static private Connection connection;


    public SqlConnector(){
        String url = "jdbc:mysql://localhost:3306/javalab";
        String username = "java";
        String password = "password";

        System.out.println("Connecting database...");
        try {
            this.connection = DriverManager.getConnection(url, username, password);
            System.out.println("Database connected!");
        } catch(SQLException e)
        {
            throw new IllegalStateException("Cannot connect the database!", e);
        }
    }

    static public void getOfficeName(List<String[]> ans) {
        String sql, id, name, bref;
        Statement stmt;
        ResultSet res;
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
        } catch(Exception e) {
            // 处理 Class.forName 错误
            e.printStackTrace();
        }
    }

    static public void getDocName(String officeId, List<String[]> ans) {
        String sql, id, name, bref;
        Statement stmt;
        ResultSet res;
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
        } catch(Exception e) {
            // 处理 Class.forName 错误
            e.printStackTrace();
        }
    }

    static public boolean isExpert(String docid){
        String sql, id, name, bref;
        Statement stmt;
        ResultSet res;
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
        } catch(Exception e) {
            // 处理 Class.forName 错误
            e.printStackTrace();
        }
        return true;
    }

    static public void getRegisterName(String depid, boolean isExpertClass, List<String[]> ans) {
        String sql, id, name, bref;
        Statement stmt;
        ResultSet res;
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
                ans.add(new String[]{name,bref,id});
            }
            stmt.close();
        } catch(SQLException se){
            // 处理 JDBC 错误
            se.printStackTrace();
        } catch(Exception e) {
            // 处理 Class.forName 错误
            e.printStackTrace();
        }
    }
}
