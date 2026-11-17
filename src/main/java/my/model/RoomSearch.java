package my.model;

import java.net.URLEncoder;

// 객실 목록 화면의 검색/필터/정렬 조건을 담는 클래스
// roomList.jsp 에서 <jsp:setProperty property="*"> 로 폼 값이 자동으로 채워진다.
// (수업 login.jsp 에서 User 를 채우던 방식과 같음)
// 값이 비어 있을 수 있어서 모두 String 으로 받는다.
public class RoomSearch {
	private String checkIn;   // 체크인 날짜
	private String checkOut;  // 체크아웃 날짜
	private String guests;    // 인원
	private String breakfast; // "1" 이면 조식 포함 객실만
	private String pet;       // "1" 이면 반려동물 동반 가능 객실만
	private String bedCount;  // 최소 침대 수
	private String amenity;   // 편의시설 키워드 (욕조, 오션뷰 ...)
	private String sort;      // 정렬 기준 (price, rating, popular)
	private String available; // "1" 이면 예약 가능한 객실만 (아니면 마감 객실도 SOLD OUT 으로 보여줌)

	// 값이 들어 있는지 확인하는 도우미
	public static boolean has(String s) {
		return s != null && !s.trim().equals("");
	}

	// 페이지 번호 링크를 만들 때 지금 조건을 그대로 이어 붙이기 위한 문자열
	// 예) checkIn=2026-11-10&checkOut=2026-11-12&guests=2&sort=price
	public String getQueryString() {
		String q = "";
		q += param("checkIn", checkIn);
		q += param("checkOut", checkOut);
		q += param("guests", guests);
		q += param("breakfast", breakfast);
		q += param("pet", pet);
		q += param("bedCount", bedCount);
		q += param("amenity", amenity);
		q += param("sort", sort);
		q += param("available", available);
		return q;
	}

	private String param(String name, String value) {
		if (!has(value)) return "";
		try {
			return name + "=" + URLEncoder.encode(value, "UTF-8") + "&";
		} catch (Exception e) {
			return "";
		}
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
	public String getGuests() {
		return guests;
	}
	public void setGuests(String guests) {
		this.guests = guests;
	}
	public String getBreakfast() {
		return breakfast;
	}
	public void setBreakfast(String breakfast) {
		this.breakfast = breakfast;
	}
	public String getPet() {
		return pet;
	}
	public void setPet(String pet) {
		this.pet = pet;
	}
	public String getBedCount() {
		return bedCount;
	}
	public void setBedCount(String bedCount) {
		this.bedCount = bedCount;
	}
	public String getAmenity() {
		return amenity;
	}
	public void setAmenity(String amenity) {
		this.amenity = amenity;
	}
	public String getAvailable() {
		return available;
	}
	public void setAvailable(String available) {
		this.available = available;
	}
	// 날짜(체크인, 체크아웃)를 둘 다 넣었나?
	public boolean isDateSelected() {
		return has(checkIn) && has(checkOut);
	}
	public String getSort() {
		return sort;
	}
	public void setSort(String sort) {
		this.sort = sort;
	}
}
