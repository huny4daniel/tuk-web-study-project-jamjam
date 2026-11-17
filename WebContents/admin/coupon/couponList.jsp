<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,java.util.*,my.util.*,my.dao.*,my.model.*" %>
<%@ include file="/inc/adminHeader.jsp" %>
<%
	Connection conn = ConnectionProvider.getConnection();
	List<Coupon> couponList = null;
	try {
		couponList = new CouponDao().selectAll(conn);
	} finally {
		JdbcUtil.close(conn);
	}
	String today = java.time.LocalDate.now().toString();   // 'yyyy-MM-dd' : 사용 기간 표시용
%>
<c:set var="couponList" value="<%= couponList %>"/>
<c:set var="today" value="<%= today %>"/>

<h2 class="page-title">할인 쿠폰 관리</h2>
<p class="muted">객실별 상시 할인은 [객실 관리]의 할인율로, 기간 한정 할인은 여기서 쿠폰으로 관리합니다.</p>

<div class="box">
	<h3>새 쿠폰 등록</h3>
	<form action="couponAdd.jsp" method="post">
		<input type="text" name="couponCode" placeholder="쿠폰 번호 (예: SPRING15)" required>
		<input type="text" name="couponName" placeholder="쿠폰 이름" required>
		<input type="number" name="discountRate" placeholder="할인율 %" min="1" max="90" required style="width:110px;">
		<input type="date" name="startDate" required> ~ <input type="date" name="endDate" required>
		<input type="submit" class="btn btn-gold" value="등록">
	</form>
</div>

<table class="list">
	<tr><th>쿠폰 번호</th><th>쿠폰 이름</th><th>할인율</th><th>사용 기간</th><th>상태</th><th>관리</th></tr>
	<c:forEach var="coupon" items="${couponList}">
		<tr>
			<td><b>${coupon.couponCode}</b></td>
			<td class="left">${coupon.couponName}</td>
			<td>${coupon.discountRate}%</td>
			<td>${coupon.startDate} ~ ${coupon.endDate}</td>
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
<%@ include file="/inc/adminFooter.jsp" %>
