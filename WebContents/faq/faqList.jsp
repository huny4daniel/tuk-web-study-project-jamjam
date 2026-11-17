<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,java.util.*,my.util.*,my.dao.*,my.model.*" %>
<%@ include file="/inc/header.jsp" %>
<%--
	자주 묻는 질문 (로그인 없이 볼 수 있음)
	faqList.jsp?category=객실 -> 그 분류만
	질문을 누르면 답이 펼쳐진다 (HTML 기본 태그 details / summary 사용, 자바스크립트 필요 없음)
--%>
<%
	request.setCharacterEncoding("utf-8");
	String category = request.getParameter("category");
	Connection conn = ConnectionProvider.getConnection();
	List<Faq> faqList = null;
	try {
		faqList = new FaqDao().selectList(conn, category);
	} finally {
		JdbcUtil.close(conn);
	}
%>
<c:set var="faqList" value="<%= faqList %>"/>
<div class="container">
	<span class="eyebrow">FAQ</span>
	<h2 class="page-title">자주 묻는 질문</h2>
	<p class="page-sub">궁금한 질문을 누르면 답변이 펼쳐집니다.</p>

	<div class="tabs">
		<a href="faqList.jsp" class="${empty param.category ? 'on' : ''}">전체</a>
		<a href="faqList.jsp?category=예약·결제" class="${param.category == '예약·결제' ? 'on' : ''}">예약·결제</a>
		<a href="faqList.jsp?category=객실" class="${param.category == '객실' ? 'on' : ''}">객실</a>
		<a href="faqList.jsp?category=시설·서비스" class="${param.category == '시설·서비스' ? 'on' : ''}">시설·서비스</a>
		<a href="faqList.jsp?category=회원" class="${param.category == '회원' ? 'on' : ''}">회원</a>
	</div>

	<div class="faq-list">
		<c:if test="${empty faqList}">
			<p class="muted">등록된 질문이 없습니다.</p>
		</c:if>
		<c:forEach var="faq" items="${faqList}">
			<details class="faq">
				<summary><span class="cat">${faq.category}</span><c:out value="${faq.question}"/></summary>
				<div class="pre"><c:out value="${faq.answer}"/></div>
			</details>
		</c:forEach>
	</div>

	<div class="box faq-more">
		<div>
			<h3>원하는 답을 찾지 못하셨나요?</h3>
			<span class="muted">AI 상담은 바로, 1:1 문의는 호텔 직원이 직접 답변해 드립니다.</span>
		</div>
		<div class="route-btns">
			<a class="btn btn-gold" href="<%= ctx %>/chat/chatbot.jsp">AI 상담</a>
			<a class="btn btn-line" href="<%= ctx %>/qna/qnaList.jsp">1:1 문의</a>
		</div>
	</div>
</div>
<%@ include file="/inc/footer.jsp" %>
