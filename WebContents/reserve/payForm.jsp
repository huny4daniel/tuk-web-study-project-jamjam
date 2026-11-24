<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,java.util.*,my.util.*,my.dao.*,my.model.*" %>
<%@ include file="/inc/loginCheck.jsp" %>
<%@ include file="/inc/header.jsp" %>
<%@ include file="/inc/reserveCheck.jsp" %>
<%--
	결제 상세 화면 (객실 상세의 [예약하기] → 여기 → [결제하기] → reserve.jsp)
	검사와 금액 계산은 inc/reserveCheck.jsp 에서 하고, 여기서는 결과를 보여주기만 한다.
	쿠폰은 쿠폰함(디지털 쿠폰)에서 고른다 : 고르면 같은 주소에 mcId 를 붙여서 다시 여는 방식 (GET) → 금액은 서버에서 다시 계산
	※ 실제 결제사(PG) 연동이 없는 모의 결제 : 카드번호는 화면에서만 확인하고 끝 4자리만 서버로 보낸다.
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
	List<Guest> guestList = null;   // 마이페이지에 등록해 둔 투숙객
	List<PayCard> cardList = null;  // 마이페이지에 등록해 둔 결제수단 (기본 카드가 맨 위)
	Connection conn = ConnectionProvider.getConnection();
	try {
		member = new MemberDao().selectById(conn, loginId);
		guestList = new GuestDao().selectByUser(conn, loginId);
		cardList = new PayCardDao().selectByUser(conn, loginId);
	} finally {
		JdbcUtil.close(conn);
	}
