<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,my.util.*,my.dao.*" %>
<%@ include file="/inc/loginCheck.jsp" %>
<%-- 투숙객 삭제 처리 : 본인이 등록한 투숙객만 지워진다 (GuestDao.delete 의 where 에 userId) --%>
<%
	Connection conn = ConnectionProvider.getConnection();
	try {
		new GuestDao().delete(conn, Integer.parseInt(request.getParameter("guestId")), (String) session.getAttribute("LOGIN"));
	} finally {
		JdbcUtil.close(conn);
	}
	response.sendRedirect("guest.jsp");
%>
