<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,java.util.*,my.util.*,my.dao.*,my.model.*" %>
<%@ include file="/inc/loginCheck.jsp" %>
<%@ include file="/inc/header.jsp" %>
<%@ include file="/inc/reserveCheck.jsp" %>
<%--
	결제 상세 화면 (객실 상세의 [예약하기] → 여기 → [결제하기] → reserve.jsp)
	검사와 금액 계산은 inc/reserveCheck.jsp 에서 하고, 여기서는 결과를 보여주기만 한다.
	쿠폰은 쿠폰함(디지털 쿠폰)에서 고른다 : 고르면 같은 주소에 mcId 를 붙여서 다시 여는 방식 (GET) → 금액은 서버에서 다시 계산
	※ 실제 결제사(PG) 연동이 없는 모의 결제 : 카드번호 같은 정보는 받지 않는다.
--%>
<%
	if (checkError != null) {
%>
		<script>
			alert("<%= checkError %>");
			history.go(-1);
		</script>
<%
		return;
	}

	// 예약자 정보 (로그인한 회원)
	Member member = null;
	Connection conn = ConnectionProvider.getConnection();
	try {
		member = new MemberDao().selectById(conn, loginId);
	} finally {
		JdbcUtil.close(conn);
	}
%>
<c:set var="room" value="<%= room %>"/>
<c:set var="member" value="<%= member %>"/>
<c:set var="coupon" value="<%= coupon %>"/>
<c:set var="usableCoupons" value="<%= usableCoupons %>"/>
<c:set var="nights" value="<%= nights %>"/>
<c:set var="nightPrice" value="<%= nightPrice %>"/>
<c:set var="roomTotal" value="<%= roomTotal %>"/>
<c:set var="couponDiscount" value="<%= couponDiscount %>"/>
<c:set var="payTotal" value="<%= payTotal %>"/>
<c:set var="extraGuests" value="<%= guests - room.getBaseGuests() %>"/>

