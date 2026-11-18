<%@ page language="java" pageEncoding="UTF-8" trimDirectiveWhitespaces="true"%>
<%@ page import="java.io.File,java.sql.*,my.util.*,my.dao.*,my.model.*" %>
<%--
	객실 사진을 "이미지 그 자체"로 보내주는 페이지
	사용법 : <img src="/hotel/room/photo.jsp?roomId=3">
	브라우저는 이 주소를 그냥 이미지 파일처럼 받아서 보여준다.

	사진을 고르는 순서
	  ① 관리자가 올린 사진이 DB(room.photo)에 있으면 그 사진
	  ② 없으면 객실 유형·전망에 맞는 기본 그림 (images/rooms/유형-전망.png, Room.getTypeImage / getViewImage)
	     그 전망 그림이 없으면 같은 유형의 다른 전망 그림 (예 : 오션뷰 그림만 있는 유형)
	  ③ 그것도 없으면 (목록에 없는 새 객실 유형) images/noimage.svg
--%>
<%
	int roomId = Integer.parseInt(request.getParameter("roomId"));

	Connection conn = ConnectionProvider.getConnection();
	Room photo = null;   // ① DB 에 저장된 사진
	Room room = null;    // ② 기본 그림을 고를 때 쓸 객실 정보 (유형, 전망)
	try {
		RoomDao dao = new RoomDao();
		photo = dao.selectPhoto(conn, roomId);
		if (photo == null) {
			room = dao.selectById(conn, roomId);
		}
	} finally {
		JdbcUtil.close(conn);
	}

	if (photo == null) {
		String image = "/images/noimage.svg";   // ③ 마지막 기본값
		if (room != null && room.getTypeImage() != null) {
			// 먼저 그 객실 전망의 그림, 없으면 오션 -> 시티 -> 파크 순서로 같은 유형 그림을 찾는다
			String[] views = { room.getViewImage(), "ocean", "city", "park" };
			for (int i = 0; i < views.length; i++) {
				String path = "/images/rooms/" + room.getTypeImage() + "-" + views[i] + ".png";
				// getRealPath : 웹 경로(/images/...)를 서버 컴퓨터의 실제 파일 경로로 바꿔 준다
				if (new File(application.getRealPath(path)).exists()) {
					image = path;
					break;
				}
			}
		}
		// 이미지 파일 주소로 다시 요청하게 보냄 -> 브라우저가 그 그림을 받아서 보여준다
		response.sendRedirect(request.getContextPath() + image);
		return;
	}

	// 글자(HTML)가 아니라 이미지를 보낼 것이므로 out 대신 바이트 출력 통로(OutputStream)를 쓴다
	out.clear();
	out = pageContext.pushBody();
	response.setContentType(photo.getPhotoType());   // 예) image/jpeg
	response.setHeader("Cache-Control", "no-cache"); // 사진을 바꾸면 바로 새 사진이 보이도록
	response.getOutputStream().write(photo.getPhotoData());
%>
