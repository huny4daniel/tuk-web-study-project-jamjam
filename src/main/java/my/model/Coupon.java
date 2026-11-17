package my.model;

// 쿠폰 정보 (coupon 테이블 한 줄)
public class Coupon {
	private String couponCode;
	private String couponName;
	private int discountRate;
	// 날짜는 'yyyy-MM-dd' 문자열로 다룸
	private String startDate;
	private String endDate;
	// 받는 방법 : '가입축하'(회원가입 때 자동 지급) / '다운로드'(쿠폰함에서 직접 받기) / '관리자지급'
	private String issueType;
	// 관리자 화면용 : 이 쿠폰을 받은 회원 수 (테이블 컬럼 아님)
	private int issuedCount;

	public String getCouponCode() {
		return couponCode;
	}
	public void setCouponCode(String couponCode) {
		this.couponCode = couponCode;
	}
	public String getCouponName() {
		return couponName;
	}
	public void setCouponName(String couponName) {
		this.couponName = couponName;
	}
	public int getDiscountRate() {
		return discountRate;
	}
	public void setDiscountRate(int discountRate) {
		this.discountRate = discountRate;
	}
	public String getStartDate() {
		return startDate;
	}
	public void setStartDate(String startDate) {
		this.startDate = startDate;
	}
	public String getEndDate() {
		return endDate;
	}
	public void setEndDate(String endDate) {
		this.endDate = endDate;
	}
	public String getIssueType() {
		return issueType;
	}
	public void setIssueType(String issueType) {
		this.issueType = issueType;
	}
	public int getIssuedCount() {
		return issuedCount;
	}
	public void setIssuedCount(int issuedCount) {
		this.issuedCount = issuedCount;
	}
}
