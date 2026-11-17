<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,java.util.*,my.util.*,my.dao.*,my.model.*" %>
<%@ include file="/inc/header.jsp" %>
<%
	int roomId = Integer.parseInt(request.getParameter("roomId"));

	// 한 페이지에서 DAO 두 개를 쓰지만 Connection 은 하나만 열고 마지막에 닫는다
	Connection conn = ConnectionProvider.getConnection();
	Room room = null;
	List<Review> reviewList = null;
	List<Reservation> bookedList = null;   // 달력에 '마감'으로 표시할 이 객실의 앞으로의 예약
	try {
		room = new RoomDao().selectById(conn, roomId);
		reviewList = new ReviewDao().selectByRoom(conn, roomId);
		bookedList = new ReservationDao().selectBookedByRoom(conn, roomId);
	} finally {
		JdbcUtil.close(conn);
	}

	if (room == null) {
		out.println("<script>alert('없는 객실입니다.'); location.href='roomList.jsp';</script>");
		return;
	}
	// 편의시설 "WiFi,TV,욕조" -> 배열로 나눠서 태그처럼 보여주기
	String[] amenityList = room.getAmenities() == null ? new String[0] : room.getAmenities().split(",");
%>
<c:set var="room" value="<%= room %>"/>
<c:set var="reviewList" value="<%= reviewList %>"/>
<c:set var="amenityList" value="<%= amenityList %>"/>
<c:set var="bookedList" value="<%= bookedList %>"/>

<div class="container">
	<p><a class="muted" href="javascript:history.back()">← 목록으로</a></p>
	<div class="detail">

		<!-- 왼쪽 : 객실 정보 + 리뷰 -->
		<div class="left">
			<img class="main-photo" src="<%= ctx %>/room/photo.jsp?roomId=${room.roomId}" alt="${room.roomType}">
			<div class="room-head">
				<span class="eyebrow">ROOM ${room.roomNo}</span>
				<h1>${room.roomType} <span class="size">${room.roomSize}평 · ${room.roomSizeM2}㎡</span></h1>
				<c:if test="${room.reviewCount == 0}"><span class="new">NEW</span> <span class="muted">아직 리뷰가 없는 객실입니다</span></c:if>
				<c:if test="${room.reviewCount > 0}"><span class="stars">★</span> <b><fmt:formatNumber value="${room.avgRating}" pattern="0.0"/></b> <span class="muted">· 리뷰 ${room.reviewCount}개 · 누적 예약 ${room.resCount}건</span></c:if>
			</div>
			<div class="spec">
				<div>GUESTS<b>기준 ${room.baseGuests}인 / 최대 ${room.capacity}인</b></div>
				<div>BEDS<b>${room.bedCount}개</b></div>
				<div>BREAKFAST<b>${room.breakfast == 1 ? '포함' : '미포함'}</b></div>
				<div>PET<b>${room.pet == 1 ? '동반 가능' : '불가'}</b></div>
			</div>
			<p class="pre"><c:out value="${room.description}"/></p>
			<p style="margin-bottom:40px;">
				<c:forEach var="a" items="${amenityList}"><span class="badge">${a}</span></c:forEach>
			</p>

			<!-- 예약 현황 달력 : 예약된 날은 '마감', 날짜를 누르면 오른쪽 예약 폼에 체크인/체크아웃이 들어간다 -->
			<div class="box">
				<span class="eyebrow">AVAILABILITY</span>
				<h3>예약 현황</h3>
				<p class="muted" style="margin-top:-6px;">체크인 날짜를 누른 뒤 체크아웃 날짜를 누르세요. 줄이 그어진 날은 이미 예약이 찬 날입니다.</p>
				<div class="cal-nav">
					<button type="button" class="btn btn-small btn-line" onclick="moveMonth(-1)">‹ 이전</button>
					<button type="button" class="btn btn-small btn-line" onclick="moveMonth(1)">다음 ›</button>
				</div>
				<div id="calendar" class="calendar"></div>
				<div class="cal-legend"><span class="c-free"></span>예약 가능 <span class="c-booked"></span>예약 마감 <span class="c-sel"></span>선택한 기간</div>
			</div>

			<div class="box">
				<span class="eyebrow">REVIEWS</span>
				<h3>투숙객 리뷰 (${room.reviewCount})</h3>
				<c:if test="${empty reviewList}">
					<p class="muted">아직 작성된 리뷰가 없습니다.</p>
				</c:if>
				<c:forEach var="review" items="${reviewList}">
					<div class="review">
						<div class="head">
							<span class="stars"><c:forEach begin="1" end="${review.rating}">★</c:forEach><c:forEach begin="${review.rating + 1}" end="5">☆</c:forEach></span>
							&nbsp;${review.userId} · <fmt:formatDate value="${review.regDate}" pattern="yyyy-MM-dd"/>
						</div>
						<div class="pre"><c:out value="${review.content}"/></div>
					</div>
				</c:forEach>
				<p class="muted">※ 리뷰는 숙박을 마친 고객만 마이페이지에서 작성할 수 있습니다.</p>
			</div>
		</div>

		<!-- 오른쪽 : 예약 폼 -->
		<div class="right">
			<div class="box reserve-box">
				<span class="eyebrow">RESERVATION</span>
				<div class="price" style="margin-bottom:20px;">
					<c:if test="${room.discountRate > 0}">
						<span class="origin"><fmt:formatNumber value="${room.price}" pattern="#,###"/>원</span>
						<span class="rate">${room.discountRate}%</span><br>
					</c:if>
					<span class="sale"><fmt:formatNumber value="${room.salePrice}" pattern="#,###"/>원</span> <span class="unit">/ 1박 (기준 ${room.baseGuests}인)</span>
					<c:if test="${room.extraPrice > 0 and room.capacity > room.baseGuests}">
						<div class="muted">기준 인원 초과 시 1인당 1박 +<fmt:formatNumber value="${room.extraPrice}" pattern="#,###"/>원</div>
					</c:if>
				</div>

				<form name="rf" action="../reserve/reserve.jsp" method="post" onsubmit="return checkForm(this)">
					<input type="hidden" name="roomId" value="${room.roomId}">
					<div class="dates">
						<p><label>체크인</label><input type="date" name="checkIn" value="${param.checkIn}" onchange="calc(); drawCalendar();"></p>
						<p><label>체크아웃</label><input type="date" name="checkOut" value="${param.checkOut}" onchange="calc(); drawCalendar();"></p>
					</div>
					<p><label>인원 (최대 ${room.capacity}명)</label>
						<input type="number" name="guests" min="1" max="${room.capacity}" value="${empty param.guests ? 1 : param.guests}" onchange="calc()">
					</p>
					<p><label>쿠폰 번호 (선택)</label><input type="text" name="couponCode" placeholder="예) WELCOME10"></p>
					<p><label>결제 방법</label>
						<select name="payMethod">
							<option>현장결제</option>
							<option>계좌이체</option>
							<option>카드결제</option>
						</select>
					</p>
					<div class="estimate" id="estimate">날짜를 선택하면 예상 금액이 표시됩니다.</div>
					<% if (loginId == null) { %>
						<a class="btn btn-gold btn-block" href="<%= ctx %>/member/loginForm.jsp">로그인 후 예약하기</a>
					<% } else { %>
						<input type="submit" class="btn btn-gold btn-block" value="예약하기">
					<% } %>
				</form>
			</div>
		</div>
	</div>
