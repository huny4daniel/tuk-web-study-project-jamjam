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
	private String amenity;   // 편의시설 키워드 (욕조, 주방 ...)
	private String viewType;  // 전망 (오션뷰 / 시티뷰 / 파크뷰), 비어 있으면 상관없음
	private String sort;      // 정렬 기준 (price, rating, popular)
	private String available; // "1" 이면 예약 가능한 객실만 (아니면 마감 객실도 SOLD OUT 으로 보여줌)
	private String minPrice;  // 1박 할인가 하한 (이 금액 이상), 비어 있으면 상관없음
	private String maxPrice;  // 1박 할인가 상한 (이 금액 이하), 비어 있으면 상관없음

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
		q += param("viewType", viewType);
		q += param("sort", sort);
		q += param("available", available);
		q += param("minPrice", minPrice);
		q += param("maxPrice", maxPrice);
		return q;
	}

	// 가격 칸 값 -> 숫자. 비었거나 숫자가 아니거나 음수면 -1 (그 조건은 무시). 쉼표는 지우고 읽는다
	private static int toPrice(String s) {
		if (!has(s)) return -1;
		try {
			int v = Integer.parseInt(s.replace(",", "").trim());
			return v < 0 ? -1 : v;
		} catch (NumberFormatException e) {
			return -1;
		}
	}

	// 검색에 쓸 1박 할인가 범위 { 최소, 최대 } (RoomDao.setSearch 에서 사용)
	//   안 넣은 쪽은 0 / 아주 큰 값 → 항상 참. 최소가 최대보다 크면 서로 바꾼다
	public int[] priceRange() {
		int min = toPrice(minPrice);
		int max = toPrice(maxPrice);
		if (min < 0) min = 0;
		if (max < 0) max = Integer.MAX_VALUE;
		if (min > max) {
			int temp = min;
			min = max;
			max = temp;
		}
		return new int[] { min, max };
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
	public String getMinPrice() {
		return minPrice;
	}
	public void setMinPrice(String minPrice) {
		this.minPrice = minPrice;
	}
	public String getMaxPrice() {
		return maxPrice;
	}
	public void setMaxPrice(String maxPrice) {
		this.maxPrice = maxPrice;
	}
	public String getViewType() {
		return viewType;
	}
	public void setViewType(String viewType) {
		this.viewType = viewType;
	}
	public String getSort() {
		return sort;
	}
	public void setSort(String sort) {
		this.sort = sort;
	}
}
