<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oreilly.servlet.*,com.oreilly.servlet.multipart.*" %>
<%@ page import="java.io.*,java.nio.file.Files,java.sql.*,my.util.*,my.dao.*,my.model.*" %>
<%@ include file="/inc/adminCheck.jsp" %>
<%--
	객실 등록 / 수정 처리 (사진 업로드 포함)
	① cos.jar 의 MultipartRequest 로 사진을 받아서 임시 폴더에 잠깐 저장 (수업 movieupload.jsp 와 같은 방식)
	② 그 파일을 byte 배열로 읽어서 DB(room.photo, LONGBLOB)에 저장
	③ 임시 파일은 지운다  → 사진이 DB 에 있으므로 서버를 Clean 해도, 다른 PC 에서도 그대로 보인다
	roomId 가 0 이면 새로 등록(insert), 아니면 수정(update)
--%>
<%
	// 톰캣이 웹 앱마다 만들어 주는 임시 폴더
	File tempDir = (File) application.getAttribute("javax.servlet.context.tempdir");
	MultipartRequest multi = new MultipartRequest(request, tempDir.getAbsolutePath(), 10 * 1024 * 1024, "utf-8",
			new DefaultFileRenamePolicy());

	Room room = new Room();
	room.setRoomId(Integer.parseInt(multi.getParameter("roomId")));
	room.setRoomType(multi.getParameter("roomType"));
	room.setRoomNo(multi.getParameter("roomNo"));
	room.setPrice(Integer.parseInt(multi.getParameter("price")));
	room.setDiscountRate(Integer.parseInt(multi.getParameter("discountRate")));
	room.setCapacity(Integer.parseInt(multi.getParameter("capacity")));
	room.setBedCount(Integer.parseInt(multi.getParameter("bedCount")));
	// 체크박스는 체크하지 않으면 값이 아예 안 넘어온다(null)
	room.setBreakfast(multi.getParameter("breakfast") == null ? 0 : 1);
	room.setPet(multi.getParameter("pet") == null ? 0 : 1);
	room.setAmenities(multi.getParameter("amenities"));
	room.setDescription(multi.getParameter("description"));

	// 사진을 골랐으면 파일 내용을 읽어서 Room 에 담고, 임시 파일은 삭제
	File photoFile = multi.getFile("photo");             // 파일을 안 골랐으면 null
	if (photoFile != null) {
		room.setPhotoData(Files.readAllBytes(photoFile.toPath()));
		room.setPhotoType(multi.getContentType("photo"));  // 예) image/jpeg
		photoFile.delete();
	}

	Connection conn = ConnectionProvider.getConnection();
	try {
		RoomDao dao = new RoomDao();
		if (room.getRoomId() == 0) {
			dao.insert(conn, room);    // 사진이 없으면 photo 는 NULL -> photo.jsp 가 기본 그림을 보여줌
		} else {
			dao.update(conn, room);              // 사진을 뺀 정보 수정
			if (room.getPhotoData() != null) {
				dao.updatePhoto(conn, room);     // 새 사진을 골랐을 때만 사진도 바꿈
			}
		}
	} finally {
		JdbcUtil.close(conn);
	}
%>
<script>
	alert("저장되었습니다.");
	location.href = "roomList.jsp";
</script>
