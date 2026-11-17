<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,java.util.*,my.util.*,my.dao.*,my.model.*" %>
<%@ include file="/inc/header.jsp" %>
<% request.setCharacterEncoding("utf-8"); %>
<%-- 검색 폼에서 넘어온 값(checkIn, guests, sort ...)이 RoomSearch 객체에 자동으로 담긴다 --%>
<jsp:useBean id="search" class="my.model.RoomSearch"/>
<jsp:setProperty name="search" property="*"/>
<%
	// 페이지 번호 (없으면 1페이지) - 수업 catalogPaging.jsp 와 같은 방식
	String pageNumberStr = request.getParameter("page");
	int pageNumber = 1;
	if (pageNumberStr != null && !pageNumberStr.equals("")) {
		pageNumber = Integer.parseInt(pageNumberStr);
	}

	Connection conn = ConnectionProvider.getConnection();
	RoomListView viewData = null;
	try {
		RoomDao dao = new RoomDao();
		viewData = dao.getRoomList(conn, search, pageNumber);

		// ★ SOLD OUT 표시 : 날짜를 골랐으면 그 기간과 겹치는 예약을 읽어서
		//   이번 페이지 객실 중 같은 객실(roomId)에 예약 기간을 붙여 준다 → room.soldOut 이 true 가 됨
		if (search.isDateSelected()) {
			List<Reservation> overlapList = new ReservationDao().selectOverlap(conn, search.getCheckIn(), search.getCheckOut());
			for (Room room : viewData.getRoomList()) {
				for (Reservation res : overlapList) {
					if (res.getRoomId() == room.getRoomId()) {
						room.addBooked(res.getCheckIn(), res.getCheckOut());
					}
				}
			}
		}
	} finally {
		JdbcUtil.close(conn);
	}
%>
<c:set var="viewData" value="<%= viewData %>"/>
<c:set var="search" value="<%= search %>"/>

<div class="container">
	<span class="eyebrow">ROOMS</span>
	<h2 class="page-title">객실 예약</h2>
	<p class="page-sub">날짜와 인원을 선택하면 예약 가능한 객실만 보여드립니다.</p>
	<div class="room-layout">

		<!-- 왼쪽 : 검색 / 필터 / 정렬 (GET 방식이라 조건이 주소창에 남음) -->
		<form class="filter" action="roomList.jsp" method="get">
			<h3>날짜 · 인원</h3>
			<p><label class="title">체크인</label><input type="date" name="checkIn" value="${search.checkIn}"></p>
			<p><label class="title">체크아웃</label><input type="date" name="checkOut" value="${search.checkOut}"></p>
			<p><label class="title">인원</label><input type="number" name="guests" min="1" max="10" value="${search.guests}"></p>
			<p><label><input type="checkbox" name="available" value="1" ${search.available == '1' ? 'checked' : ''}> 예약 가능한 객실만 보기</label></p>

			<h3>필터</h3>
			<p>
				<label><input type="checkbox" name="breakfast" value="1" ${search.breakfast == '1' ? 'checked' : ''}> 조식 포함</label><br>
				<label><input type="checkbox" name="pet" value="1" ${search.pet == '1' ? 'checked' : ''}> 반려동물 동반</label>
			</p>
			<p>
				<label class="title">침대 수</label>
				<select name="bedCount">
					<option value="">상관없음</option>
					<option value="1" ${search.bedCount == '1' ? 'selected' : ''}>1개 이상</option>
					<option value="2" ${search.bedCount == '2' ? 'selected' : ''}>2개 이상</option>
					<option value="3" ${search.bedCount == '3' ? 'selected' : ''}>3개 이상</option>
				</select>
			</p>
			<p>
				<label class="title">편의시설</label>
				<select name="amenity">
					<option value="">상관없음</option>
					<option value="오션뷰" ${search.amenity == '오션뷰' ? 'selected' : ''}>오션뷰</option>
					<option value="시티뷰" ${search.amenity == '시티뷰' ? 'selected' : ''}>시티뷰</option>
					<option value="욕조" ${search.amenity == '욕조' ? 'selected' : ''}>욕조</option>
					<option value="주방" ${search.amenity == '주방' ? 'selected' : ''}>주방</option>
					<option value="거실" ${search.amenity == '거실' ? 'selected' : ''}>거실</option>
					<option value="세탁기" ${search.amenity == '세탁기' ? 'selected' : ''}>세탁기</option>
					<option value="펫침대" ${search.amenity == '펫침대' ? 'selected' : ''}>펫침대</option>
				</select>
			</p>

			<h3>정렬</h3>
			<p>
				<select name="sort">
					<option value="">기본순</option>
					<option value="price" ${search.sort == 'price' ? 'selected' : ''}>낮은 가격순</option>
					<option value="priceDesc" ${search.sort == 'priceDesc' ? 'selected' : ''}>높은 가격순</option>
					<option value="rating" ${search.sort == 'rating' ? 'selected' : ''}>평점 높은순</option>
					<option value="popular" ${search.sort == 'popular' ? 'selected' : ''}>인기순(예약 많은 순)</option>
				</select>
			</p>
			<input type="submit" class="btn btn-gold btn-block" value="검색">
			<p style="text-align:center; margin-top:10px;"><a class="muted" href="roomList.jsp">조건 초기화</a></p>
		</form>

		<!-- 오른쪽 : 결과 목록 -->
		<div class="room-area">
			<div class="top">
				<span>
					<c:if test="${search.dateSelected}">
						<b>${search.checkIn} ~ ${search.checkOut}</b> ${search.available == '1' ? '예약 가능한' : '기준'}
					</c:if>
					객실 <b>${viewData.roomTotalCount}</b>개
					<c:if test="${search.dateSelected and search.available != '1'}">
						<span class="muted"> · 이미 예약된 객실은 SOLD OUT 으로 표시됩니다</span>
					</c:if>
				</span>
			</div>

			<c:if test="${viewData.roomTotalCount == 0}">
				<div class="box">조건에 맞는 객실이 없습니다. 날짜나 필터를 바꿔 보세요.</div>
			</c:if>

			<div class="cards">
				<c:forEach var="room" items="${viewData.roomList}">
					<%@ include file="/inc/roomCard.jsp" %>
				</c:forEach>
			</div>

			<!-- 페이지 번호 : 지금 검색 조건(search.queryString)을 그대로 붙여서 이동 -->
			<div class="paging">
				<c:forEach var="i" begin="1" end="${viewData.pageTotalCount}">
					<a href="roomList.jsp?${search.queryString}page=${i}" class="${i == viewData.currentPageNumber ? 'on' : ''}">${i}</a>
				</c:forEach>
			</div>
		</div>
	</div>
</div>
<%@ include file="/inc/footer.jsp" %>
