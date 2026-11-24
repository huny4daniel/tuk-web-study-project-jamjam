package my.model;

// 회원이 등록해 둔 결제수단 (pay_card 테이블 한 줄)
// ※ 모의 결제라서 카드번호 전체, 유효기간, CVC 는 받지도 저장하지도 않는다 (끝 4자리만)
public class PayCard {
	// 등록할 수 있는 카드사 (결제 화면 payForm.jsp 의 카드사 목록과 같게 유지)
	public static final String[] COMPANIES = { "신한카드", "국민카드", "삼성카드", "현대카드", "롯데카드", "하나카드", "우리카드", "BC카드" };

	private int cardId;
	private String userId;       // 등록한 회원
	private String cardCompany;  // 카드사
	private String cardName;     // 별칭 (예 : 여행용)
	private String last4;        // 카드번호 끝 4자리
	private boolean defaultCard; // 결제 화면에서 먼저 선택되는 기본 카드 (컬럼 이름은 isDefault)

	// 화면에 보여줄 이름 (예 : "신한카드 ****1234")
	public String getLabel() {
		return cardCompany + " ****" + last4;
	}

	public int getCardId() {
		return cardId;
	}
	public void setCardId(int cardId) {
		this.cardId = cardId;
	}
	public String getUserId() {
		return userId;
	}
	public void setUserId(String userId) {
		this.userId = userId;
	}
	public String getCardCompany() {
		return cardCompany;
	}
	public void setCardCompany(String cardCompany) {
		this.cardCompany = cardCompany;
	}
	public String getCardName() {
		return cardName;
	}
	public void setCardName(String cardName) {
		this.cardName = cardName;
	}
	public String getLast4() {
		return last4;
	}
	public void setLast4(String last4) {
		this.last4 = last4;
	}
	public boolean isDefaultCard() {
		return defaultCard;
	}
	public void setDefaultCard(boolean defaultCard) {
		this.defaultCard = defaultCard;
	}
}
