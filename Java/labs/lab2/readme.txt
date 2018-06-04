若需要编译运行，使用eclipse打开工程，在工程目录下修改或添加config.txt以配置本地服务器信息，
config.txt中三行分别为连接数据库的url,所用的用户名和所用的密码。
注意行末行首不要有空格，
使用时修改:3306/后的javalab为测试用的数据库名，修改第二行第三行分别为数据库用户名和其对应密码。
实例的config.txt内容如下：
jdbc:mysql://localhost:3306/javalab?characterEncoding=utf8&useSSL=false&serverTimezone=UTC
java
password
