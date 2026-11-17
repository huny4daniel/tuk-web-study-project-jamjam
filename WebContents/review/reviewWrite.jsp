<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,my.util.*,my.dao.*,my.model.*" %>
<%@ include file="/inc/loginCheck.jsp" %>
<%--
	리뷰 등록 처리
	★ "숙박을 마친 사용자만" 쓸 수 있도록 서버에서 다시 한 번 검사한다.
	   (화면에서 버튼을 숨겨도 주소를 직접 입력하면 들어올 수 있기 때문)
--%>
<%
	request.setCharacterEncoding("utf-8");
	String loginId = (String) session.getAttribute("LOGIN");
	int resId = Integer.parseInt(request.getParameter("resId"));
	int rating = Integer.parseInt(request.getParameter("rating"));
	String content = request.getParameter("content");
	String error = null;

	Connection conn = ConnectionProvider.getConnection();
	try {
		ReservationDao resDao = new ReservationDao();
		Reservation res = resDao.selectById(conn, resId);

		if (res == null || !res.getUserId().equals(loginId)) {
			error = "본인의 예약에만 리뷰를 쓸 수 있습니다.";
		} else if (res.isReviewed()) {
			error = "이미 리뷰를 작성한 예약입니다.";
		} else if (!res.isReviewable()) {
			error = "숙박을 마친 예약에만 리뷰를 쓸 수 있습니다.";
		} else if (rating < 1 || rating > 5) {
			error = "평점은 1 ~ 5점입니다.";
		} else {
			Review review = new Review();
			review.setResId(resId);
			review.setUserId(loginId);
			review.setRoomId(res.getRoomId());
			review.setRoomType(res.getRoomType());
			review.setRating(rating);
			review.setContent(content);
			new ReviewDao().insert(conn, review);                    // ① 리뷰 저장
			resDao.updateReviewed(conn, resId);                      // ② 이 예약은 리뷰 작성 완료로 표시
			new RoomDao().addRating(conn, res.getRoomId(), rating);  // ③ 객실 평균 평점, 리뷰 수 갱신
		}
	} finally {
		JdbcUtil.close(conn);
	}
%>
<script>
	alert("<%= error == null ? "리뷰가 등록되었습니다. 감사합니다." : error %>");
	location.href = "../mypage/myPage.jsp";
</script>
