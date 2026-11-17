package my.model;

// 챗봇 대화 한 줄 (세션에 List<ChatMessage> 로 쌓아 두고 화면에 보여줌)
// Serializable : 세션에 넣는 객체라서, 서버를 다시 켤 때 톰캣이 세션을 파일로 저장했다가 되살릴 수 있게 함
public class ChatMessage implements java.io.Serializable {
	private String role;   // "user"(손님), "bot"(챗봇), "error"(서버 연결 실패 안내 : AI 에게 다시 보내지 않음)
	private String text;

	public ChatMessage(String role, String text) {
		this.role = role;
		this.text = text;
	}

	public String getRole() {
		return role;
	}
	public String getText() {
		return text;
	}
	// 손님이 보낸 말인가? (JSP 에서 ${msg.user})
	public boolean isUser() {
		return role.equals("user");
	}
	// 연결 실패 안내인가? (다음 질문 때 대화 기록에서 뺀다)
	public boolean isError() {
		return role.equals("error");
	}
}
