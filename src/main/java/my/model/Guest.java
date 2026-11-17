package my.model;

// 회원이 등록해 둔 투숙객 (guest 테이블 한 줄)
// 예약할 때 결제 화면에서 골라서 이름·연락처를 바로 채운다
public class Guest {
	private int guestId;
	private String userId;     // 등록한 회원
	private String name;
	private String phone;
	private String relation;   // 관계 (가족, 친구, 동료 ...)

	public int getGuestId() {
		return guestId;
	}
	public void setGuestId(int guestId) {
		this.guestId = guestId;
	}
	public String getUserId() {
		return userId;
	}
	public void setUserId(String userId) {
		this.userId = userId;
	}
	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}
	public String getPhone() {
		return phone;
	}
	public void setPhone(String phone) {
		this.phone = phone;
	}
	public String getRelation() {
		return relation;
	}
	public void setRelation(String relation) {
		this.relation = relation;
	}
}
