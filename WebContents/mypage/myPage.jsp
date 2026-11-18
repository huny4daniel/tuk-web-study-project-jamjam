<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,java.util.*,my.util.*,my.dao.*,my.model.*" %>
<%@ include file="/inc/loginCheck.jsp" %>
<%@ include file="/inc/header.jsp" %>
<%
	// 마이페이지 : 내 정보 + 내 예약 + 내가 쓴 리뷰
	Connection conn = ConnectionProvider.getConnection();
	Member member = null;
	List<Reservation> resList = null;
	List<Review> reviewList = null;
	try {
		member = new MemberDao().selectById(conn, loginId);
		resList = new ReservationDao().selectByUser(conn, loginId);
		reviewList = new ReviewDao().selectByUser(conn, loginId);
	} finally {
		JdbcUtil.close(conn);
	}
%>
<c:set var="member" value="<%= member %>"/>
<c:set var="resList" value="<%= resList %>"/>
<c:set var="reviewList" value="<%= reviewList %>"/>

<div class="container">
	<h2 class="page-title">마이페이지</h2>
	<div class="tabs">
		<a class="on" href="myPage.jsp">예약 · 리뷰</a>
		<a href="coupon.jsp">쿠폰함</a>
		<a href="guest.jsp">투숙객</a>
		<a href="../qna/qnaList.jsp">1:1 문의</a>
		<a href="../member/memberUpdateForm.jsp">회원 정보 수정</a>
	</div>

	<!-- 내 정보 : 카드 없이 큰 이름 + 작은 연락처 -->
	<div class="profile">
		<div>
			<div class="who"><c:out value="${member.name}"/> 님<span>${member.userId}</span></div>
			<div class="meta"><c:out value="${member.phone}"/> · <c:out value="${member.email}"/> · 가입일 <fmt:formatDate value="${member.registerTime}" pattern="yyyy-MM-dd"/></div>
		</div>
		<a class="btn btn-small btn-line" href="../member/memberUpdateForm.jsp">정보 수정</a>
	</div>

	<section class="group">
		<div class="group-head"><h3>내 예약 내역<span class="count">${resList.size()}건</span></h3></div>
		<table class="list">
			<tr>
				<th>예약번호</th><th>객실</th><th>숙박 기간</th><th>인원</th><th>결제 금액</th><th>결제 방법</th><th>상태</th><th>관리</th>
			</tr>
			<c:if test="${empty resList}">
				<tr><td colspan="8">예약 내역이 없습니다.</td></tr>
			</c:if>
			<c:forEach var="res" items="${resList}">
				<tr>
					<td><a href="../reserve/resDetail.jsp?resId=${res.resId}" title="예약 확인서 보기"><b>${res.resId}</b> <span class="muted">확인서</span></a></td>
					<td><a href="../room/roomDetail.jsp?roomId=${res.roomId}"><b>${res.roomType}</b> ${res.roomNo}</a></td>
					<td>${res.checkIn} ~ ${res.checkOut}</td>
					<td>${res.guests}명</td>
					<td><fmt:formatNumber value="${res.totalPrice}" pattern="#,###"/>원
						<c:if test="${not empty res.couponCode}"><br><span class="muted">쿠폰 ${res.couponCode}</span></c:if>
					</td>
					<td>${res.payMethod}</td>
					<%-- 상태 글자와 버튼 표시 여부는 Reservation.java 의 메서드에서 if 문으로 계산해 둠 --%>
					<td><span class="badge">${res.statusLabel}</span></td>
					<td>
						<c:if test="${res.cancelable}">
							<a class="btn btn-small btn-red" href="../reserve/cancel.jsp?resId=${res.resId}"
							   onclick="return confirm('예약을 취소하시겠습니까?')">예약 취소</a>
						</c:if>
						<c:if test="${res.reviewable}">
							<a class="btn btn-small btn-gold" href="../review/reviewForm.jsp?resId=${res.resId}">리뷰 쓰기</a>
						</c:if>
						<c:if test="${res.reviewed}"><span class="muted">리뷰 작성 완료</span></c:if>
					</td>
				</tr>
			</c:forEach>
		</table>
	</section>

	<section class="group">
		<div class="group-head"><h3>내가 쓴 리뷰<span class="count">${reviewList.size()}개</span></h3></div>
		<c:if test="${empty reviewList}">
			<p class="muted">작성한 리뷰가 없습니다.</p>
		</c:if>
		<c:forEach var="review" items="${reviewList}">
			<div class="review">
				<div class="head">
					<b>${review.roomType}</b> ·
					<span class="stars"><c:forEach begin="1" end="${review.rating}">★</c:forEach><c:forEach begin="${review.rating + 1}" end="5">☆</c:forEach></span>
					· <fmt:formatDate value="${review.regDate}" pattern="yyyy-MM-dd"/>
				</div>
				<div class="pre"><c:out value="${review.content}"/></div>
			</div>
		</c:forEach>
	</section>
</div>
<%@ include file="/inc/footer.jsp" %>