<div class="container">
	<p><a class="muted" href="<%= ctx %>/room/roomDetail.jsp?roomId=${room.roomId}&checkIn=${param.checkIn}&checkOut=${param.checkOut}&guests=${param.guests}">← 객실로 돌아가기</a></p>
	<span class="eyebrow">CHECKOUT</span>
	<h2 class="page-title">예약 · 결제</h2>
	<p class="page-sub">예약 내용과 금액을 확인하고 결제 방법을 선택해 주세요.</p>

	<form name="pf" action="reserve.jsp" method="post" onsubmit="return checkPay(this)">
		<input type="hidden" name="roomId" value="${room.roomId}">
		<input type="hidden" name="checkIn" value="${param.checkIn}">
		<input type="hidden" name="checkOut" value="${param.checkOut}">
		<input type="hidden" name="guests" value="${param.guests}">
		<input type="hidden" name="mcId" value="${coupon.mcId}">

		<div class="pay-layout">
			<!-- 왼쪽 : 예약 내용, 예약자, 결제 수단, 동의 -->
			<div>
				<div class="box">
					<h3>예약 내용</h3>
					<div class="pay-room">
						<img src="<%= ctx %>/room/photo.jsp?roomId=${room.roomId}" alt="${room.roomType}">
						<div>
							<span class="eyebrow">ROOM ${room.roomNo}</span>
							<div class="name">${room.roomType} <span class="size">${room.roomSize}평</span></div>
							<div class="muted">${room.breakfast == 1 ? '조식 포함' : '조식 미포함'} · ${room.bedLabel}</div>
						</div>
					</div>
					<table class="form">
						<tr><th>체크인</th><td>${param.checkIn} <span class="muted">15:00 부터</span></td></tr>
						<tr><th>체크아웃</th><td>${param.checkOut} <span class="muted">11:00 까지</span></td></tr>
						<tr><th>숙박</th><td>${nights}박</td></tr>
						<tr><th>인원</th><td>${param.guests}명 <span class="muted">(기준 ${room.baseGuests}명 / 최대 ${room.capacity}명)</span></td></tr>
					</table>
				</div>

				<div class="box">
					<h3>예약자 정보</h3>
					<table class="form">
						<tr><th>이름</th><td><c:out value="${member.name}"/></td></tr>
						<tr><th>연락처</th><td><c:out value="${member.phone}"/></td></tr>
						<tr><th>이메일</th><td><c:out value="${member.email}"/></td></tr>
					</table>
					<p class="muted">정보가 다르면 <a href="<%= ctx %>/member/memberUpdateForm.jsp"><b>회원 정보 수정</b></a>에서 바꿀 수 있습니다.</p>
				</div>

				<!-- 고객 요청사항 : 자주 쓰는 요청 버튼을 누르면 글이 덧붙고, 직접 써도 됨 -->
				<div class="box">
					<h3>요청사항 <span class="muted">(선택)</span></h3>
					<div class="chips">
						<button type="button" onclick="addRequest(this)">높은 층 희망</button>
						<button type="button" onclick="addRequest(this)">조용한 객실 희망</button>
						<button type="button" onclick="addRequest(this)">늦은 체크인 (21시 이후)</button>
						<button type="button" onclick="addRequest(this)">얼리 체크인 희망</button>
						<button type="button" onclick="addRequest(this)">아기 침대 요청</button>
						<button type="button" onclick="addRequest(this)">기념일 (케이크 문의)</button>
					</div>
					<textarea name="requestNote" maxlength="500" placeholder="호텔에 전달할 내용을 적어 주세요. 요청사항은 객실 사정에 따라 제공되지 않을 수 있습니다."></textarea>
				</div>

				<div class="box">
					<h3>결제 방법</h3>
					<div class="pay-methods">
						<label><input type="radio" name="payMethod" value="카드결제" checked onclick="showPay()"> 카드결제</label>
						<label><input type="radio" name="payMethod" value="계좌이체" onclick="showPay()"> 계좌이체</label>
						<label><input type="radio" name="payMethod" value="현장결제" onclick="showPay()"> 현장결제</label>
					</div>
					<div class="pay-detail" id="pay-카드결제">
						<p>
							<label>카드사</label>
							<select name="cardCompany">
								<option>신한카드</option><option>국민카드</option><option>삼성카드</option>
								<option>현대카드</option><option>롯데카드</option><option>하나카드</option><option>우리카드</option><option>BC카드</option>
							</select>
						</p>
						<p>
							<label>할부</label>
							<select name="installment">
								<option>일시불</option><option>2개월</option><option>3개월</option><option>6개월</option>
							</select>
						</p>
						<p class="muted">※ 수업용 모의 결제입니다. 실제 카드 결제는 이루어지지 않습니다.</p>
					</div>
					<div class="pay-detail" id="pay-계좌이체" style="display:none;">
						<p>입금 계좌 : <b>잠잠은행 000-0000-0000</b> (예금주 호텔잠잠)</p>
						<p><label>입금자명</label><input type="text" name="depositor" value="<c:out value='${member.name}'/>"></p>
						<p class="muted">※ 체크인 전날까지 입금해 주세요.</p>
					</div>
					<div class="pay-detail" id="pay-현장결제" style="display:none;">
						<p>체크인할 때 프런트에서 카드 또는 현금으로 결제합니다.</p>
					</div>
				</div>

				<div class="box">
					<h3>취소 규정</h3>
					<p class="muted" style="margin-top:0;">
						체크인 날짜 전까지는 마이페이지에서 무료로 취소할 수 있습니다.<br>
						체크인 당일부터는 온라인 취소가 불가능하며 호텔로 문의해 주세요.
					</p>
					<label><input type="checkbox" name="agree" value="1"> 예약 내용과 취소 규정을 확인했으며, 결제에 동의합니다. (필수)</label>
				</div>
			</div>

			<!-- 오른쪽 : 금액 내역 (스크롤해도 따라옴) -->
			<div>
				<div class="box pay-sum">
					<span class="eyebrow">PAYMENT</span>
					<table class="sum">
						<tr><td>객실 1박 요금</td><td><fmt:formatNumber value="${room.salePrice}" pattern="#,###"/>원</td></tr>
						<c:if test="${room.discountRate > 0}">
							<tr><td class="muted" colspan="2">정가 <fmt:formatNumber value="${room.price}" pattern="#,###"/>원에서 ${room.discountRate}% 할인</td></tr>
						</c:if>
						<c:if test="${extraGuests > 0}">
							<tr><td>인원 추가 (${extraGuests}명)</td><td>+<fmt:formatNumber value="${extraGuests * room.extraPrice}" pattern="#,###"/>원</td></tr>
						</c:if>
						<tr><td>1박 × ${nights}박</td><td><fmt:formatNumber value="${roomTotal}" pattern="#,###"/>원</td></tr>
						<c:if test="${coupon != null}">
							<tr class="minus"><td>쿠폰 할인 (${coupon.discountRate}%)<br><span class="muted"><c:out value="${coupon.couponName}"/></span></td><td>−<fmt:formatNumber value="${couponDiscount}" pattern="#,###"/>원</td></tr>
						</c:if>
						<tr class="total"><td>총 결제 금액</td><td><fmt:formatNumber value="${payTotal}" pattern="#,###"/>원</td></tr>
					</table>

					<!-- 쿠폰 고르기 : 내 쿠폰함에서 지금 쓸 수 있는 쿠폰만 나온다. 고르면 같은 화면을 다시 열어 금액 계산 -->
					<label class="muted">쿠폰 (내 쿠폰함 ${usableCoupons.size()}장)</label>
					<select id="couponSelect" class="coupon-select" onchange="applyCoupon(this.value)">
						<option value="">쿠폰 사용 안 함</option>
						<c:forEach var="mc" items="${usableCoupons}">
							<option value="${mc.mcId}" ${mc.mcId == coupon.mcId ? 'selected' : ''}><c:out value="${mc.couponName}"/> (${mc.discountRate}%, ~${mc.endDate})</option>
						</c:forEach>
					</select>
					<p class="muted" style="margin-top:6px;"><a href="<%= ctx %>/mypage/coupon.jsp">쿠폰함에서 쿠폰 받기 →</a></p>

					<input type="submit" class="btn btn-gold btn-block" value="<fmt:formatNumber value='${payTotal}' pattern='#,###'/>원 결제하기">
				</div>
			</div>
		</div>
	</form>
