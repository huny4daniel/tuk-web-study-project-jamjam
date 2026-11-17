<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,my.util.*,my.dao.*,my.model.*" %>
<%@ include file="/inc/adminCheck.jsp" %>
<%-- 관리자 예약 취소 처리 (관리자는 체크인 이후라도 취소할 수 있음) --%>
<%
	int resId = Integer.parseInt(request.getParameter("resId"));
	Connection conn = ConnectionProvider.getConnection();
	try {
		ReservationDao dao = new ReservationDao();
		Reservation res = dao.selectById(conn, resId);
		if (res != null && res.getStatus().equals("예약완료")) {
			dao.updateStatus(conn, resId, "취소");
			new RoomDao().updateResCount(conn, res.getRoomId(), -1);   // 객실 예약 수 -1
			new MemberCouponDao().restoreByRes(conn, resId);            // 이 예약에 쓴 쿠폰 돌려주기
		}
	} finally {
		JdbcUtil.close(conn);
	}
%>
<script>
	alert("<%= resId %>번 예약이 취소 처리되었습니다.");
	location.href = "reservationList.jsp";
</script>
