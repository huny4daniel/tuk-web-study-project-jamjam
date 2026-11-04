<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,my.util.*,my.dao.*" %>
<%@ include file="/inc/adminCheck.jsp" %>
<%-- 객실 삭제 : 아직 끝나지 않은 예약이 있으면 삭제하지 않는다 --%>
<%
	int roomId = Integer.parseInt(request.getParameter("roomId"));
	String msg;
	Connection conn = ConnectionProvider.getConnection();
	try {
		if (new ReservationDao().countActiveByRoom(conn, roomId) > 0) {
			msg = "투숙 예정인 예약이 남아 있어 삭제할 수 없습니다. 예약을 먼저 처리하세요.";
		} else {
			new RoomDao().deleteById(conn, roomId);
			msg = "삭제되었습니다.";
		}
	} finally {
		JdbcUtil.close(conn);
	}
%>
<script>
	alert("<%= msg %>");
	location.href = "roomList.jsp";
</script>
