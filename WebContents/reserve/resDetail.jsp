<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,my.util.*,my.dao.*,my.model.*" %>
<%@ include file="/inc/loginCheck.jsp" %>
<%@ include file="/inc/header.jsp" %>
<%--
	예약 확인서 (결제가 끝나면 여기로 오고, 마이페이지 예약번호를 눌러도 여기로 옴)
	resDetail.jsp?resId=5         -> 확인서
	resDetail.jsp?resId=5&done=1  -> 맨 위에 "예약이 완료되었습니다" 문구 추가
	본인 예약만 볼 수 있다.
--%>
<%
	int resId = Integer.parseInt(request.getParameter("resId"));
	Reservation res = null;
	Member member = null;
	Connection conn = ConnectionProvider.getConnection();
	try {
		res = new ReservationDao().selectById(conn, resId);
		member = new MemberDao().selectById(conn, loginId);
	} finally {
		JdbcUtil.close(conn);
	}
	if (res == null || !res.getUserId().equals(loginId)) {
		response.sendRedirect("../mypage/myPage.jsp");
		return;
	}
%>
<c:set var="res" value="<%= res %>"/>
<c:set var="member" value="<%= member %>"/>

<div class="container">
	<div class="receipt">
		<c:if test="${param.done == '1'}">
			<div class="done">
				<span class="eyebrow">THANK YOU</span>
				<h2>예약이 완료되었습니다</h2>
				<p class="muted">파도 소리와 함께 기다리고 있겠습니다.</p>
			</div>
		</c:if>

		<div class="box">
			<div class="receipt-head">
				<div>
					<span class="eyebrow">RESERVATION CONFIRMATION</span>
					<h3>예약 확인서</h3>
				</div>
				<span class="badge">${res.statusLabel}</span>
			</div>
			<table class="form">
				<tr><th>예약번호</th><td><b>${res.resId}</b> <span class="muted">· 예약일 <fmt:formatDate value="${res.resDate}" pattern="yyyy-MM-dd HH:mm"/></span></td></tr>
				<tr><th>예약자</th><td><c:out value="${member.name}"/> <span class="muted">· <c:out value="${member.phone}"/></span></td></tr>
				<tr><th>객실</th><td>${res.roomType} ${res.roomNo}</td></tr>
				<tr><th>체크인</th><td>${res.checkIn} <span class="muted">15:00 부터</span></td></tr>
				<tr><th>체크아웃</th><td>${res.checkOut} <span class="muted">11:00 까지</span></td></tr>
				<tr><th>인원</th><td>${res.guests}명</td></tr>
				<tr><th>결제 금액</th><td><b><fmt:formatNumber value="${res.totalPrice}" pattern="#,###"/>원</b>
					<c:if test="${not empty res.couponCode}"><span class="muted"> · 쿠폰 ${res.couponCode} 적용</span></c:if></td></tr>
				<tr><th>요청사항</th><td class="pre">${empty res.requestNote ? '없음' : ''}<c:out value="${res.requestNote}"/></td></tr>
				<tr><th>결제 방법</th><td>${res.payMethod}<c:if test="${not empty res.payDetail}"> <span class="muted">· <c:out value="${res.payDetail}"/></span></c:if></td></tr>
			</table>
			<p class="muted" style="margin-bottom:0;">
				호텔 잠잠 · 경기도 시흥시 배곧동 (가상 주소) · 031-000-0000<br>
				체크인 날짜 전까지 마이페이지에서 무료로 취소할 수 있습니다.
			</p>
		</div>

		<p class="receipt-btns">
			<a class="btn btn-gold" href="<%= ctx %>/mypage/myPage.jsp">마이페이지에서 보기</a>
			<a class="btn btn-line" href="<%= ctx %>/info/location.jsp">오시는 길</a>
			<a class="btn btn-line" href="javascript:window.print()">인쇄</a>
		</p>
	</div>
</div>
<%@ include file="/inc/footer.jsp" %>
