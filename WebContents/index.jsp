<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,java.util.*,my.util.*,my.dao.*,my.model.*" %>
<%@ include file="/inc/header.jsp" %>
<%
	// 메인 화면 : 예약이 많은 인기 객실 3개를 가져온다
	Connection conn = ConnectionProvider.getConnection();
	List<Room> popularList = null;
	Room bestOcean = null, bestCity = null, bestPark = null;
	try {
		RoomDao roomDao = new RoomDao();
		popularList = roomDao.selectPopular(conn, 3);
		// 뷰 추천 : 전망마다 평점이 가장 높은 객실 1개씩
		bestOcean = roomDao.selectBestByView(conn, "오션뷰");
		bestCity = roomDao.selectBestByView(conn, "시티뷰");
		bestPark = roomDao.selectBestByView(conn, "파크뷰");
	} finally {
		JdbcUtil.close(conn);
	}

	// 검색 띠의 날짜 기본값 : 오늘 체크인, 내일 체크아웃 ('yyyy-MM-dd' 문자열)
	String today = java.time.LocalDate.now().toString();
	String tomorrow = java.time.LocalDate.now().plusDays(1).toString();
%>
<c:set var="popularList" value="<%= popularList %>"/>
<c:set var="bestOcean" value="<%= bestOcean %>"/>
<c:set var="bestCity" value="<%= bestCity %>"/>
<c:set var="bestPark" value="<%= bestPark %>"/>

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
		<div class="field"><label for="checkIn">체크인</label><input type="date" id="checkIn" name="checkIn" value="<%= today %>" min="<%= today %>" onchange="fixCheckOut(this.form)"></div>
		<div class="field"><label for="checkOut">체크아웃</label><input type="date" id="checkOut" name="checkOut" value="<%= tomorrow %>" min="<%= tomorrow %>"></div>
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

	<!-- 뷰 추천 : 전망별 설명 + 그 전망에서 평점이 가장 높은 객실 -->
	<section class="section">
		<div class="section-head">
			<div><span class="eyebrow">VIEW GUIDE</span><h2>창밖 풍경으로 고르는 객실</h2></div>
			<a href="<%= ctx %>/room/roomList.jsp">전체 객실 보기 →</a>
		</div>
		<div class="views">
			<div class="view-item">
				<span class="tag">OCEAN</span>
				<h3>오션뷰</h3>
				<p>서해 바다가 창 가득 펼쳐집니다. 해 질 무렵 붉게 물드는 노을이 가장 아름답습니다.</p>
				<p class="best-time">추천 시간 · 17:00 ~ 18:30 노을</p>
				<c:if test="${bestOcean != null}">
					<a class="pick" href="<%= ctx %>/room/roomDetail.jsp?roomId=${bestOcean.roomId}"><small>추천 객실</small><b>${bestOcean.roomType}</b> <span><fmt:formatNumber value="${bestOcean.salePrice}" pattern="#,###"/>원~</span></a>
				</c:if>
				<a class="more" href="<%= ctx %>/room/roomList.jsp?viewType=%EC%98%A4%EC%85%98%EB%B7%B0">오션뷰 객실 모두 보기 →</a>
			</div>
			<div class="view-item">
				<span class="tag">PARK</span>
				<h3>파크뷰</h3>
				<p>배곧한울공원의 초록 산책로가 내려다보입니다. 아이, 반려동물과 함께라면 추천합니다.</p>
				<p class="best-time">추천 시간 · 07:00 ~ 09:00 아침 산책</p>
				<c:if test="${bestPark != null}">
					<a class="pick" href="<%= ctx %>/room/roomDetail.jsp?roomId=${bestPark.roomId}"><small>추천 객실</small><b>${bestPark.roomType}</b> <span><fmt:formatNumber value="${bestPark.salePrice}" pattern="#,###"/>원~</span></a>
				</c:if>
				<a class="more" href="<%= ctx %>/room/roomList.jsp?viewType=%ED%8C%8C%ED%81%AC%EB%B7%B0">파크뷰 객실 모두 보기 →</a>
			</div>
			<div class="view-item">
				<span class="tag">CITY</span>
				<h3>시티뷰</h3>
				<p>배곧 신도시의 불빛이 반짝이는 야경 객실입니다. 합리적인 가격으로 머물기 좋습니다.</p>
				<p class="best-time">추천 시간 · 20:00 이후 야경</p>
				<c:if test="${bestCity != null}">
					<a class="pick" href="<%= ctx %>/room/roomDetail.jsp?roomId=${bestCity.roomId}"><small>추천 객실</small><b>${bestCity.roomType}</b> <span><fmt:formatNumber value="${bestCity.salePrice}" pattern="#,###"/>원~</span></a>
				</c:if>
				<a class="more" href="<%= ctx %>/room/roomList.jsp?viewType=%EC%8B%9C%ED%8B%B0%EB%B7%B0">시티뷰 객실 모두 보기 →</a>
			</div>
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
				<p>서해 바다와 노을이 보이는 객실을 운영합니다. 객실 검색의 전망 필터에서 '오션뷰'를 선택해 보세요.</p>
			</div>
			<div class="item">
				<svg viewBox="0 0 28 28" fill="none" stroke="currentColor" stroke-width="1.2"><circle cx="8" cy="11" r="2.2"/><circle cx="14" cy="7.5" r="2.2"/><circle cx="20" cy="11" r="2.2"/><path d="M14 14.5c-4 0-6.5 4-6.5 6.5 0 1.6 1.4 2.4 3 2.4h7c1.6 0 3-.8 3-2.4 0-2.5-2.5-6.5-6.5-6.5z"/></svg>
				<h3>반려동물 동반</h3>
				<p>펫 프렌들리 객실에서는 반려동물과 함께 머무를 수 있습니다. 펫 침대와 식기를 무료로 제공합니다.</p>
			</div>
			<div class="item">
				<svg viewBox="0 0 28 28" fill="none" stroke="currentColor" stroke-width="1.2"><rect x="3" y="8" width="22" height="13"/><path d="M3 13h22M9 8v13"/></svg>
				<h3>회원 전용 혜택</h3>
				<p>회원가입하면 10% 할인 쿠폰이 쿠폰함에 바로 들어옵니다. 쿠폰 번호 입력 없이 결제 화면에서 골라 쓰세요.</p>
			</div>
		</div>
		<p class="links">
			<a class="btn btn-line" href="<%= ctx %>/info/location.jsp">오시는 길</a>
			<a class="btn btn-line" href="<%= ctx %>/info/tour.jsp">주변 즐길거리</a>
		</p>
	</section>
</div>

<script>
	// 체크인을 바꿨을 때 체크아웃이 같은 날이거나 더 빠르면 체크인 다음 날로 맞춰 준다
	function fixCheckOut(f) {
		if (f.checkIn.value == "") return;
		var next = new Date(f.checkIn.value);
		next.setDate(next.getDate() + 1);
		var nextStr = next.toISOString().substring(0, 10);   // 'yyyy-MM-dd'
		f.checkOut.min = nextStr;
		if (f.checkOut.value == "" || f.checkOut.value <= f.checkIn.value) {
			f.checkOut.value = nextStr;
		}
	}

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
