<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,my.util.*,my.dao.*,my.model.*" %>
<%-- 로그인 처리 --%>
<%
	request.setCharacterEncoding("utf-8");
	String userId = request.getParameter("userId");
	String password = request.getParameter("password");

	Connection conn = ConnectionProvider.getConnection();
	Member member = null;
	try {
		MemberDao dao = new MemberDao();
		member = dao.login(conn, userId, password);
	} finally {
		JdbcUtil.close(conn);
	}

	if (member != null) {
		// 로그인 성공 : 세션에 아이디와 이름을 저장 (다른 페이지에서 꺼내 씀)
		session.setAttribute("LOGIN", member.getUserId());
		session.setAttribute("NAME", member.getName());

		// 관리자는 관리자 화면으로, 이용자는 메인 화면으로
		if (member.getUserId().equals("admin")) {
			response.sendRedirect("../admin/index.jsp");
		} else {
			response.sendRedirect("../index.jsp");
		}
		return;
	}
%>
<script>
	alert("아이디 또는 비밀번호가 틀렸습니다.");
	history.go(-1);
</script>
