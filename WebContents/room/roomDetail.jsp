<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,java.util.*,my.util.*,my.dao.*,my.model.*" %>
<%@ include file="/inc/header.jsp" %>
<%
	int roomId = Integer.parseInt(request.getParameter("roomId"));

	// 한 페이지에서 DAO 두 개를 쓰지만 Connection 은 하나만 열고 마지막에 닫는다
	Connection conn = ConnectionProvider.getConnection();
	Room room = null;
	List<Review> reviewList = null;
	try {
		room = new RoomDao().selectById(conn, roomId);
		reviewList = new ReviewDao().selectByRoom(conn, roomId);
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

<div class="container">
	<p><a class="muted" href="javascript:history.back()">← 목록으로</a></p>
	<div class="detail">

		<!-- 왼쪽 : 객실 정보 + 리뷰 -->
		<div class="left">
			<img class="main-photo" src="<%= ctx %>/room/photo.jsp?roomId=${room.roomId}" alt="${room.roomType}">
			<div class="room-head">
				<span class="eyebrow">ROOM ${room.roomNo}</span>
				<h1>${room.roomType}</h1>
				<c:if test="${room.reviewCount == 0}"><span class="new">NEW</span> <span class="muted">아직 리뷰가 없는 객실입니다</span></c:if>
				<c:if test="${room.reviewCount > 0}"><span class="stars">★</span> <b><fmt:formatNumber value="${room.avgRating}" pattern="0.0"/></b> <span class="muted">· 리뷰 ${room.reviewCount}개 · 누적 예약 ${room.resCount}건</span></c:if>
			</div>
			<div class="spec">
				<div>GUESTS<b>최대 ${room.capacity}인</b></div>
				<div>BEDS<b>${room.bedCount}개</b></div>
				<div>BREAKFAST<b>${room.breakfast == 1 ? '포함' : '미포함'}</b></div>
				<div>PET<b>${room.pet == 1 ? '동반 가능' : '불가'}</b></div>
			</div>
			<p class="pre"><c:out value="${room.description}"/></p>
			<p style="margin-bottom:40px;">
				<c:forEach var="a" items="${amenityList}"><span class="badge">${a}</span></c:forEach>
			</p>

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
					<span class="sale"><fmt:formatNumber value="${room.salePrice}" pattern="#,###"/>원</span> <span class="unit">/ 1박</span>
				</div>

				<form name="rf" action="../reserve/reserve.jsp" method="post" onsubmit="return checkForm(this)">
					<input type="hidden" name="roomId" value="${room.roomId}">
					<div class="dates">
						<p><label>체크인</label><input type="date" name="checkIn" value="${param.checkIn}" onchange="calc()"></p>
						<p><label>체크아웃</label><input type="date" name="checkOut" value="${param.checkOut}" onchange="calc()"></p>
					</div>
					<p><label>인원 (최대 ${room.capacity}명)</label>
						<input type="number" name="guests" min="1" max="${room.capacity}" value="${empty param.guests ? 1 : param.guests}">
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
	var salePrice = ${room.salePrice};   // 할인 적용된 1박 가격 (서버에서 받아 둔 값)
	var capacity = ${room.capacity};

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
		box.innerHTML = nights + "박 × " + salePrice.toLocaleString() + "원<br>예상 금액 <b>"
				+ (nights * salePrice).toLocaleString() + "원</b>";
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
		if (f.guests.value < 1 || f.guests.value > capacity) {
			alert("인원은 1명 ~ " + capacity + "명까지 가능합니다.");
			return false;
		}
		return confirm("예약하시겠습니까?");
	}
	calc();   // 목록에서 날짜를 가지고 왔으면 바로 계산
</script>
<%@ include file="/inc/footer.jsp" %>
