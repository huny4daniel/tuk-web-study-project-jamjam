<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,my.util.*,my.dao.*,my.model.*" %>
<%@ include file="/inc/loginCheck.jsp" %>
<%@ include file="/inc/header.jsp" %>
<%
	int resId = Integer.parseInt(request.getParameter("resId"));
	Connection conn = ConnectionProvider.getConnection();
	Reservation res = null;
	try {
		res = new ReservationDao().selectById(conn, resId);
	} finally {
		JdbcUtil.close(conn);
	}
	// 남의 예약이거나 아직 숙박이 끝나지 않았으면 마이페이지로 돌려보낸다
	if (res == null || !res.getUserId().equals(loginId) || !res.isReviewable()) {
		response.sendRedirect("myPage.jsp");
		return;
	}
%>
<c:set var="res" value="<%= res %>"/>
<div class="container">
	<div class="box form-box" style="width:600px;">
		<h2 class="page-title">리뷰 쓰기</h2>
		<p><b>${res.roomType} ${res.roomNo}</b><br><span class="muted">${res.checkIn} ~ ${res.checkOut} 숙박</span></p>
		<form action="review.jsp" method="post" onsubmit="return checkForm(this)">
			<input type="hidden" name="resId" value="${res.resId}">
			<p>
				<label>평점</label>
				<select name="rating">
					<option value="5">★★★★★ (5점) 아주 좋아요</option>
					<option value="4">★★★★☆ (4점) 좋아요</option>
					<option value="3">★★★☆☆ (3점) 보통이에요</option>
					<option value="2">★★☆☆☆ (2점) 별로예요</option>
					<option value="1">★☆☆☆☆ (1점) 실망이에요</option>
				</select>
			</p>
			<p><label>후기</label><textarea name="content" placeholder="숙박은 어떠셨나요?"></textarea></p>
			<input type="submit" class="btn btn-gold btn-block" value="리뷰 등록">
		</form>
	</div>
</div>
<script>
	function checkForm(f) {
		if (f.content.value.trim() == "") {
			alert("후기 내용을 입력하세요.");
			return false;
		}
		return true;
	}
</script>
<%@ include file="/inc/footer.jsp" %>