%>
<c:set var="room" value="<%= room %>"/>
<c:set var="member" value="<%= member %>"/>
<c:set var="guestList" value="<%= guestList %>"/>
<c:set var="cardList" value="<%= cardList %>"/>
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
				<!-- 카드 없이 묶음(group)으로 나눈다 : ① 예약 내용 ② 투숙 정보(예약자·투숙객·요청사항) ③ 결제 방법 + 동의 -->
				<section class="group">
					<div class="group-head"><h3>예약 내용</h3></div>
					<div class="pay-room">
						<img src="<%= ctx %>/room/photo.jsp?roomId=${room.roomId}" alt="${room.roomType}">
						<div>
							<span class="eyebrow">ROOM ${room.roomNo}</span>
							<div class="name">${room.roomType} <span class="size">${room.roomSize}평</span></div>
							<div class="muted">${room.breakfast == 1 ? '조식 포함' : '조식 미포함'} · ${room.bedLabel}</div>
						</div>
					</div>
					<div class="stay">
						<div>체크인<b>${param.checkIn}</b>15:00 부터</div>
						<div>체크아웃<b>${param.checkOut}</b>11:00 까지</div>
						<div>숙박<b>${nights}박</b>&nbsp;</div>
						<div>인원<b>${param.guests}명</b>기준 ${room.baseGuests}명 / 최대 ${room.capacity}명</div>
					</div>
				</section>

				<section class="group">
					<div class="group-head"><h3>투숙 정보</h3></div>

					<h4 class="sub-title">예약자</h4>
					<p class="who-line"><b><c:out value="${member.name}"/></b> · <c:out value="${member.phone}"/> · <c:out value="${member.email}"/></p>
					<p class="muted" style="margin-top:0;">정보가 다르면 <a href="<%= ctx %>/member/memberUpdateForm.jsp"><b>회원 정보 수정</b></a>에서 바꿀 수 있습니다.</p>

					<!-- 투숙객 정보 : 본인 또는 마이페이지에 등록해 둔 투숙객을 고르면 이름·연락처가 채워진다 -->
					<h4 class="sub-title">투숙객</h4>
					<div class="chips" id="guestPick">
						<button type="button" class="on" data-name="<c:out value='${member.name}'/>" data-phone="<c:out value='${member.phone}'/>" onclick="pickGuest(this)">본인</button>
						<c:forEach var="g" items="${guestList}">
							<button type="button" data-name="<c:out value='${g.name}'/>" data-phone="<c:out value='${g.phone}'/>" onclick="pickGuest(this)"><c:out value="${g.name}"/> (${g.relation})</button>
						</c:forEach>
						<button type="button" data-name="" data-phone="" onclick="pickGuest(this)">직접 입력</button>
					</div>
					<p><label>투숙객 이름</label><input type="text" name="guestName" maxlength="50" value="<c:out value='${member.name}'/>"></p>
					<p><label>투숙객 연락처</label><input type="text" name="guestPhone" maxlength="20" value="<c:out value='${member.phone}'/>"></p>
					<p id="saveGuestRow" style="display:none;"><label><input type="checkbox" name="saveGuest" value="1"> 이 투숙객을 마이페이지에 저장해서 다음에도 불러오기</label></p>
					<p class="muted">투숙객 목록은 <a href="<%= ctx %>/mypage/guest.jsp"><b>마이페이지 &gt; 투숙객</b></a>에서 관리합니다.</p>

					<!-- 고객 요청사항 : 자주 쓰는 요청 버튼을 누르면 글이 덧붙고, 직접 써도 됨 -->
					<h4 class="sub-title">요청사항 <span class="muted">(선택)</span></h4>
					<div class="chips">
						<button type="button" onclick="addRequest(this)">높은 층 희망</button>
						<button type="button" onclick="addRequest(this)">조용한 객실 희망</button>
						<button type="button" onclick="addRequest(this)">늦은 체크인 (21시 이후)</button>
						<button type="button" onclick="addRequest(this)">얼리 체크인 희망</button>
						<button type="button" onclick="addRequest(this)">아기 침대 요청</button>
						<button type="button" onclick="addRequest(this)">기념일 (케이크 문의)</button>
					</div>
					<textarea name="requestNote" maxlength="500" placeholder="호텔에 전달할 내용을 적어 주세요. 요청사항은 객실 사정에 따라 제공되지 않을 수 있습니다."></textarea>
				</section>

				<section class="group">
					<div class="group-head"><h3>결제 방법</h3></div>
					<div class="pay-methods">
						<label><input type="radio" name="payMethod" value="카드결제" checked onclick="showPay()"> 카드결제</label>
						<label><input type="radio" name="payMethod" value="계좌이체" onclick="showPay()"> 계좌이체</label>
						<label><input type="radio" name="payMethod" value="현장결제" onclick="showPay()"> 현장결제</label>
					</div>
					<div class="pay-detail" id="pay-카드결제">
						<!-- 등록 카드 : 고르면 카드사·카드 번호 칸은 숨긴다. [다른 카드]면 cardId 가 비고 카드사와 번호를 직접 넣는다. 별칭은 () 안에 (따로 안 정했으면 생략) -->
						<c:if test="${not empty cardList}">
							<p>
								<label>등록 카드</label>
								<select name="cardId" onchange="showCard()">
									<c:forEach var="pc" items="${cardList}">
										<option value="${pc.cardId}"><c:out value="${pc.label}"/><c:if test="${pc.cardName != pc.cardCompany}"> (<c:out value="${pc.cardName}"/>)</c:if></option>
									</c:forEach>
									<option value="">다른 카드</option>
								</select>
							</p>
						</c:if>
						<p id="cardCompanyRow">
							<label>카드사</label>
							<select name="cardCompany">
								<option>신한카드</option><option>국민카드</option><option>삼성카드</option>
								<option>현대카드</option><option>롯데카드</option><option>하나카드</option><option>우리카드</option><option>BC카드</option>
							</select>
						</p>
						<!-- 카드 번호 칸은 name 이 없어서 서버로 가지 않는다. 끝 4자리만 newLast4 에 담아 보낸다 -->
						<p id="cardNoRow">
							<label>카드 번호</label>
							<input type="text" id="cardNo" maxlength="19" placeholder="0000-0000-0000-0000" inputmode="numeric" autocomplete="off" oninput="formatCardNo(this)">
							<input type="hidden" name="newLast4">
						</p>
						<p>
							<label>할부</label>
							<select name="installment">
								<option>일시불</option><option>2개월</option><option>3개월</option><option>6개월</option>
							</select>
						</p>
						<p class="muted"><a href="<%= ctx %>/mypage/card.jsp"><b>마이페이지 &gt; 결제수단</b></a></p>
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

					<h4 class="sub-title">취소 규정</h4>
					<p class="muted" style="margin-top:0;">
						체크인 날짜 전까지는 마이페이지에서 무료로 취소할 수 있습니다.<br>
						체크인 당일부터는 온라인 취소가 불가능하며 호텔로 문의해 주세요.
					</p>
					<div class="agree">
						<label><input type="checkbox" name="agree" value="1"> 예약 내용과 취소 규정을 확인했으며, 결제에 동의합니다. (필수)</label>
					</div>
				</section>
			</div>

			<!-- 오른쪽 : 금액 내역 (스크롤해도 따라옴) -->
			<div>
				<div class="box box-key pay-sum">
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

					<input type="submit" id="payBtn" class="btn btn-gold btn-block" value="<fmt:formatNumber value='${payTotal}' pattern='#,###'/>원 결제하기">
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

	// 등록 카드를 골랐으면 카드사·카드 번호 칸을 숨긴다 (등록 카드가 없으면 cardId 칸 자체가 없음)
	function showCard() {
		var sel = document.pf.cardId;
		var show = (sel && sel.value != "") ? "none" : "";
		document.getElementById("cardCompanyRow").style.display = show;
		document.getElementById("cardNoRow").style.display = show;
	}

	// 카드 번호 : 숫자만 남기고 4자리마다 - 를 넣는다
	function formatCardNo(box) {
		box.value = box.value.replace(/[^0-9]/g, "").substring(0, 16).replace(/(\d{4})(?=\d)/g, "$1-");
	}

	// 고른 쿠폰 번호(mcId)를 붙여서 이 화면을 다시 연다 (금액은 서버에서 다시 계산)
	function applyCoupon(mcId) {
		var f = document.pf;
		location.href = "payForm.jsp?roomId=" + f.roomId.value + "&checkIn=" + f.checkIn.value + "&checkOut=" + f.checkOut.value
				+ "&guests=" + f.guests.value + "&mcId=" + mcId;
	}

	// 투숙객 고르기 : 버튼에 담아 둔 이름·연락처를 입력칸에 채운다. [직접 입력]이면 비우고 저장 체크 칸을 보여줌
	function pickGuest(btn) {
		var f = document.pf;
		var buttons = document.querySelectorAll("#guestPick button");
		for (var i = 0; i < buttons.length; i++) buttons[i].className = "";
		btn.className = "on";
		f.guestName.value = btn.dataset.name;
		f.guestPhone.value = btn.dataset.phone;
		document.getElementById("saveGuestRow").style.display = (btn.dataset.name == "") ? "" : "none";
		if (btn.dataset.name == "") f.guestName.focus();
	}

	// 요청사항 버튼 : 이미 들어 있지 않으면 글 끝에 덧붙인다
	function addRequest(btn) {
		var box = document.pf.requestNote;
		var text = btn.textContent;
		if (box.value.indexOf(text) >= 0) return;
		box.value = box.value.trim() == "" ? text : box.value.trim() + ", " + text;
		btn.className = "on";
	}

	// 결제 버튼 잠그기 / 풀기 (더블클릭으로 두 번 제출되는 것을 막음)
	function lockPay(lock) {
		document.getElementById("payBtn").disabled = lock;
	}

	// [결제하기] : 입력 검사 → 확인창 → 버튼 잠그고 제출
	function checkPay(f) {
		if (!f.agree.checked) {
			alert("취소 규정을 확인하고 결제에 동의해 주세요.");
			return false;
		}
		if (f.guestName.value.trim() == "" || f.guestPhone.value.trim() == "") {
			alert("투숙객 이름과 연락처를 입력해 주세요.");
			return false;
		}
		if (f.payMethod.value == "계좌이체" && f.depositor.value.trim() == "") {
			alert("입금자명을 입력해 주세요.");
			return false;
		}
		// 다른 카드(직접 입력)로 결제할 때만 카드 번호를 확인하고 끝 4자리만 보낸다
		f.newLast4.value = "";
		if (f.payMethod.value == "카드결제" && !(f.cardId && f.cardId.value != "")) {
			var no = document.getElementById("cardNo").value.replace(/-/g, "");
			if (!/^[0-9]{15,16}$/.test(no)) {
				alert("카드 번호 15~16자리를 입력해 주세요.");
				return false;
			}
			f.newLast4.value = no.substring(no.length - 4);
		}
		if (!confirm("결제하시겠습니까?")) return false;
		lockPay(true);
		return true;
	}

	// 뒤로 가기로 돌아오면 (오류 안내 후 history.go(-1) 포함) 버튼을 풀고, 남아 있는 선택에 맞게 칸을 다시 보여줌
	window.addEventListener("pageshow", function () {
		lockPay(false);
		showPay();
		showCard();
	});
</script>
<%@ include file="/inc/footer.jsp" %>
