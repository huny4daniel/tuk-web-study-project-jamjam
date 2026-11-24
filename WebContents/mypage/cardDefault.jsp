<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,my.util.*,my.dao.*" %>
<%@ include file="/inc/loginCheck.jsp" %>
<%-- 기본 카드 지정 처리 : 본인 카드일 때만 바뀐다 --%>
<%
	String loginId = (String) session.getAttribute("LOGIN");
	int cardId = Integer.parseInt(request.getParameter("cardId"));
	Connection conn = ConnectionProvider.getConnection();
	try {
		PayCardDao dao = new PayCardDao();
		if (dao.selectMine(conn, cardId, loginId) != null) {
			dao.updateDefault(conn, cardId, loginId);
		}
	} finally {
		JdbcUtil.close(conn);
	}
	response.sendRedirect("card.jsp");
%>
