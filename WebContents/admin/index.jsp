<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,java.util.*,my.util.*,my.dao.*,my.model.*" %>
<%@ include file="/inc/adminHeader.jsp" %>
<%
	// 관리자 대시보드 : 숫자 요약 + 오늘 체크인 목록
	Connection conn = ConnectionProvider.getConnection();
	int roomCount = 0, upcomingCount = 0, unansweredCount = 0, breakfastToday = 0;
	List<Reservation> todayList = null;
	try {
		ReservationDao resDao = new ReservationDao();
		roomCount = new RoomDao().selectAll(conn).size();
		upcomingCount = resDao.countUpcoming(conn);
		todayList = resDao.selectTodayCheckIn(conn);
		breakfastToday = resDao.countBreakfastToday(conn);   // 오늘 아침 조식 인원 (포함 객실 + 추가 신청)
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
	<div class="item" title="조식 포함 객실 투숙객 + 조식 추가 인원">오늘 아침 조식<b><%= breakfastToday %>명</b></div>
	<div class="item">답변 대기 문의<b><a href="qna/qnaList.jsp"><%= unansweredCount %>건</a></b></div>
</div>

<section class="group" style="margin-top:56px;">
	<div class="group-head"><h3>오늘 체크인 예정<span class="count">${todayList.size()}건</span></h3></div>
	<table class="list">
		<tr><th>예약번호</th><th>객실</th><th>예약자</th><th>숙박 기간</th><th>인원</th><th>결제</th><th>요청사항</th></tr>
		<c:if test="${empty todayList}">
			<tr><td colspan="7">오늘 체크인 예정인 예약이 없습니다.</td></tr>
		</c:if>
		<c:forEach var="res" items="${todayList}">
			<tr>
				<td>${res.resId}</td>
				<td>${res.roomType} ${res.roomNo}</td>
				<td>${res.userId}<c:if test="${not empty res.guestName}"><br><span class="muted">투숙 <c:out value="${res.guestName}"/> · <c:out value="${res.guestPhone}"/></span></c:if></td>
				<td>${res.checkIn} ~ ${res.checkOut}</td>
				<td>${res.guests}명<c:if test="${res.breakfastCount > 0}"><br><span class="muted">조식 ${res.breakfastCount}명</span></c:if></td>
				<td><fmt:formatNumber value="${res.totalPrice}" pattern="#,###"/>원 · ${res.payMethod}</td>
				<td class="left"><c:out value="${empty res.requestNote ? '-' : res.requestNote}"/></td>
			</tr>
		</c:forEach>
	</table>
</section>
<%@ include file="/inc/adminFooter.jsp" %>
