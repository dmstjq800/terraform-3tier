#!/bin/bash
###################
### 지바 설치 및 설정
yum -y install java-1.8.0-amazon-corretto-devel.x86_64

echo "JAVA_HOME=/usr/lib/jvm/java-1.8.0-amazon-corretto.x86_64/" >> /etc/profile
echo "export JAVA_HOME" >> /etc/profile
echo "PATH=$PATH:$JAVA_HOME/bin" >> /etc/profile
echo "export PATH" >> /etc/profile

#####################
## Tomcat 설치
mkdir /test
cd /test
wget https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.100/bin/apache-tomcat-9.0.100.tar.gz
tar zxvf apache-tomcat-9.0.100.tar.gz
mv apache-tomcat-9.0.100 /usr/local/tomcat9

###################
## Tomcat 설정파일 추가
mkdir /usr/local/tomcat9/webapps/test
rm /usr/local/tomcat9/conf/server.xml
aws s3 cp s3://my-bucket-ces-3tier/was/server.xml /usr/local/tomcat9/conf/server.xml
aws s3 cp s3://my-bucket-ces-3tier/was/mysql-connector-java-8.0.19.jar /usr/local/tomcat9/lib/

################################
## db.jsp 생성
cat << EOF > /usr/local/tomcat9/webapps/test/db.jsp
<%@page import="java.sql.*"%>
 
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Insert title here</title>
</head>
<body>
	<%
		Connection conn = null;
		ResultSet rs = null;
		String url = "jdbc:mysql://${DB_DNS}:3306/web?serverTimezone=UTC";
		String id = "test";
		String pwd = "password";
		try {
			Class.forName("com.mysql.jdbc.Driver");
			conn = DriverManager.getConnection(url, id, pwd);
			Statement stmt = conn.createStatement();
			String sql = "SELECT name FROM people";
			rs = stmt.executeQuery(sql);
			while(rs.next()) {
				out.println(rs.getString("name"));
			}
			conn.close();
		} catch (Exception e) {
			out.println("catch");
			e.printStackTrace();
		}	
	%>
</body>
</html>
EOF
#################
# Tomcat 실행
/usr/local/tomcat9/bin/shutdown.sh
/usr/local/tomcat9/bin/startup.sh