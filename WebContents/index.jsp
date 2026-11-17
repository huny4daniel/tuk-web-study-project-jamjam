<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,java.util.*,my.util.*,my.dao.*,my.model.*" %>
<%@ include file="/inc/header.jsp" %>
<%
	// 메인 화면 : 예약이 많은 인기 객실 3개를 가져온다
	Connection conn = ConnectionProvider.getConnection();
	List<Room> popularList = null;
	try {
		RoomDao roomDao = new RoomDao();
		popularList = roomDao.selectPopular(conn, 3);
	} finally {
		JdbcUtil.close(conn);
	}
%>
<c:set var="popularList" value="<%= popularList %>"/>

<!-- 가로로 긴 바다 사진 + 바로 아래 붙은 빠른 검색 -->
<section class="hero">
	<div class="photo">
		<div class="txt">
			<span class="eyebrow">시흥 배곧 · 바다 앞 호텔</span>
			<h1>오늘 밤은,<br>파도 소리에 잠잠.</h1>
			<p>바다 보며 쉬고, 노을 보며 자는 곳. 호텔 잠잠</p>
		</div>
	</div>

	<!-- 검색 버튼을 누르면 객실 목록 페이지로 날짜/인원이 전달된다 (GET 방식) -->
	<form class="search-bar" action="<%= ctx %>/room/roomList.jsp" method="get" onsubmit="return checkDate(this)">
		<div class="field"><label for="checkIn">체크인</label><input type="date" id="checkIn" name="checkIn"></div>
		<div class="field"><label for="checkOut">체크아웃</label><input type="date" id="checkOut" name="checkOut"></div>
		<div class="field"><label for="guests">인원</label>
			<select id="guests" name="guests">
				<option value="1">성인 1명</option>
				<option value="2" selected>성인 2명</option>
				<option value="3">성인 3명</option>
				<option value="4">성인 4명</option>
				<option value="5">성인 5명</option>
			</select>
		</div>
		<input type="submit" class="btn btn-gold" value="객실 검색">
	</form>
</section>

<div class="container" style="padding-top:0;">

	<section class="section intro">
		<div class="pic"></div>
		<div class="text">
			<span class="eyebrow">ABOUT</span>
			<h2>파도 소리와 함께<br>깊은 잠에 드는 곳</h2>
			<p>
				호텔 잠잠은 서해 바다를 마주한 작은 부티크 호텔입니다.
				모든 객실은 숙면을 위해 설계된 침구와 차음 설계를 갖추고 있으며,
				일부 객실에서는 창밖으로 서해의 노을을 감상할 수 있습니다.
			</p>
			<a class="btn btn-line" href="<%= ctx %>/room/roomList.jsp">전체 객실 보기</a>
		</div>
	</section>

	<section class="section">
		<div class="section-head">
			<div><span class="eyebrow">BEST</span><h2>지금 가장 인기 있는 객실</h2></div>
			<a href="<%= ctx %>/room/roomList.jsp">전체 객실 보기 →</a>
		</div>
		<div class="cards">
			<c:forEach var="room" items="${popularList}">
				<%@ include file="/inc/roomCard.jsp" %>
			</c:forEach>
		</div>
	</section>

	<section class="section">
		<div class="section-head no-line">
			<div><span class="eyebrow">WHY JAMJAM</span><h2>잠잠에서만 누리는 것</h2></div>
		</div>
		<div class="features">
			<div class="item">
				<svg viewBox="0 0 28 28" fill="none" stroke="currentColor" stroke-width="1.2"><path d="M2 17c3 0 3-2.5 6-2.5s3 2.5 6 2.5 3-2.5 6-2.5 3 2.5 6 2.5M2 22c3 0 3-2.5 6-2.5s3 2.5 6 2.5 3-2.5 6-2.5 3 2.5 6 2.5"/><path d="M8 11a6 6 0 0 1 12 0"/></svg>
				<h3>오션뷰 객실</h3>
				<p>서해 바다와 노을이 보이는 객실을 운영합니다. 객실 검색의 편의시설 필터에서 '오션뷰'를 선택해 보세요.</p>
			</div>
			<div class="item">
				<svg viewBox="0 0 28 28" fill="none" stroke="currentColor" stroke-width="1.2"><circle cx="8" cy="11" r="2.2"/><circle cx="14" cy="7.5" r="2.2"/><circle cx="20" cy="11" r="2.2"/><path d="M14 14.5c-4 0-6.5 4-6.5 6.5 0 1.6 1.4 2.4 3 2.4h7c1.6 0 3-.8 3-2.4 0-2.5-2.5-6.5-6.5-6.5z"/></svg>
				<h3>반려동물 동반</h3>
				<p>펫 프렌들리 객실에서는 반려동물과 함께 머무를 수 있습니다. 펫 침대와 식기를 무료로 제공합니다.</p>
			</div>
			<div class="item">
				<svg viewBox="0 0 28 28" fill="none" stroke="currentColor" stroke-width="1.2"><rect x="3" y="8" width="22" height="13"/><path d="M3 13h22M9 8v13"/></svg>
				<h3>회원 전용 혜택</h3>
				<p>신규 회원은 <b>WELCOME10</b> 쿠폰으로 10% 할인을 받을 수 있습니다. 예약할 때 쿠폰 번호를 입력하세요.</p>
			</div>
		</div>
		<p class="links">
			<a class="btn btn-line" href="<%= ctx %>/info/location.jsp">오시는 길</a>
			<a class="btn btn-line" href="<%= ctx %>/info/tour.jsp">주변 즐길거리</a>
		</p>
	</section>
</div>

<script>
	// 체크인/체크아웃 둘 중 하나만 넣었거나 순서가 거꾸로면 막기
	function checkDate(f) {
		if ((f.checkIn.value == "") != (f.checkOut.value == "")) {
			alert("체크인과 체크아웃 날짜를 모두 선택하세요.");
			return false;
		}
		if (f.checkIn.value != "" && f.checkIn.value >= f.checkOut.value) {
			alert("체크아웃은 체크인 다음 날 이후여야 합니다.");
			return false;
		}
		return true;
	}
</script>
<%@ include file="/inc/footer.jsp" %>
