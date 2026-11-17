<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,java.util.*,my.util.*,my.dao.*,my.model.*" %>
<%@ include file="/inc/adminHeader.jsp" %>
<%
	// 관리자 대시보드 : 숫자 요약 + 오늘 체크인 목록
	Connection conn = ConnectionProvider.getConnection();
	int roomCount = 0, upcomingCount = 0, unansweredCount = 0;
	List<Reservation> todayList = null;
	try {
		ReservationDao resDao = new ReservationDao();
		roomCount = new RoomDao().selectAll(conn).size();
		upcomingCount = resDao.countUpcoming(conn);
		todayList = resDao.selectTodayCheckIn(conn);
		unansweredCount = new QnaDao().countUnanswered(conn);
	} finally {
		JdbcUtil.close(conn);
	}
%>
<c:set var="todayList" value="<%= todayList %>"/>

<h2 class="page-title">대시보드</h2>
<div class="dash">
	<div class="item">전체 객실<b><%= roomCount %>실</b></div>
	<div class="item">투숙 예정 예약<b><%= upcomingCount %>건</b></div>
	<div class="item">오늘 체크인<b>${todayList.size()}건</b></div>
	<div class="item">답변 대기 문의<b><a href="qna/qnaList.jsp"><%= unansweredCount %>건</a></b></div>
</div>

<div class="box">
	<h3>오늘 체크인 예정</h3>
	<table class="list">
		<tr><th>예약번호</th><th>객실</th><th>예약자</th><th>숙박 기간</th><th>인원</th><th>결제</th><th>요청사항</th></tr>
		<c:if test="${empty todayList}">
			<tr><td colspan="7">오늘 체크인 예정인 예약이 없습니다.</td></tr>
		</c:if>
		<c:forEach var="res" items="${todayList}">
			<tr>
				<td>${res.resId}</td>
				<td>${res.roomType} ${res.roomNo}</td>
				<td>${res.userId}</td>
				<td>${res.checkIn} ~ ${res.checkOut}</td>
				<td>${res.guests}명</td>
				<td><fmt:formatNumber value="${res.totalPrice}" pattern="#,###"/>원 · ${res.payMethod}</td>
				<td class="left"><c:out value="${empty res.requestNote ? '-' : res.requestNote}"/></td>
			</tr>
		</c:forEach>
	</table>
</div>
<%@ include file="/inc/adminFooter.jsp" %>
