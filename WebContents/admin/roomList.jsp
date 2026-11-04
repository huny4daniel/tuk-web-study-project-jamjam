<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,java.util.*,my.util.*,my.dao.*,my.model.*" %>
<%@ include file="/inc/adminHeader.jsp" %>
<%
	Connection conn = ConnectionProvider.getConnection();
	List<Room> roomList = null;
	try {
		roomList = new RoomDao().selectAll(conn);
	} finally {
		JdbcUtil.close(conn);
	}
%>
<c:set var="roomList" value="<%= roomList %>"/>

<h2 class="page-title">객실 관리</h2>
<p><a class="btn btn-gold" href="roomForm.jsp">+ 새 객실 등록</a></p>
<table class="list">
	<tr>
		<th>번호</th><th>사진</th><th>객실 유형</th><th>호실</th><th>정가</th><th>할인</th><th>판매가</th>
		<th>인원</th><th>침대</th><th>조식</th><th>반려동물</th><th>평점</th><th>예약</th><th>관리</th>
	</tr>
	<c:forEach var="room" items="${roomList}">
		<tr>
			<td>${room.roomId}</td>
			<td><img src="<%= ctx %>/room/photo.jsp?roomId=${room.roomId}" width="80" height="55" style="object-fit:cover; border-radius:3px;"></td>
			<td><b>${room.roomType}</b></td>
			<td>${room.roomNo}</td>
			<td><fmt:formatNumber value="${room.price}" pattern="#,###"/></td>
			<td>${room.discountRate}%</td>
			<td><fmt:formatNumber value="${room.salePrice}" pattern="#,###"/></td>
			<td>${room.capacity}명</td>
			<td>${room.bedCount}</td>
			<td>${room.breakfast == 1 ? 'O' : '-'}</td>
			<td>${room.pet == 1 ? 'O' : '-'}</td>
			<td><fmt:formatNumber value="${room.avgRating}" pattern="0.0"/></td>
			<td>${room.resCount}</td>
			<td style="white-space:nowrap;">
				<a class="btn btn-small" href="roomForm.jsp?roomId=${room.roomId}">수정</a>
				<a class="btn btn-small btn-red" href="roomDelete.jsp?roomId=${room.roomId}"
				   onclick="return confirm('${room.roomType} ${room.roomNo} 객실을 삭제하시겠습니까?')">삭제</a>
			</td>
		</tr>
	</c:forEach>
</table>
<%@ include file="/inc/adminFooter.jsp" %>