</div>

<script>
	// 고른 결제 방법의 입력 칸만 보이기
	function showPay() {
		var radios = document.pf.payMethod;
		for (var i = 0; i < radios.length; i++) {
			document.getElementById("pay-" + radios[i].value).style.display = radios[i].checked ? "" : "none";
		}
	}

	// 고른 쿠폰 번호(mcId)를 붙여서 이 화면을 다시 연다 (금액은 서버에서 다시 계산)
	function applyCoupon(mcId) {
		var f = document.pf;
		location.href = "payForm.jsp?roomId=" + f.roomId.value + "&checkIn=" + f.checkIn.value + "&checkOut=" + f.checkOut.value
				+ "&guests=" + f.guests.value + "&mcId=" + mcId;
	}

	// 요청사항 버튼 : 이미 들어 있지 않으면 글 끝에 덧붙인다
	function addRequest(btn) {
		var box = document.pf.requestNote;
		var text = btn.textContent;
		if (box.value.indexOf(text) >= 0) return;
		box.value = box.value.trim() == "" ? text : box.value.trim() + ", " + text;
		btn.className = "on";
	}

	function checkPay(f) {
		if (!f.agree.checked) {
			alert("취소 규정을 확인하고 결제에 동의해 주세요.");
			return false;
		}
		if (f.payMethod.value == "계좌이체" && f.depositor.value.trim() == "") {
			alert("입금자명을 입력해 주세요.");
			return false;
		}
		return confirm("결제하시겠습니까?");
	}
</script>
<%@ include file="/inc/footer.jsp" %>
