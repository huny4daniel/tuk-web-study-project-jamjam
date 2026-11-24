<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,java.util.*,my.util.*,my.dao.*,my.model.*" %>
<%@ include file="/inc/loginCheck.jsp" %>
<%@ include file="/inc/header.jsp" %>
<%--
	쿠폰함 : 위에는 내가 가진 디지털 쿠폰, 아래에는 지금 받을 수 있는 쿠폰(다운로드형)
	쿠폰은 결제 화면에서 골라서 쓴다 (번호를 입력하지 않음)
--%>
<%
	Connection conn = ConnectionProvider.getConnection();
	List<MemberCoupon> myList = null;
	List<Coupon> downList = new ArrayList<Coupon>();
	try {
		MemberCouponDao mcDao = new MemberCouponDao();
		myList = mcDao.selectByUser(conn, loginId);
		// 받을 수 있는 쿠폰 중 아직 안 받은 것만
		for (Coupon c : new CouponDao().selectByIssueType(conn, "다운로드")) {
			if (!mcDao.hasCoupon(conn, loginId, c.getCouponCode())) {
				downList.add(c);
			}
		}
	} finally {
		JdbcUtil.close(conn);
	}
%>
<c:set var="myList" value="<%= myList %>"/>
<c:set var="downList" value="<%= downList %>"/>

<div class="container">
	<h2 class="page-title">쿠폰함</h2>
	<div class="tabs">
		<a href="myPage.jsp">예약 · 리뷰</a>
		<a class="on" href="coupon.jsp">쿠폰함</a>
		<a href="guest.jsp">투숙객</a>
		<a href="card.jsp">결제수단</a>
		<a href="../qna/qnaList.jsp">1:1 문의</a>
		<a href="../member/memberUpdateForm.jsp">회원 정보 수정</a>
	</div>

	<section class="group">
		<div class="group-head">
			<h3>내 쿠폰<span class="count">${myList.size()}장</span></h3>
			<span class="desc">결제 화면에서 쓸 쿠폰을 고르면 할인됩니다. 예약을 취소하면 쓴 쿠폰은 다시 돌아옵니다.</span>
		</div>
		<c:if test="${empty myList}"><p class="muted">가진 쿠폰이 없습니다.</p></c:if>
		<div class="coupons">
			<c:forEach var="mc" items="${myList}">
				<div class="coupon ${mc.usable ? '' : 'off'}">
					<div class="rate">${mc.discountRate}<small>%</small></div>
					<div class="info">
						<b><c:out value="${mc.couponName}"/></b>
						<span class="muted">${mc.startDate} ~ ${mc.endDate}</span>
					</div>
					<span class="badge ${mc.usable ? 'badge-green' : ''}">${mc.statusLabel}</span>
				</div>
			</c:forEach>
		</div>
	</section>

	<section class="group">
		<div class="group-head"><h3>쿠폰 받기</h3></div>
		<c:if test="${empty downList}"><p class="muted">지금 받을 수 있는 쿠폰이 없습니다.</p></c:if>
		<div class="coupons">
			<c:forEach var="c" items="${downList}">
				<div class="coupon">
					<div class="rate">${c.discountRate}<small>%</small></div>
					<div class="info">
						<b><c:out value="${c.couponName}"/></b>
						<span class="muted">${c.startDate} ~ ${c.endDate}</span>
					</div>
					<a class="btn btn-small btn-gold" href="couponDown.jsp?couponCode=${c.couponCode}">받기</a>
				</div>
			</c:forEach>
		</div>
	</section>
</div>
<%@ include file="/inc/footer.jsp" %>
