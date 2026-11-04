<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,my.util.*,my.dao.*" %>
<%-- 아이디 중복확인 팝업 창 (joinForm.jsp 에서 window.open 으로 열림) --%>
<%
	request.setCharacterEncoding("utf-8");
	String userId = request.getParameter("userId");
	boolean exist = false;

	Connection conn = ConnectionProvider.getConnection();
	try {
		MemberDao dao = new MemberDao();
		exist = dao.idCheck(conn, userId);
	} finally {
		JdbcUtil.close(conn);
	}
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>아이디 중복확인</title>
<link href="../css/style.css" rel="stylesheet" type="text/css">
</head>
<body style="padding:25px; text-align:center;">
	<% if (exist) { %>
		<p><b><%= userId %></b> 은(는) 이미 사용 중인 아이디입니다.</p>
		<form action="joinIdCheck.jsp" method="get">
			<input type="text" name="userId">
			<input type="submit" class="btn" value="다시 확인">
		</form>
	<% } else { %>
		<p><b><%= userId %></b> 은(는) 사용할 수 있는 아이디입니다.</p>
		<input type="button" class="btn btn-gold" value="이 아이디 사용하기" onclick="useId()">
	<% } %>
	<script>
		// 부모 창(opener)의 아이디 칸에 값을 넣고 팝업 닫기
		function useId() {
			opener.document.fr.userId.value = "<%= userId %>";
			window.close();
		}
	</script>
</body>
</html>
