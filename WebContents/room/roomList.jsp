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
	int priceMax = 0;   // 가격대 슬라이더 오른쪽 끝 (가장 비싼 1박 할인가를 1만 원 단위로 올림)
	try {
		RoomDao dao = new RoomDao();
		viewData = dao.getRoomList(conn, search, pageNumber);
		priceMax = (dao.selectMaxSalePrice(conn) + 9999) / 10000 * 10000;
		if (priceMax == 0) priceMax = 500000;

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
<c:set var="priceMax" value="<%= priceMax %>"/>

<div class="container">
	<span class="eyebrow">ROOMS</span>
	<h2 class="page-title">객실 예약</h2>
	<p class="page-sub">날짜와 인원을 선택하면 예약 가능한 객실만 보여드립니다.</p>
	<div class="room-layout">

		<!-- 왼쪽 : 검색 / 필터 / 정렬 (GET 방식이라 조건이 주소창에 남음) -->
		<form class="filter box-key" action="roomList.jsp" method="get">
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
				<label class="title">전망</label>
				<select name="viewType">
					<option value="">상관없음</option>
					<option value="오션뷰" ${search.viewType == '오션뷰' ? 'selected' : ''}>오션뷰</option>
					<option value="시티뷰" ${search.viewType == '시티뷰' ? 'selected' : ''}>시티뷰</option>
					<option value="파크뷰" ${search.viewType == '파크뷰' ? 'selected' : ''}>파크뷰</option>
				</select>
			</p>
			<p>
				<label class="title">편의시설</label>
				<select name="amenity">
					<option value="">상관없음</option>
					<option value="욕조" ${search.amenity == '욕조' ? 'selected' : ''}>욕조</option>
					<option value="주방" ${search.amenity == '주방' ? 'selected' : ''}>주방</option>
					<option value="거실" ${search.amenity == '거실' ? 'selected' : ''}>거실</option>
					<option value="세탁기" ${search.amenity == '세탁기' ? 'selected' : ''}>세탁기</option>
					<option value="펫침대" ${search.amenity == '펫침대' ? 'selected' : ''}>펫침대</option>
					<option value="테라스" ${search.amenity == '테라스' ? 'selected' : ''}>테라스</option>
					<option value="스파욕조" ${search.amenity == '스파욕조' ? 'selected' : ''}>스파욕조</option>
					<option value="온돌" ${search.amenity == '온돌' ? 'selected' : ''}>온돌</option>
					<option value="복층" ${search.amenity == '복층' ? 'selected' : ''}>복층</option>
					<option value="안마의자" ${search.amenity == '안마의자' ? 'selected' : ''}>안마의자</option>
					<option value="빔프로젝터" ${search.amenity == '빔프로젝터' ? 'selected' : ''}>빔프로젝터</option>
				</select>
			</p>
			<!-- 1박 가격대 : 손잡이 두 개를 끌거나 버튼을 눌러 고른다
			     range 두 개(name 없음)는 화면용이고, 실제로 검색에 보내는 값은 아래 hidden 두 개
			     (왼쪽 끝 = 하한 없음, 오른쪽 끝 = 상한 없음 → 빈 값) -->
			<div class="price-filter">
				<label class="title">1박 요금 <span id="priceText"></span></label>
				<input type="hidden" name="minPrice" value="<c:out value='${search.minPrice}'/>">
				<input type="hidden" name="maxPrice" value="<c:out value='${search.maxPrice}'/>">
				<div class="price-slider">
					<div class="track"></div>
					<div class="fill" id="priceFill"></div>
					<input type="range" id="priceLo" min="0" max="${priceMax}" step="10000" aria-label="최저 가격" oninput="slidePrice(this)" onchange="hideBubble()" onblur="hideBubble()">
					<input type="range" id="priceHi" min="0" max="${priceMax}" step="10000" aria-label="최고 가격" oninput="slidePrice(this)" onchange="hideBubble()" onblur="hideBubble()">
					<span class="bubble" id="priceBubble"></span>
				</div>
				<div class="chips" id="pricePick">
					<button type="button" data-min="" data-max="100000" onclick="pickPrice(this)">10만 원 이하</button>
					<button type="button" data-min="100000" data-max="150000" onclick="pickPrice(this)">10~15만 원</button>
					<button type="button" data-min="150000" data-max="200000" onclick="pickPrice(this)">15~20만 원</button>
					<button type="button" data-min="200000" data-max="300000" onclick="pickPrice(this)">20~30만 원</button>
					<button type="button" data-min="300000" data-max="" onclick="pickPrice(this)">30만 원 이상</button>
				</div>
				<span class="muted price-note">할인가 기준 · 인원 추가 요금 제외</span>
			</div>

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
				<div class="empty">조건에 맞는 객실이 없습니다. 날짜나 필터를 바꿔 보세요.</div>
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
<script>
	// ===== 1박 가격대 슬라이더 =====
	// range 두 개를 겹쳐서 손잡이 두 개를 만든다. 손잡이를 움직이면 hidden 칸(minPrice, maxPrice)이 바뀌고
	// [검색]을 누르면 그 값으로 검색한다 (서버 검색 방식은 숫자 칸일 때와 같음)
	var PRICE_MAX = ${priceMax};   // 오른쪽 끝 (가장 비싼 1박 할인가, 1만 원 단위 올림)
	var PRICE_STEP = 10000;
	var EN = ${sessionScope.LANG == 'en'};   // 영어 화면이면 금액을 KRW 로 (번역 스크립트는 처음 한 번만 바꾸므로)
	var pf = document.querySelector("form.filter");
	var lo = document.getElementById("priceLo");
	var hi = document.getElementById("priceHi");

	// 금액 글자 : 150000 → "150,000원" (영어 : "KRW 150,000")
	function won(n) {
		var s = String(n).replace(/\B(?=(\d{3})+(?!\d))/g, ",");
		return EN ? "KRW " + s : s + "원";
	}

	// hidden 칸 값 → 숫자 (비었거나 이상하면 null)
	function readPrice(input) {
		var n = parseInt(input.value.replace(/,/g, ""), 10);
		return isNaN(n) || n < 0 ? null : n;
	}

	// 손잡이 위치에 맞게 색칠한 구간, 제목 옆 범위 글자, 버튼 켜짐 상태를 다시 그린다
	function drawPrice() {
		var a = Number(lo.value), b = Number(hi.value);
		var fill = document.getElementById("priceFill");
		fill.style.left = (a / PRICE_MAX * 100) + "%";
		fill.style.right = (100 - b / PRICE_MAX * 100) + "%";
		// 왼쪽 손잡이가 오른쪽 끝 가까이 가면 위로 올려서 두 손잡이가 겹쳐도 잡을 수 있게 함
		lo.style.zIndex = a > PRICE_MAX / 2 ? 3 : 1;
		document.getElementById("priceText").textContent = "(" + won(a) + " - " + won(b) + (b >= PRICE_MAX ? "+" : "") + ")";

		var buttons = document.querySelectorAll("#pricePick button");
		for (var i = 0; i < buttons.length; i++) {
			var same = buttons[i].dataset.min == pf.minPrice.value && buttons[i].dataset.max == pf.maxPrice.value;
			buttons[i].className = same ? "on" : "";
		}
	}

	// 손잡이를 움직일 때 : 서로 넘어가지 않게 막고(최소 1만 원 차이), hidden 칸을 채우고, 말풍선을 띄운다
	function slidePrice(input) {
		var a = Number(lo.value), b = Number(hi.value);
		if (a > b - PRICE_STEP) {
			if (input == lo) lo.value = Math.max(0, b - PRICE_STEP);
			else hi.value = Math.min(PRICE_MAX, a + PRICE_STEP);
		}
		pf.minPrice.value = Number(lo.value) <= 0 ? "" : lo.value;            // 왼쪽 끝 = 하한 없음
		pf.maxPrice.value = Number(hi.value) >= PRICE_MAX ? "" : hi.value;    // 오른쪽 끝 = 상한 없음

		// 말풍선 : 움직이는 손잡이 바로 위 (손잡이 너비 22px 를 고려해서 가운데를 맞춤)
		var p = Number(input.value) / PRICE_MAX;
		var bubble = document.getElementById("priceBubble");
		bubble.textContent = won(Number(input.value)) + (input == hi && p >= 1 ? "+" : "");
		bubble.style.left = "calc(" + (p * 100) + "% + " + (11 - 22 * p) + "px)";
		bubble.className = "bubble show";
		drawPrice();
	}

	function hideBubble() {
		document.getElementById("priceBubble").className = "bubble";
	}

	// 가격대 버튼 : 손잡이를 그 구간으로 옮긴다. 이미 켜진 버튼을 또 누르면 전체 범위로 되돌림
	function pickPrice(btn) {
		var on = btn.className == "on";
		pf.minPrice.value = on ? "" : btn.dataset.min;
		pf.maxPrice.value = on ? "" : btn.dataset.max;
		setSlider();
	}

	// hidden 칸 값 → 손잡이 위치 (처음 열 때, 버튼을 눌렀을 때)
	//   비었으면 양 끝, 범위를 벗어나면 끝에 맞추고, 거꾸로 들어왔으면 서로 바꾼다 (서버 검색과 같은 규칙)
	function setSlider() {
		var a = readPrice(pf.minPrice), b = readPrice(pf.maxPrice);
		if (a == null) pf.minPrice.value = "";
		if (b == null) pf.maxPrice.value = "";
		if (a != null && b != null && a > b) {
			var temp = a; a = b; b = temp;
			pf.minPrice.value = a;
			pf.maxPrice.value = b;
		}
		lo.value = a == null ? 0 : Math.min(a, PRICE_MAX);
		hi.value = b == null ? PRICE_MAX : Math.min(b, PRICE_MAX);
		drawPrice();
	}
	setSlider();
</script>
<%@ include file="/inc/footer.jsp" %>
