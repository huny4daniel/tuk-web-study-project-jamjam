package my.model;

// 자주 묻는 질문 (faq 테이블 한 줄)
public class Faq {
	private int faqId;
	private String category;   // 분류 (예약·결제, 객실, 시설·서비스, 회원)
	private String question;
	private String answer;

	public int getFaqId() {
		return faqId;
	}
	public void setFaqId(int faqId) {
		this.faqId = faqId;
	}
	public String getCategory() {
		return category;
	}
	public void setCategory(String category) {
		this.category = category;
	}
	public String getQuestion() {
		return question;
	}
	public void setQuestion(String question) {
		this.question = question;
	}
	public String getAnswer() {
		return answer;
	}
	public void setAnswer(String answer) {
		this.answer = answer;
	}
}
