<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,java.util.*,my.util.*,my.dao.*,my.model.*" %>
<%@ include file="/inc/loginCheck.jsp" %>
<%-- 결제수단 삭제 처리 : 본인 카드만 지워진다. 기본 카드를 지우면 남은 카드 중 먼저 등록한 것이 기본이 된다 --%>
<%
	String loginId = (String) session.getAttribute("LOGIN");
	Connection conn = ConnectionProvider.getConnection();
	try {
		PayCardDao dao = new PayCardDao();
		dao.delete(conn, Integer.parseInt(request.getParameter("cardId")), loginId);
		List<PayCard> cardList = dao.selectByUser(conn, loginId);
		if (cardList.size() > 0 && !cardList.get(0).isDefaultCard()) {
			dao.updateDefault(conn, cardList.get(0).getCardId(), loginId);
		}
	} finally {
		JdbcUtil.close(conn);
	}
	response.sendRedirect("card.jsp");
%>
