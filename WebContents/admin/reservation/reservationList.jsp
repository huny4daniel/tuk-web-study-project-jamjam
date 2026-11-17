<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,java.util.*,my.util.*,my.dao.*,my.model.*" %>
<%@ include file="/inc/adminHeader.jsp" %>
<%
	request.setCharacterEncoding("utf-8");
	String status = request.getParameter("status");   // 비어 있으면 전체
	Connection conn = ConnectionProvider.getConnection();
	List<Reservation> resList = null;
	try {
		resList = new ReservationDao().selectAll(conn, status);
	} finally {
		JdbcUtil.close(conn);
	}
%>
<c:set var="resList" value="<%= resList %>"/>

<h2 class="page-title">예약 관리</h2>
<div class="tabs">
	<a href="reservationList.jsp" class="${empty param.status ? 'on' : ''}">전체</a>
	<a href="reservationList.jsp?status=예약완료" class="${param.status == '예약완료' ? 'on' : ''}">예약완료</a>
	<a href="reservationList.jsp?status=취소" class="${param.status == '취소' ? 'on' : ''}">취소</a>
</div>
<table class="list">
	<tr>
		<th>예약번호</th><th>예약일</th><th>예약자</th><th>객실</th><th>숙박 기간</th><th>인원</th>
		<th>금액</th><th>쿠폰</th><th>결제</th><th>상태</th><th>관리</th>
	</tr>
	<c:if test="${empty resList}">
		<tr><td colspan="11">예약이 없습니다.</td></tr>
	</c:if>
	<c:forEach var="res" items="${resList}">
		<tr>
			<td>${res.resId}</td>
			<td><fmt:formatDate value="${res.resDate}" pattern="yyyy-MM-dd"/></td>
			<td>${res.userId}</td>
			<td>${res.roomType} ${res.roomNo}
				<c:if test="${not empty res.requestNote}"><br><span class="badge badge-gold" title="<c:out value='${res.requestNote}'/>">요청사항</span></c:if>
			</td>
			<td>${res.checkIn} ~ ${res.checkOut}</td>
			<td>${res.guests}명</td>
			<td><fmt:formatNumber value="${res.totalPrice}" pattern="#,###"/>원</td>
			<td>${empty res.couponCode ? '-' : res.couponCode}</td>
			<td>${res.payMethod}</td>
			<td><span class="badge">${res.statusLabel}</span></td>
			<td>
				<c:if test="${res.status == '예약완료' and not res.finished}">
					<a class="btn btn-small btn-red" href="resCancel.jsp?resId=${res.resId}"
					   onclick="return confirm('${res.resId}번 예약을 취소 처리하시겠습니까?')">취소 처리</a>
				</c:if>
			</td>
		</tr>
		<c:if test="${not empty res.requestNote}">
			<tr class="note-row"><td></td><td colspan="10" class="left"><span class="muted">요청사항 ·</span> <c:out value="${res.requestNote}"/></td></tr>
		</c:if>
	</c:forEach>
</table>
<%@ include file="/inc/adminFooter.jsp" %>
