<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,java.util.*,my.util.*,my.dao.*,my.model.*" %>
<%@ include file="/inc/adminHeader.jsp" %>
<%
	Connection conn = ConnectionProvider.getConnection();
	List<Coupon> couponList = null;
	try {
		couponList = new CouponDao().selectAll(conn);
		MemberCouponDao mcDao = new MemberCouponDao();
		for (Coupon c : couponList) {
			c.setIssuedCount(mcDao.countByCode(conn, c.getCouponCode()));   // 받은 회원 수
		}
	} finally {
		JdbcUtil.close(conn);
	}
	String today = java.time.LocalDate.now().toString();   // 'yyyy-MM-dd' : 사용 기간 표시용
%>
<c:set var="couponList" value="<%= couponList %>"/>
<c:set var="today" value="<%= today %>"/>

<h2 class="page-title">할인 쿠폰 관리</h2>
<p class="muted">객실별 상시 할인은 [객실 관리]의 할인율로, 기간 한정 할인은 여기서 디지털 쿠폰으로 관리합니다.
	회원은 쿠폰 번호를 입력하지 않고 쿠폰함에 받은 쿠폰을 결제 화면에서 고릅니다.<br>
	받는 방법 : <b>가입축하</b> 회원가입 때 자동 지급 · <b>다운로드</b> 회원이 쿠폰함에서 직접 받기 · <b>관리자지급</b> 아래 [쿠폰 지급]으로만</p>

<div class="box" style="margin-top:24px;">
	<div class="part">
	<h4 class="sub-title">새 쿠폰 등록</h4>
	<form action="couponAdd.jsp" method="post" class="inline-form">
		<input type="text" name="couponCode" placeholder="쿠폰 번호 (예: SPRING15)" required>
		<input type="text" name="couponName" placeholder="쿠폰 이름" required>
		<input type="number" name="discountRate" placeholder="할인율 %" min="1" max="90" required style="width:110px;">
		<input type="date" name="startDate" required> ~ <input type="date" name="endDate" required>
		<select name="issueType">
			<option>다운로드</option>
			<option>가입축하</option>
			<option>관리자지급</option>
		</select>
		<input type="submit" class="btn btn-gold" value="등록">
	</form>
	</div>
	<div class="part">
	<h4 class="sub-title">쿠폰 지급</h4>
	<form action="couponIssue.jsp" method="post" class="inline-form" onsubmit="return confirm(this.userId.value == '' ? '모든 회원에게 지급하시겠습니까?' : this.userId.value + ' 님에게 지급하시겠습니까?')">
		<select name="couponCode">
			<c:forEach var="coupon" items="${couponList}">
				<c:if test="${coupon.endDate >= today}"><option value="${coupon.couponCode}">${coupon.couponCode} · <c:out value="${coupon.couponName}"/></option></c:if>
			</c:forEach>
		</select>
		<input type="text" name="userId" placeholder="회원 아이디 (비우면 전체 회원)">
		<input type="submit" class="btn btn-gold" value="지급">
	</form>
	</div>
</div>

<section class="group" style="margin-top:56px;">
<div class="group-head"><h3>쿠폰 목록<span class="count">${couponList.size()}개</span></h3></div>
<table class="list">
	<tr><th>쿠폰 번호</th><th>쿠폰 이름</th><th>할인율</th><th>사용 기간</th><th>받는 방법</th><th>받은 회원</th><th>상태</th><th>관리</th></tr>
	<c:forEach var="coupon" items="${couponList}">
		<tr>
			<td><b>${coupon.couponCode}</b></td>
			<td class="left">${coupon.couponName}</td>
			<td>${coupon.discountRate}%</td>
			<td>${coupon.startDate} ~ ${coupon.endDate}</td>
			<td>${coupon.issueType}</td>
			<td>${coupon.issuedCount}명</td>
			<td>
				<%-- 날짜 문자열 'yyyy-MM-dd' 는 글자 순서로 비교해도 날짜 순서와 같다 --%>
				<c:if test="${coupon.endDate < today}"><span class="badge badge-red">기간 만료</span></c:if>
				<c:if test="${coupon.startDate > today}"><span class="badge">시작 전</span></c:if>
				<c:if test="${coupon.startDate <= today and coupon.endDate >= today}"><span class="badge badge-green">사용 가능</span></c:if>
			</td>
			<td>
				<a class="btn btn-small btn-red" href="couponDelete.jsp?couponCode=${coupon.couponCode}"
				   onclick="return confirm('쿠폰을 삭제하시겠습니까?')">삭제</a>
			</td>
		</tr>
	</c:forEach>
</table>
</section>
<%@ include file="/inc/adminFooter.jsp" %>
