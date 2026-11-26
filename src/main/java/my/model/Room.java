package my.model;

// 객실 정보 (room 테이블 한 줄 + 목록 화면용 통계값)
public class Room {
	// 조식 미포함 객실에서 조식을 추가할 때 1인 1박 가격 (가격을 바꾸려면 여기만 고치면 됨)
	public static final int BREAKFAST_PRICE = 20000;

	private int roomId;
	private String roomType;
	private String roomNo;
	private int roomSize;       // 객실 크기 (평)
	private int price;
	private int discountRate;
	private int capacity;
	private int baseGuests;     // 기준 인원 (이 인원까지는 기본 요금)
	private int extraPrice;     // 기준 인원을 넘는 1명당 1박 추가 요금
	private int bedCount;
	private int breakfast;
	private int pet;
	private String viewType;    // 전망 (오션뷰 / 시티뷰 / 파크뷰)
	private String amenities;
	private String description;
	private byte[] photoData;   // 사진 파일 내용 그대로 (DB 의 LONGBLOB)
	private String photoType;   // 사진 종류 (image/jpeg, image/png ...)
	// 아래 3개는 테이블 컬럼이 아니라 select 할 때 계산해서 채우는 값
	private double avgRating;
	private int reviewCount;
	private int resCount;
	// 검색한 기간에 이미 예약된 기간들 (예 : "11-20 ~ 11-22") : 비어 있으면 예약 가능
	// 테이블 컬럼이 아니라 roomList.jsp 에서 addBooked() 로 채우는 화면용 값
	private String bookedText = "";

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
	public int getRoomSize() {
		return roomSize;
	}
	public void setRoomSize(int roomSize) {
		this.roomSize = roomSize;
	}
	// 평 -> 제곱미터 (1평 = 약 3.3058㎡, 반올림) : JSP 에서 ${room.roomSizeM2}
	public int getRoomSizeM2() {
		return (int) Math.round(roomSize * 3.3058);
	}
	public int getPrice() {
		return price;
	}
	public void setPrice(int price) {
		this.price = price;
	}
	public int getDiscountRate() {
		return discountRate;
	}
	public void setDiscountRate(int discountRate) {
		this.discountRate = discountRate;
	}
	public int getCapacity() {
		return capacity;
	}
	public void setCapacity(int capacity) {
		this.capacity = capacity;
	}
	public int getBaseGuests() {
		return baseGuests;
	}
	public void setBaseGuests(int baseGuests) {
		this.baseGuests = baseGuests;
	}
	public int getExtraPrice() {
		return extraPrice;
	}
	public void setExtraPrice(int extraPrice) {
		this.extraPrice = extraPrice;
	}
	public int getBedCount() {
		return bedCount;
	}
	public void setBedCount(int bedCount) {
		this.bedCount = bedCount;
	}
	public int getBreakfast() {
		return breakfast;
	}
	public void setBreakfast(int breakfast) {
		this.breakfast = breakfast;
	}
	public int getPet() {
		return pet;
	}
	public void setPet(int pet) {
		this.pet = pet;
	}
	public String getViewType() {
		return viewType;
	}
	public void setViewType(String viewType) {
		this.viewType = viewType;
	}
	public String getAmenities() {
		return amenities;
	}
	public void setAmenities(String amenities) {
		this.amenities = amenities;
	}
	public String getDescription() {
		return description;
	}
	public void setDescription(String description) {
		this.description = description;
	}
	public byte[] getPhotoData() {
		return photoData;
	}
	public void setPhotoData(byte[] photoData) {
		this.photoData = photoData;
	}
	public String getPhotoType() {
		return photoType;
	}
	public void setPhotoType(String photoType) {
		this.photoType = photoType;
	}
	public double getAvgRating() {
		return avgRating;
	}
	public void setAvgRating(double avgRating) {
		this.avgRating = avgRating;
	}
	public int getReviewCount() {
		return reviewCount;
	}
	public void setReviewCount(int reviewCount) {
		this.reviewCount = reviewCount;
	}
	public int getResCount() {
		return resCount;
	}
	public void setResCount(int resCount) {
		this.resCount = resCount;
	}

