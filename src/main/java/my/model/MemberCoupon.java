package my.model;

import java.time.LocalDate;
import java.util.Date;

// 회원이 가진 디지털 쿠폰 (member_coupon 테이블 한 줄 = 쿠폰함의 쿠폰 한 장)
// 쿠폰 이름, 할인율, 기간은 발급할 때 coupon 테이블에서 복사해 둔다
//   → join 없이 쿠폰함을 바로 보여줄 수 있다 (예약에 객실 이름을 같이 저장하는 것과 같은 방식)
public class MemberCoupon {
	private int mcId;
	private String userId;
	private String couponCode;
	private String couponName;
	private int discountRate;
	private String startDate;   // 'yyyy-MM-dd'
	private String endDate;
	private boolean used;       // 사용했으면 true
	private int usedResId;      // 어느 예약에 썼는지 (안 썼으면 0)
	private Date issueDate;

	// ---------- 화면용 계산 ----------
	// 사용 기간이 지났나?
	public boolean isExpired() {
		return endDate.compareTo(LocalDate.now().toString()) < 0;
	}
	// 아직 사용 기간 전인가?
	public boolean isNotStarted() {
		return startDate.compareTo(LocalDate.now().toString()) > 0;
	}
	// 지금 결제에 쓸 수 있나? (안 썼고, 기간 안)
	public boolean isUsable() {
		return !used && !isExpired() && !isNotStarted();
	}
	// 쿠폰함에 보여줄 상태 글자 (${mc.statusLabel})
	public String getStatusLabel() {
		if (used)          return "사용 완료";
		if (isExpired())   return "기간 만료";
		if (isNotStarted()) return "사용 기간 전";
		return "사용 가능";
	}

	// ---------- getter / setter ----------
	public int getMcId() {
		return mcId;
	}
	public void setMcId(int mcId) {
		this.mcId = mcId;
	}
	public String getUserId() {
		return userId;
	}
	public void setUserId(String userId) {
		this.userId = userId;
	}
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
	public boolean isUsed() {
		return used;
	}
	public void setUsed(boolean used) {
		this.used = used;
	}
	public int getUsedResId() {
		return usedResId;
	}
	public void setUsedResId(int usedResId) {
		this.usedResId = usedResId;
	}
	public Date getIssueDate() {
		return issueDate;
	}
	public void setIssueDate(Date issueDate) {
		this.issueDate = issueDate;
	}
}
