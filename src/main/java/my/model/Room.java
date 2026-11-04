package my.model;

// 객실 정보 (room 테이블 한 줄 + 목록 화면용 통계값)
public class Room {
	private int roomId;
	private String roomType;
	private String roomNo;
	private int price;
	private int discountRate;
	private int capacity;
	private int bedCount;
	private int breakfast;
	private int pet;
	private String amenities;
	private String description;
	private byte[] photoData;   // 사진 파일 내용 그대로 (DB 의 LONGBLOB)
	private String photoType;   // 사진 종류 (image/jpeg, image/png ...)
	// 아래 3개는 테이블 컬럼이 아니라 select 할 때 계산해서 채우는 값
	private double avgRating;
	private int reviewCount;
	private int resCount;

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

	// 할인이 적용된 1박 가격 (JSP에서 ${room.salePrice} 로 사용)
	public int getSalePrice() {
		return price * (100 - discountRate) / 100;
	}
}