</div>

<script>
	// 이 객실의 예약된 기간들 (서버에서 받은 값을 자바스크립트 배열로)
	//   예) [ {checkIn:"2026-12-24", checkOut:"2026-12-26"}, ... ]  → 24일, 25일 밤이 마감 (26일은 체크아웃 날이라 새 체크인 가능)
	var booked = [
		<c:forEach var="b" items="${bookedList}">{ checkIn: "${b.checkIn}", checkOut: "${b.checkOut}" },</c:forEach>
	];

	// 그 날 밤이 예약돼 있나? (체크인 <= 날짜 < 체크아웃)
	function isBooked(day) {
		for (var i = 0; i < booked.length; i++) {
			if (booked[i].checkIn <= day && day < booked[i].checkOut) return true;
		}
		return false;
	}

	// 체크인 ~ 체크아웃 사이에 예약된 밤이 하루라도 있나? (서버의 중복 예약 검사와 같은 조건)
	function hasBookedBetween(checkIn, checkOut) {
		for (var i = 0; i < booked.length; i++) {
			if (booked[i].checkIn < checkOut && booked[i].checkOut > checkIn) return true;
		}
		return false;
	}

	// 숫자 -> 'yyyy-MM-dd' 문자열 (시간대 문제를 피하려고 직접 만든다)
	function dateStr(y, m, d) {
		return y + "-" + (m < 10 ? "0" + m : m) + "-" + (d < 10 ? "0" + d : d);
	}

	var now = new Date();
	var todayStr = dateStr(now.getFullYear(), now.getMonth() + 1, now.getDate());
	var calYear = now.getFullYear();
	var calMonth = now.getMonth() + 1;   // 1 ~ 12, 달력 왼쪽에 보여줄 달

	// 체크인 날짜가 들어 있으면 그 달부터 보여준다
	if (document.rf.checkIn.value != "") {
		calYear = Number(document.rf.checkIn.value.substring(0, 4));
		calMonth = Number(document.rf.checkIn.value.substring(5, 7));
	}

	// 한 달짜리 달력(HTML 문자열) 만들기
	function monthHtml(y, m) {
		var f = document.rf;
		var html = '<div class="cal-month"><div class="cal-title">' + y + '년 ' + m + '월</div>';
		html += '<div class="cal-grid"><span class="wk">일</span><span class="wk">월</span><span class="wk">화</span><span class="wk">수</span><span class="wk">목</span><span class="wk">금</span><span class="wk">토</span>';
		var firstDay = new Date(y, m - 1, 1).getDay();   // 1일이 무슨 요일인지 (0 = 일요일)
		var lastDate = new Date(y, m, 0).getDate();       // 그 달의 마지막 날
		for (var i = 0; i < firstDay; i++) html += '<span></span>';
		for (var d = 1; d <= lastDate; d++) {
			var day = dateStr(y, m, d);
			var cls = "day";
			if (day < todayStr) cls += " past";
			else if (isBooked(day)) cls += " booked";
			if (day == f.checkIn.value || day == f.checkOut.value) cls += " pick";
			else if (f.checkIn.value != "" && f.checkOut.value != "" && day > f.checkIn.value && day < f.checkOut.value) cls += " sel";
			html += '<button type="button" class="' + cls + '" data-day="' + day + '" onclick="pickDay(this.dataset.day)"'
					+ (day < todayStr ? ' disabled' : '') + '>' + d + '</button>';
		}
		return html + '</div></div>';
	}

	// 지금 달 + 다음 달 두 개를 그린다
	function drawCalendar() {
		var y2 = calMonth == 12 ? calYear + 1 : calYear;
		var m2 = calMonth == 12 ? 1 : calMonth + 1;
		document.getElementById("calendar").innerHTML = monthHtml(calYear, calMonth) + monthHtml(y2, m2);
	}

	function moveMonth(n) {
		calMonth += n;
		if (calMonth < 1)  { calMonth = 12; calYear--; }
		if (calMonth > 12) { calMonth = 1;  calYear++; }
		drawCalendar();
	}

	// 달력에서 날짜를 눌렀을 때 : 첫 번째는 체크인, 두 번째는 체크아웃
	function pickDay(day) {
		var f = document.rf;
		var choosingOut = f.checkIn.value != "" && f.checkOut.value == "" && day > f.checkIn.value;
		if (choosingOut) {
			if (hasBookedBetween(f.checkIn.value, day)) {
				alert("선택한 기간 중에 이미 예약된 날이 있습니다. 다른 날짜를 골라 주세요.");
				return;
			}
			f.checkOut.value = day;
		} else {
			if (isBooked(day)) {
				alert("이미 예약이 찬 날입니다.");
				return;
			}
			f.checkIn.value = day;   // 체크인부터 다시 고르기
			f.checkOut.value = "";
		}
		drawCalendar();
		calc();
	}

	var salePrice = ${room.salePrice};   // 할인 적용된 1박 가격 (서버에서 받아 둔 값)
	var capacity = ${room.capacity};
	var baseGuests = ${room.baseGuests};  // 기준 인원
	var extraPrice = ${room.extraPrice};  // 기준 인원을 넘는 1명당 1박 추가 요금

	// 인원에 따른 1박 요금 (Room.java 의 getNightPrice 와 같은 계산)
	function nightPrice(guests) {
		var extraGuests = guests - baseGuests;
		if (extraGuests < 0) extraGuests = 0;
		return salePrice + extraGuests * extraPrice;
	}

	// 날짜를 고르면 "몇 박 x 가격" 예상 금액을 보여준다 (쿠폰 할인은 예약할 때 서버에서 계산)
	function calc() {
		var f = document.rf;
		if (f.checkIn.value == "" || f.checkOut.value == "") return;
		var nights = (new Date(f.checkOut.value) - new Date(f.checkIn.value)) / (1000 * 60 * 60 * 24);
		var box = document.getElementById("estimate");
		if (nights <= 0) {
			box.innerHTML = "체크아웃은 체크인 다음 날 이후여야 합니다.";
			return;
		}
		if (hasBookedBetween(f.checkIn.value, f.checkOut.value)) {
			box.innerHTML = "<b>SOLD OUT</b><br>선택한 기간에 이미 예약이 있습니다. 달력에서 다른 날짜를 골라 주세요.";
			return;
		}
		var guests = Number(f.guests.value);
		var price = nightPrice(guests);
		var text = nights + "박 × " + price.toLocaleString() + "원";
		if (price > salePrice) {
			text += "<br><span class='muted'>(기본 " + salePrice.toLocaleString() + "원 + 추가 " + (guests - baseGuests)
					+ "명 × " + extraPrice.toLocaleString() + "원)</span>";
		}
		box.innerHTML = text + "<br>예상 금액 <b>" + (nights * price).toLocaleString() + "원</b>";
	}

	function checkForm(f) {
		if (f.checkIn.value == "" || f.checkOut.value == "") {
			alert("체크인과 체크아웃 날짜를 선택하세요.");
			return false;
		}
		if (f.checkIn.value >= f.checkOut.value) {
			alert("체크아웃은 체크인 다음 날 이후여야 합니다.");
			return false;
		}
		if (hasBookedBetween(f.checkIn.value, f.checkOut.value)) {
			alert("선택한 기간에 이미 예약이 있습니다.");
			return false;
		}
		if (f.guests.value < 1 || f.guests.value > capacity) {
			alert("인원은 1명 ~ " + capacity + "명까지 가능합니다.");
			return false;
		}
		return confirm("예약하시겠습니까?");
	}
	calc();   // 목록에서 날짜를 가지고 왔으면 바로 계산
	drawCalendar();
</script>
<%@ include file="/inc/footer.jsp" %>
