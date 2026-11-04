<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,my.util.*,my.dao.*,my.model.*" %>
<%@ include file="/inc/loginCheck.jsp" %>
<%-- 문의 등록 처리 --%>
<% request.setCharacterEncoding("utf-8"); %>
<jsp:useBean id="qna" class="my.model.Qna"/>
<jsp:setProperty name="qna" property="*"/>
<%
	qna.setUserId((String) session.getAttribute("LOGIN"));
	Connection conn = ConnectionProvider.getConnection();
	try {
		new QnaDao().insert(conn, qna);
	} finally {
		JdbcUtil.close(conn);
	}
%>
<script>
	alert("문의가 등록되었습니다. 답변은 이 화면에서 확인할 수 있습니다.");
	location.href = "qna.jsp";
</script>
