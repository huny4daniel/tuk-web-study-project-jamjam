<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,my.util.*,my.dao.*" %>
<%@ include file="/inc/adminCheck.jsp" %>
<%
	Connection conn = ConnectionProvider.getConnection();
	try {
		new CouponDao().deleteByCode(conn, request.getParameter("couponCode"));
	} finally {
		JdbcUtil.close(conn);
	}
	response.sendRedirect("couponList.jsp");
%>
