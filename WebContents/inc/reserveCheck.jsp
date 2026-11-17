<%@ page pageEncoding="UTF-8" %>
<%@ page import="java.sql.*,java.time.*,java.time.temporal.ChronoUnit,my.util.*,my.dao.*,my.model.*" %>
<%--
	예약 검사 + 금액 계산 조각 (결제 화면 reserve/payForm.jsp 와 예약 처리 reserve/reserve.jsp 에서 같이 include)
	결제 화면에서 보여준 금액과 실제로 저장되는 금액이 항상 같도록 한 곳에서 계산한다.
	화면에서 이미 검사했어도 처리 페이지에서 한 번 더 검사하기 위해 두 곳 모두에서 include 한다.

	이 조각이 만드는 변수 (include 한 페이지에서 바로 쓸 수 있음, 같은 이름의 변수를 또 만들면 안 됨)
	  roomId, checkIn, checkOut, guests, mcId  : 폼에서 받은 값 (mcId : 고른 쿠폰함 쿠폰 번호, 안 골랐으면 0)
	  room        : 객실 정보
	  nights      : 몇 박
	  nightPrice  : 인원에 따른 1박 요금 (Room.getNightPrice)
	  roomTotal   : 1박 요금 x 박 수 (쿠폰 적용 전)
	  coupon      : 적용한 쿠폰함 쿠폰 MemberCoupon (없으면 null)
	  usableCoupons : 이 회원이 지금 쓸 수 있는 쿠폰 목록 (결제 화면 선택 칸용)
	  payTotal    : 최종 결제 금액 = roomTotal x (100 - 쿠폰 할인율) / 100
	  couponDiscount : 쿠폰으로 깎인 금액 (roomTotal - payTotal)
	  checkError  : 문제가 있으면 오류 메시지, 없으면 null
--%>
<%
	int roomId = Integer.parseInt(request.getParameter("roomId"));
	String checkIn = request.getParameter("checkIn");
	String checkOut = request.getParameter("checkOut");
	int guests = Integer.parseInt(request.getParameter("guests"));
	String mcIdStr = request.getParameter("mcId");
	int mcId = (mcIdStr == null || mcIdStr.equals("")) ? 0 : Integer.parseInt(mcIdStr);

	Room room = null;
	long nights = 0;
	int nightPrice = 0, roomTotal = 0, payTotal = 0, couponDiscount = 0;
	MemberCoupon coupon = null;
	java.util.List<MemberCoupon> usableCoupons = null;
	String checkError = null;

	Connection checkConn = ConnectionProvider.getConnection();
	try {
		room = new RoomDao().selectById(checkConn, roomId);

		// ① 날짜 / 인원 검사
		LocalDate inDate = LocalDate.parse(checkIn);
		LocalDate outDate = LocalDate.parse(checkOut);
		nights = ChronoUnit.DAYS.between(inDate, outDate);   // 몇 박인지

		if (room == null) {
			checkError = "없는 객실입니다.";
		} else if (inDate.isBefore(LocalDate.now())) {
			checkError = "지난 날짜는 예약할 수 없습니다.";
		} else if (nights < 1) {
			checkError = "체크아웃은 체크인 다음 날 이후여야 합니다.";
		} else if (guests < 1 || guests > room.getCapacity()) {
			checkError = "이 객실은 최대 " + room.getCapacity() + "명까지 이용할 수 있습니다.";
		}
		// ② 중복 예약 검사 : 같은 기간에 이미 예약이 있으면 막는다
		else if (new ReservationDao().countOverlap(checkConn, roomId, checkIn, checkOut) > 0) {
			checkError = "선택한 기간에 이미 예약이 있습니다. 다른 날짜를 선택해 주세요.";
		}

		// ③ 쿠폰 확인 (고른 경우에만) : 내 쿠폰함의 쿠폰이고, 안 썼고, 오늘이 사용 기간 안이어야 함
		MemberCouponDao mcDao = new MemberCouponDao();
		usableCoupons = mcDao.selectUsable(checkConn, (String) session.getAttribute("LOGIN"));
		if (checkError == null && mcId != 0) {
			coupon = mcDao.selectById(checkConn, mcId);
			if (coupon == null || !coupon.getUserId().equals(session.getAttribute("LOGIN")) || !coupon.isUsable()) {
				checkError = "사용할 수 없는 쿠폰입니다. (이미 썼거나 사용 기간이 아님)";
				coupon = null;
			}
		}

		// ④ 금액 계산
		if (checkError == null) {
			nightPrice = room.getNightPrice(guests);
			roomTotal = nightPrice * (int) nights;
			payTotal = roomTotal;
			if (coupon != null) {
				payTotal = roomTotal * (100 - coupon.getDiscountRate()) / 100;
			}
			couponDiscount = roomTotal - payTotal;
		}
	} catch (java.time.format.DateTimeParseException e) {
		checkError = "체크인과 체크아웃 날짜를 선택하세요.";   // 날짜를 비워서 보낸 경우
	} finally {
		JdbcUtil.close(checkConn);
	}
%>
