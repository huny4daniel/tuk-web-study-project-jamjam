<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,my.util.*,my.dao.*" %>
<%@ include file="/inc/adminCheck.jsp" %>
<%-- 자주 묻는 질문 삭제 처리 (couponDelete.jsp 와 같은 방식) --%>
<%
	Connection conn = ConnectionProvider.getConnection();
	try {
		new FaqDao().deleteById(conn, Integer.parseInt(request.getParameter("faqId")));
	} finally {
		JdbcUtil.close(conn);
	}
	response.sendRedirect("faqList.jsp");
%>
