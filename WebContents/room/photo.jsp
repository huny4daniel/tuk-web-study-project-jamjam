<%@ page language="java" pageEncoding="UTF-8" trimDirectiveWhitespaces="true"%>
<%@ page import="java.sql.*,my.util.*,my.dao.*,my.model.*" %>
<%--
	DB 에 저장된 객실 사진을 꺼내서 "이미지 그 자체"로 보내주는 페이지
	사용법 : <img src="/hotel/room/photo.jsp?roomId=3">
	브라우저는 이 주소를 그냥 이미지 파일처럼 받아서 보여준다.
--%>
<%
	int roomId = Integer.parseInt(request.getParameter("roomId"));

	Connection conn = ConnectionProvider.getConnection();
	Room room = null;
	try {
		room = new RoomDao().selectPhoto(conn, roomId);
	} finally {
		JdbcUtil.close(conn);
	}

	if (room == null) {
		// 사진이 없는 객실이면 기본 그림으로
		response.sendRedirect(request.getContextPath() + "/images/noimage.svg");
		return;
	}

	// 글자(HTML)가 아니라 이미지를 보낼 것이므로 out 대신 바이트 출력 통로(OutputStream)를 쓴다
	out.clear();
	out = pageContext.pushBody();
	response.setContentType(room.getPhotoType());   // 예) image/jpeg
	response.setHeader("Cache-Control", "no-cache"); // 사진을 바꾸면 바로 새 사진이 보이도록
	response.getOutputStream().write(room.getPhotoData());
%>
