<%@ page pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%-- 이용자 화면 공통 아랫부분 --%>
<%-- 오른쪽 아래 AI 상담 버튼 (상담 화면 자체에서는 숨김) --%>
<c:if test="${!pageContext.request.requestURI.endsWith('/chat/chatbot.jsp')}">
	<a class="chat-fab" href="${pageContext.request.contextPath}/chat/chatbot.jsp" title="AI 상담">
		<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><path d="M4 5h16v11H9l-5 4z"/><path d="M8 10h.01M12 10h.01M16 10h.01" stroke-linecap="round" stroke-width="2.2"/></svg>
		<span>AI 상담</span>
	</a>
</c:if>
<footer class="site-footer">
	<div class="inner">
		<div>
			<div class="brand">JAMJAM</div>
			호텔 잠잠 · 경기도 시흥시 배곧동 (가상 주소)
		</div>
		<div>
			<b>예약 문의</b>
			031-000-0000<br>
			체크인 15:00 / 체크아웃 11:00
		</div>
		<div>
			<b>만든 사람들</b>
			웹프로그래밍응용 텀프로젝트<br>
			팀 잠 좀 자자
		</div>
	</div>
	<div class="copy">© 2026 HOTEL JAMJAM. All rights reserved.</div>
</footer>
<%-- 영어를 골랐으면 화면의 한글을 영어로 바꾸는 스크립트 실행 --%>
<c:if test="${sessionScope.LANG == 'en'}">
	<%@ include file="/inc/translate.jsp" %>
</c:if>
</body>
</html>
