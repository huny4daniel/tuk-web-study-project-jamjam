<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,my.util.*,my.dao.*,my.model.*" %>
<%-- 회원가입 처리 (화면 없음 : 처리 후 alert 띄우고 이동) --%>
<% request.setCharacterEncoding("utf-8"); %>
<%-- 폼의 name 과 Member 의 필드 이름이 같으면 setProperty="*" 가 알아서 값을 채워준다 --%>
<jsp:useBean id="member" class="my.model.Member"/>
<jsp:setProperty name="member" property="*"/>
<%
	Connection conn = ConnectionProvider.getConnection();
	try {
		MemberDao dao = new MemberDao();
		if (dao.idCheck(conn, member.getUserId())) {
%>
			<script>
				alert("이미 사용 중인 아이디입니다.");
				history.go(-1);
			</script>
<%
		} else {
			dao.insert(conn, member);
%>
			<script>
				alert("회원가입이 완료되었습니다. 로그인해 주세요.");
				location.href = "loginForm.jsp";
			</script>
<%
		}
	} finally {
		JdbcUtil.close(conn);
	}
%>
