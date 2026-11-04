<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,my.util.*,my.dao.*,my.model.*" %>
<%@ include file="/inc/adminCheck.jsp" %>
<%
	Connection conn = ConnectionProvider.getConnection();
	try {
		ReviewDao dao = new ReviewDao();
		Review review = dao.selectById(conn, Integer.parseInt(request.getParameter("reviewId")));
		if (review != null) {
			dao.deleteById(conn, review.getReviewId());
			new RoomDao().removeRating(conn, review.getRoomId(), review.getRating());   // 객실 평점에서 빼기
		}
	} finally {
		JdbcUtil.close(conn);
	}
	response.sendRedirect("reviewList.jsp");
%>
