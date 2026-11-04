<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,java.time.*,java.time.temporal.ChronoUnit,my.util.*,my.dao.*,my.model.*" %>
<%@ include file="/inc/loginCheck.jsp" %>
<%--
	예약 처리 (roomDetail.jsp 의 예약 폼에서 넘어옴)
	순서 : ① 값 받기 → ② 날짜/인원 검사 → ③ 중복 예약 검사 → ④ 쿠폰 확인
	      → ⑤ 금액 계산 → ⑥ 저장 + 객실 예약 수 +1 → 마이페이지로 이동
--%>
<%
	request.setCharacterEncoding("utf-8");

	// ① 값 받기
	String loginId = (String) session.getAttribute("LOGIN");
	int roomId = Integer.parseInt(request.getParameter("roomId"));
	String checkIn = request.getParameter("checkIn");
	String checkOut = request.getParameter("checkOut");
	int guests = Integer.parseInt(request.getParameter("guests"));
	String couponCode = request.getParameter("couponCode").trim().toUpperCase();
	String payMethod = request.getParameter("payMethod");

	String error = null;    // 문제가 생기면 여기에 메시지를 담는다
	Connection conn = ConnectionProvider.getConnection();
	try {
		RoomDao roomDao = new RoomDao();
		ReservationDao resDao = new ReservationDao();
		Room room = roomDao.selectById(conn, roomId);

		// ② 날짜 / 인원 검사
		LocalDate inDate = LocalDate.parse(checkIn);
		LocalDate outDate = LocalDate.parse(checkOut);
		long nights = ChronoUnit.DAYS.between(inDate, outDate);   // 몇 박인지

		if (room == null) {
			error = "없는 객실입니다.";
		} else if (inDate.isBefore(LocalDate.now())) {
			error = "지난 날짜는 예약할 수 없습니다.";
		} else if (nights < 1) {
			error = "체크아웃은 체크인 다음 날 이후여야 합니다.";
		} else if (guests < 1 || guests > room.getCapacity()) {
			error = "이 객실은 최대 " + room.getCapacity() + "명까지 이용할 수 있습니다.";
		}
		// ③ 중복 예약 검사 : 같은 기간에 이미 예약이 있으면 막는다
		else if (resDao.countOverlap(conn, roomId, checkIn, checkOut) > 0) {
			error = "선택한 기간에 이미 예약이 있습니다. 다른 날짜를 선택해 주세요.";
		}

		// ④ 쿠폰 확인 (입력한 경우에만)
		Coupon coupon = null;
		if (error == null && !couponCode.equals("")) {
			coupon = new CouponDao().selectValid(conn, couponCode);
			if (coupon == null) {
				error = "사용할 수 없는 쿠폰입니다. (번호 오류 또는 사용 기간 아님)";
			}
		}

		if (error == null) {
			// ⑤ 금액 계산 : (객실 할인가 x 박 수) 에서 쿠폰 할인율만큼 빼기
			int total = room.getSalePrice() * (int) nights;
			if (coupon != null) {
				total = total * (100 - coupon.getDiscountRate()) / 100;
			}

			// ⑥ 저장
			Reservation res = new Reservation();
			res.setUserId(loginId);
			res.setRoomId(roomId);
			res.setRoomType(room.getRoomType());   // 객실 이름도 예약에 같이 저장
			res.setRoomNo(room.getRoomNo());
			res.setCheckIn(checkIn);
			res.setCheckOut(checkOut);
			res.setGuests(guests);
			res.setTotalPrice(total);
			res.setCouponCode(coupon == null ? null : coupon.getCouponCode());
			res.setPayMethod(payMethod);
			resDao.insert(conn, res);
			roomDao.updateResCount(conn, roomId, 1);   // 객실 예약 수 +1 (인기순 정렬용)
%>
			<script>
				alert("예약이 완료되었습니다.\n<%= room.getRoomType() %> / <%= checkIn %> ~ <%= checkOut %> (<%= nights %>박)\n결제 금액 : <%= String.format("%,d", total) %>원");
				location.href = "../mypage/myPage.jsp";
			</script>
<%
		}
	} finally {
		JdbcUtil.close(conn);
	}

	if (error != null) {
%>
		<script>
			alert("<%= error %>");
			history.go(-1);
		</script>
<%
	}
%>
