<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,my.util.*,my.dao.*,my.model.*" %>
<%@ include file="/inc/loginCheck.jsp" %>
<%-- 이용자 예약 취소 (마이페이지의 취소 버튼) --%>
<%
	String loginId = (String) session.getAttribute("LOGIN");
	int resId = Integer.parseInt(request.getParameter("resId"));
	String error = null;

	Connection conn = ConnectionProvider.getConnection();
	try {
		ReservationDao dao = new ReservationDao();
		Reservation res = dao.selectById(conn, resId);

		if (res == null || !res.getUserId().equals(loginId)) {
			error = "본인의 예약만 취소할 수 있습니다.";
		} else if (!res.isCancelable()) {
			error = "이미 취소되었거나 체크인 날짜가 지난 예약은 취소할 수 없습니다. 호텔로 문의해 주세요.";
		} else {
			dao.updateStatus(conn, resId, "취소");
			new RoomDao().updateResCount(conn, res.getRoomId(), -1);   // 객실 예약 수 -1
			new MemberCouponDao().restoreByRes(conn, resId);            // 이 예약에 쓴 쿠폰 돌려주기
		}
	} finally {
		JdbcUtil.close(conn);
	}
%>
<script>
	alert("<%= error == null ? "예약이 취소되었습니다." : error %>");
	location.href = "../mypage/myPage.jsp";
</script>
