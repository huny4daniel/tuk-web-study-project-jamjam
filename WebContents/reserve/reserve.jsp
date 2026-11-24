<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,my.util.*,my.dao.*,my.model.*" %>
<%@ include file="/inc/loginCheck.jsp" %>
<% request.setCharacterEncoding("utf-8"); %>
<%@ include file="/inc/reserveCheck.jsp" %>
<%--
	예약 처리 (결제 화면 payForm.jsp 에서 [결제하기] 를 누르면 넘어옴)
	순서 : ① 검사 + 금액 계산 (inc/reserveCheck.jsp 를 한 번 더 실행 → 화면을 거치지 않고 들어와도 막힘)
	      → ② 동의 확인 → ③ 결제 상세 글 만들기 → ④ 저장 + 객실 예약 수 +1 → 예약 확인서로 이동
--%>
<%
	String loginId = (String) session.getAttribute("LOGIN");
	String payMethod = request.getParameter("payMethod");
	String error = checkError;

	// ② 취소 규정 동의
	if (error == null && !"1".equals(request.getParameter("agree"))) {
		error = "취소 규정을 확인하고 결제에 동의해 주세요.";
	}

	// ③ 결제 방법에 따라 확인서에 보여줄 결제 상세 (정해진 3가지만 허용)
	String payDetail = null;
	if ("카드결제".equals(payMethod)) {
		String cardIdStr = request.getParameter("cardId");
		if (cardIdStr == null || cardIdStr.equals("")) {
			// 다른 카드(직접 입력) : 카드 번호는 끝 4자리만 넘어온다
			String newLast4 = request.getParameter("newLast4");
			if (newLast4 != null && newLast4.matches("[0-9]{4}")) {
				payDetail = request.getParameter("cardCompany") + " ****" + newLast4 + " / " + request.getParameter("installment");
			} else if (error == null) {
				error = "카드 번호를 입력해 주세요.";
			}
		} else {
			// 등록 카드 : 폼에서는 번호만 받고, 본인 카드인지 DB 에서 확인한 뒤 카드사·끝 4자리를 가져온다
			PayCard payCard = null;
			Connection cardConn = ConnectionProvider.getConnection();
			try {
				payCard = new PayCardDao().selectMine(cardConn, Integer.parseInt(cardIdStr), loginId);
			} finally {
				JdbcUtil.close(cardConn);
			}
			if (payCard != null) {
				payDetail = payCard.getLabel() + " / " + request.getParameter("installment");
			} else if (error == null) {
				error = "등록된 카드를 찾을 수 없습니다. 카드를 다시 선택해 주세요.";
			}
		}
	} else if ("계좌이체".equals(payMethod)) {
		payDetail = "입금자 " + request.getParameter("depositor") + " · 잠잠은행 000-0000-0000";
	} else if ("현장결제".equals(payMethod)) {
		payDetail = "체크인 시 프런트에서 결제";
	} else if (error == null) {
		error = "결제 방법을 선택해 주세요.";
	}

	// 투숙객 이름·연락처 (비어 있으면 안 됨)
	String guestName = request.getParameter("guestName") == null ? "" : request.getParameter("guestName").trim();
	String guestPhone = request.getParameter("guestPhone") == null ? "" : request.getParameter("guestPhone").trim();
	if (error == null && (guestName.equals("") || guestPhone.equals(""))) {
		error = "투숙객 이름과 연락처를 입력해 주세요.";
	}
	if (guestName.length() > 50) guestName = guestName.substring(0, 50);
	if (guestPhone.length() > 20) guestPhone = guestPhone.substring(0, 20);

	int newResId = 0;
	if (error == null) {
		// ④ 저장
		Reservation res = new Reservation();
		res.setUserId(loginId);
		res.setRoomId(roomId);
		res.setRoomType(room.getRoomType());   // 객실 이름도 예약에 같이 저장
		res.setRoomNo(room.getRoomNo());
		res.setCheckIn(checkIn);
		res.setCheckOut(checkOut);
		res.setGuests(guests);
		res.setTotalPrice(payTotal);
		res.setCouponCode(coupon == null ? null : coupon.getCouponCode());
		res.setPayMethod(payMethod);
		res.setPayDetail(payDetail);
		// 요청사항 : 비어 있으면 null 로 저장 (화면에서 "요청사항 없음" 판단이 쉽게)
		String requestNote = request.getParameter("requestNote");
		if (requestNote != null && requestNote.trim().length() > 500) {
			requestNote = requestNote.trim().substring(0, 500);
		}
		res.setRequestNote(requestNote == null || requestNote.trim().equals("") ? null : requestNote.trim());
		res.setGuestName(guestName);
		res.setGuestPhone(guestPhone);

		Connection conn = ConnectionProvider.getConnection();
		try {
			ReservationDao resDao = new ReservationDao();
			resDao.insert(conn, res);
			new RoomDao().updateResCount(conn, roomId, 1);   // 객실 예약 수 +1 (인기순 정렬용)
			newResId = resDao.selectLatestByUser(conn, loginId).getResId();   // 방금 저장한 예약 번호
			if (coupon != null) {
				new MemberCouponDao().markUsed(conn, coupon.getMcId(), newResId);   // 쿠폰함의 쿠폰을 사용 완료로
			}
			// [이 투숙객 저장] 을 체크했으면 마이페이지 투숙객 목록에 추가 (이미 있거나 10명이 차면 건너뜀)
			GuestDao guestDao = new GuestDao();
			if ("1".equals(request.getParameter("saveGuest")) && !guestDao.exists(conn, loginId, guestName, guestPhone)
					&& guestDao.selectByUser(conn, loginId).size() < 10) {
				Guest guest = new Guest();
				guest.setUserId(loginId);
				guest.setName(guestName);
				guest.setPhone(guestPhone);
				guest.setRelation("기타");
				guestDao.insert(conn, guest);
			}
		} finally {
			JdbcUtil.close(conn);
		}
		// 예약 확인서로 (done=1 이면 "예약이 완료되었습니다" 문구를 같이 보여줌)
		response.sendRedirect("resDetail.jsp?resId=" + newResId + "&done=1");
		return;
	}
%>
<script>
	alert("<%= error %>");
	history.go(-1);
</script>
