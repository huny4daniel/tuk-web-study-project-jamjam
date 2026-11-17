package my.model;

import java.time.LocalDate;
import java.util.Date;

// 예약 정보 (reservation 테이블 한 줄)
public class Reservation {
	private int resId;
	private String userId;
	private int roomId;
	private String roomType;    // 예약할 때의 객실 이름
	private String roomNo;
	private String checkIn;     // 'yyyy-MM-dd' 문자열
	private String checkOut;
	private int guests;
	private int totalPrice;
	private String couponCode;
	private String payMethod;
	private String payDetail;   // 결제 상세 (예 : "신한카드 / 일시불")
	private String requestNote; // 고객 요청사항 (없으면 null)
	private String guestName;   // 실제 투숙객 이름 (예약자와 다를 수 있음)
	private String guestPhone;
	private String status;      // '예약완료' 또는 '취소'
	private boolean reviewed;   // 리뷰를 썼으면 true
	private Date resDate;

	// ---------- 화면에서 쓰기 편하게 만든 계산 메서드 ----------
	// 'yyyy-MM-dd' 문자열은 글자 순서로 비교해도 날짜 순서와 같다 (compareTo)

	// 체크아웃 날짜가 지났나? (오늘 이전이거나 오늘)
	public boolean isFinished() {
		return checkOut.compareTo(LocalDate.now().toString()) <= 0;
	}

	// 체크인 날짜가 되었나?
	public boolean isStarted() {
		return checkIn.compareTo(LocalDate.now().toString()) <= 0;
	}

	// 화면에 보여줄 상태 글자 (JSP 에서 ${res.statusLabel})
	public String getStatusLabel() {
		if (status.equals("취소")) return "취소";
		if (isFinished())          return "이용 완료";
		if (isStarted())           return "투숙 중";
		return "예약 완료";
	}

	// 이용자가 취소할 수 있나? (예약완료 상태이고 체크인 전) -> ${res.cancelable}
	public boolean isCancelable() {
		return status.equals("예약완료") && !isStarted();
	}

	// 리뷰를 쓸 수 있나? (예약완료 상태, 숙박을 마쳤고, 아직 안 썼음) -> ${res.reviewable}
	public boolean isReviewable() {
		return status.equals("예약완료") && isFinished() && !reviewed;
	}

	// ---------- getter / setter ----------
	public int getResId() {
		return resId;
	}
	public void setResId(int resId) {
		this.resId = resId;
	}
	public String getUserId() {
		return userId;
	}
	public void setUserId(String userId) {
		this.userId = userId;
	}
	public int getRoomId() {
		return roomId;
	}
	public void setRoomId(int roomId) {
		this.roomId = roomId;
	}
	public String getRoomType() {
		return roomType;
	}
	public void setRoomType(String roomType) {
		this.roomType = roomType;
	}
	public String getRoomNo() {
		return roomNo;
	}
	public void setRoomNo(String roomNo) {
		this.roomNo = roomNo;
	}
	public String getCheckIn() {
		return checkIn;
	}
	public void setCheckIn(String checkIn) {
		this.checkIn = checkIn;
	}
	public String getCheckOut() {
		return checkOut;
	}
	public void setCheckOut(String checkOut) {
		this.checkOut = checkOut;
	}
	public int getGuests() {
		return guests;
	}
	public void setGuests(int guests) {
		this.guests = guests;
	}
	public int getTotalPrice() {
		return totalPrice;
	}
	public void setTotalPrice(int totalPrice) {
		this.totalPrice = totalPrice;
	}
	public String getCouponCode() {
		return couponCode;
	}
	public void setCouponCode(String couponCode) {
		this.couponCode = couponCode;
	}
	public String getPayMethod() {
		return payMethod;
	}
	public void setPayMethod(String payMethod) {
		this.payMethod = payMethod;
	}
	public String getPayDetail() {
		return payDetail;
	}
	public void setPayDetail(String payDetail) {
		this.payDetail = payDetail;
	}
	public String getRequestNote() {
		return requestNote;
	}
	public void setRequestNote(String requestNote) {
		this.requestNote = requestNote;
	}
	public String getGuestName() {
		return guestName;
	}
	public void setGuestName(String guestName) {
		this.guestName = guestName;
	}
	public String getGuestPhone() {
		return guestPhone;
	}
	public void setGuestPhone(String guestPhone) {
		this.guestPhone = guestPhone;
	}
	public String getStatus() {
		return status;
	}
	public void setStatus(String status) {
		this.status = status;
	}
	public boolean isReviewed() {
		return reviewed;
	}
	public void setReviewed(boolean reviewed) {
		this.reviewed = reviewed;
	}
	public Date getResDate() {
		return resDate;
	}
	public void setResDate(Date resDate) {
		this.resDate = resDate;
	}
}
