<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,my.util.*,my.dao.*" %>
<%@ include file="/inc/adminCheck.jsp" %>
<%-- 문의 답변 저장 --%>
<%
	request.setCharacterEncoding("utf-8");
	int qnaId = Integer.parseInt(request.getParameter("qnaId"));
	String answer = request.getParameter("answer");

	Connection conn = ConnectionProvider.getConnection();
	try {
		new QnaDao().updateAnswer(conn, qnaId, answer);
	} finally {
		JdbcUtil.close(conn);
	}
%>
<script>
	alert("답변이 저장되었습니다.");
	location.href = "qnaList.jsp";
</script>
