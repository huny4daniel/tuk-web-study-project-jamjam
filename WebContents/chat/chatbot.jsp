<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,java.util.*,my.util.*,my.model.*,my.ai.*" %>
<%--
	AI 상담 챗봇 (수업 CHAPTER10/ollama.jsp 와 같은 "폼 POST → Ollama → 답 보여주기" 방식)
	- 대화 내용은 세션("CHAT")에 List<ChatMessage> 로 쌓아서 채팅처럼 보여준다
	- 질문을 처리한 뒤에는 이 페이지로 다시 이동(redirect)해서 새로고침해도 같은 질문이 또 가지 않게 함
	- chatbot.jsp?reset=1 : 대화 지우기
	- 로그인하지 않아도 쓸 수 있다
--%>
<%
	request.setCharacterEncoding("utf-8");

	List<ChatMessage> chat = (List<ChatMessage>) session.getAttribute("CHAT");
	if (chat == null || request.getParameter("reset") != null) {
		chat = new ArrayList<ChatMessage>();
		chat.add(new ChatMessage("bot", "안녕하세요, 호텔 잠잠 AI 상담입니다. 객실, 요금, 체크인 시간, 오시는 길 등 궁금한 점을 물어보세요."));
		session.setAttribute("CHAT", chat);
	}

	String question = request.getParameter("question");
	if ("POST".equals(request.getMethod()) && question != null && !question.trim().equals("")) {
		question = question.trim();
		if (question.length() > 500) {
			question = question.substring(0, 500);   // 너무 긴 질문은 자름
		}
		String answer;
		String role = "bot";
		Connection conn = ConnectionProvider.getConnection();
		try {
			// 화면 언어가 영어면 영어로 답하게 한다
			answer = new HotelChatbot().ask(conn, chat, question, "en".equals(session.getAttribute("LANG")));
		} catch (Exception e) {
			// Ollama 가 꺼져 있거나 응답이 없을 때
			application.log("챗봇 응답 실패", e);
			role = "error";
			answer = "죄송합니다. 지금은 AI 상담 서버에 연결할 수 없습니다.\n"
					+ "급한 문의는 [1:1 문의] 메뉴나 대표전화 031-000-0000 으로 연락해 주세요.";
		} finally {
			JdbcUtil.close(conn);
		}
		chat.add(new ChatMessage("user", question));
		chat.add(new ChatMessage(role, answer));
		response.sendRedirect("chatbot.jsp#end");
		return;
	}
%>
<%@ include file="/inc/header.jsp" %>
<c:set var="chat" value="<%= chat %>"/>

<div class="container">
	<div class="chat-wrap">
		<div class="chat-head">
			<div>
				<span class="eyebrow">AI CONCIERGE</span>
				<h2 class="page-title">AI 상담</h2>
			</div>
			<a class="muted" href="chatbot.jsp?reset=1" onclick="return confirm('대화 내용을 지울까요?')">대화 지우기</a>
		</div>

		<div class="chat-box">
			<c:forEach var="msg" items="${chat}">
				<div class="msg ${msg.user ? 'me' : 'bot'}"><div class="bubble pre"><c:out value="${msg.text}"/></div></div>
			</c:forEach>
			<div id="end"></div>
		</div>

		<!-- 자주 하는 질문 : 누르면 그 문장으로 바로 질문을 보냄 -->
		<div class="chips">
			<button type="button" onclick="ask(this)">체크인, 체크아웃 시간이 언제인가요?</button>
			<button type="button" onclick="ask(this)">4명이 묵을 수 있는 객실을 추천해 주세요.</button>
			<button type="button" onclick="ask(this)">바다가 보이는 객실은 어떤 게 있나요?</button>
			<button type="button" onclick="ask(this)">반려동물과 함께 갈 수 있나요?</button>
			<button type="button" onclick="ask(this)">주차가 가능한가요?</button>
		</div>

		<form name="cf" class="chat-form" method="post" action="chatbot.jsp" onsubmit="return send(this)">
			<%-- 서버로 가는 질문은 이 숨은 칸 : 보내는 순간 입력칸(input)은 비우고 글은 여기에 옮겨 담는다 --%>
			<input type="hidden" name="question">
			<textarea name="input" rows="2" maxlength="500" placeholder="궁금한 점을 입력하세요 (Enter 전송, Shift+Enter 줄바꿈)"
				onkeydown="if (event.key == 'Enter' && !event.shiftKey) { event.preventDefault(); if (send(this.form)) this.form.submit(); }"></textarea>
			<input type="submit" id="sendBtn" class="btn btn-gold" value="보내기">
		</form>
		<p class="muted">AI 답변은 참고용입니다. 정확한 예약 가능 여부와 금액은 객실 예약 화면에서 확인해 주세요.</p>
	</div>
</div>

<script>
	// 예시 문장을 누르면 입력칸에 넣고 바로 보낸다 (보내기 버튼을 누른 것과 같음)
	function ask(btn) {
		var f = document.cf;
		f.input.value = btn.textContent;
		if (send(f)) {
			f.submit();
		}
	}

	// 채팅창 맨 아래에 말풍선 하나 붙이기 (who : "me" 내 질문 / "bot" AI)
	//   textContent 로 넣으므로 사용자가 쓴 글에 태그가 있어도 글자 그대로 보인다 (JSTL c:out 과 같은 효과)
	function addBubble(who, text) {
		var msg = document.createElement("div");
		msg.className = "msg " + who;
		var bubble = document.createElement("div");
		bubble.className = "bubble pre";
		bubble.textContent = text;
		msg.appendChild(bubble);
		box.appendChild(msg);
		box.scrollTop = box.scrollHeight;
		return bubble;
	}

	// 보내기 : AI 가 답을 만드는 데 시간이 걸리므로 (수업 ollama.jsp 처럼 버튼을 막고 안내)
	//   서버 답을 기다리지 않고 내 질문을 바로 채팅창에 띄우고, 그 아래에 "답변 생성 중" 말풍선을 보여준다.
	//   답이 오면 페이지가 새로 열리면서 서버에 저장된 대화(세션 CHAT)로 다시 그려진다.
	function send(f) {
		var text = f.input.value.trim();
		if (text == "" || f.question.value != "") return false;   // 빈 글, 이미 보내는 중이면 무시
		f.question.value = text;   // 서버로 갈 칸에 옮기고
		f.input.value = "";        // 입력칸은 비운다 (보낸 것처럼)
		addBubble("me", text);
		addBubble("bot", "${sessionScope.LANG == 'en' ? 'Writing an answer' : '답변 생성 중'}").className += " typing";
		// 답을 기다리는 동안 다시 보내지 못하게 버튼들을 막는다
		document.getElementById("sendBtn").disabled = true;
		var chips = document.querySelectorAll(".chips button");
		for (var i = 0; i < chips.length; i++) {
			chips[i].disabled = true;
		}
		return true;
	}
	// 마지막 대화가 보이게 아래로
	var box = document.querySelector(".chat-box");
	box.scrollTop = box.scrollHeight;

	// 뒤로 가기로 돌아오면 브라우저가 "보내는 중" 화면을 그대로 꺼내 보여줄 수 있어서, 그럴 땐 새로 불러온다
	window.onpageshow = function (e) {
		if (e.persisted) {
			location.reload();
		}
	};
</script>
<%@ include file="/inc/footer.jsp" %>