	// 검색 기간과 겹치는 예약 기간 하나 추가 ('yyyy-MM-dd' 에서 앞의 연도는 빼고 'MM-dd' 만)
	public void addBooked(String checkIn, String checkOut) {
		if (!bookedText.equals("")) {
			bookedText += ", ";
		}
		bookedText += checkIn.substring(5) + " ~ " + checkOut.substring(5);
	}
	public String getBookedText() {
		return bookedText;
	}
	// 검색 기간에 예약이 있어서 예약할 수 없나? (JSP 에서 ${room.soldOut})
	public boolean isSoldOut() {
		return !bookedText.equals("");
	}

	// 침대 표시 글자 : 한실 온돌처럼 침대가 없으면(0개) "온돌 (요)" (JSP 에서 ${room.bedLabel})
	public String getBedLabel() {
		if (bedCount == 0) {
			return "온돌 (요)";
		}
		return "침대 " + bedCount + "개";
	}

	// 할인이 적용된 1박 가격 (JSP에서 ${room.salePrice} 로 사용)
	public int getSalePrice() {
		return price * (100 - discountRate) / 100;
	}

	// ★ 인원에 따른 1박 요금 = 할인가 + (기준 인원을 넘는 사람 수 x 1인 추가 요금)
	//   예) 할인가 100,000원, 기준 2명, 추가 20,000원 -> 3명이면 120,000원, 2명 이하면 100,000원
	public int getNightPrice(int guests) {
		int extraGuests = guests - baseGuests;
		if (extraGuests < 0) {
			extraGuests = 0;
		}
		return getSalePrice() + extraGuests * extraPrice;
	}

	// ★ 기본 사진 : 관리자가 사진을 올리지 않은 객실(photo 가 NULL)은 images/rooms 의 그림을 쓴다.
	//   파일 이름 = 객실 유형 영어 이름 + "-" + 전망 영어 이름 + ".png"   예) 디럭스 + 시티뷰 -> deluxe-city.png
	//   room/photo.jsp 에서 이 이름으로 파일이 있는지 확인하고, 없으면 같은 유형의 다른 전망 그림을 찾는다.

	// 객실 유형 -> 그림 파일 이름 앞부분 (목록에 없는 새 유형이면 null -> 기본 그림 noimage.svg)
	public String getTypeImage() {
		if ("스탠다드".equals(roomType)) return "standard";
		if ("스탠다드 트윈".equals(roomType)) return "standard-twin";
		if ("슈페리어 트리플".equals(roomType)) return "superior-triple";
		if ("디럭스".equals(roomType)) return "deluxe";
		if ("디럭스 오션뷰".equals(roomType)) return "deluxe-oceanview";
		if ("디럭스 테라스".equals(roomType)) return "deluxe-terrace";
		if ("이그제큐티브 킹".equals(roomType)) return "executive-king";
		if ("패밀리".equals(roomType)) return "family";
		if ("펫 프렌들리".equals(roomType)) return "pet";
		if ("펫 패밀리".equals(roomType)) return "pet-family";
		if ("한실 온돌".equals(roomType)) return "ondol";
		if ("복층 로프트".equals(roomType)) return "loft";
		if ("주니어 스위트".equals(roomType)) return "junior-suite";
		if ("스파 스위트".equals(roomType)) return "spa-suite";
		if ("로열 스위트".equals(roomType)) return "royal-suite";
		return null;
	}

	// 전망 -> 그림 파일 이름 뒷부분
	public String getViewImage() {
		if ("오션뷰".equals(viewType)) return "ocean";
		if ("파크뷰".equals(viewType)) return "park";
		return "city";
	}
}
