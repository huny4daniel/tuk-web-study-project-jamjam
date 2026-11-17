<%@ page pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%--
	이용자 화면 공통 윗부분 (모든 이용자 페이지 맨 위에서 include)
	  <%@ include file="/inc/header.jsp" %>
	include 는 이 파일 내용을 그 페이지에 그대로 붙여넣는 것이라
	여기서 만든 변수(ctx, loginId, loginName)를 include 한 페이지에서 바로 쓸 수 있다.
	(그래서 include 한 페이지에서 같은 이름의 변수를 또 만들면 안 된다)
--%>
<%
	String ctx = request.getContextPath();                       // 예) /hotel
	String loginId = (String) session.getAttribute("LOGIN");     // 로그인 안 했으면 null
	String loginName = (String) session.getAttribute("NAME");

	// 관리자(admin)는 이용자 화면을 쓰지 않는다 → 어느 이용자 페이지로 들어와도 관리자 대시보드로 보냄
	if ("admin".equals(loginId)) {
		response.sendRedirect(ctx + "/admin/index.jsp");
		return;
	}
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>호텔 잠잠 - Hotel JAMJAM</title>
<link href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9/dist/web/static/pretendard.min.css" rel="stylesheet">
<link href="<%= ctx %>/css/style.css" rel="stylesheet" type="text/css">
</head>
<body>
<header class="site-header">
	<div class="inner">
		<a class="logo" href="<%= ctx %>/index.jsp">JAMJAM</a>
		<nav class="gnb">
			<a href="<%= ctx %>/room/roomList.jsp">객실 예약</a>
			<a href="<%= ctx %>/info/location.jsp">오시는 길</a>
			<a href="<%= ctx %>/info/tour.jsp">주변 즐길거리</a>
			<a href="<%= ctx %>/faq/faqList.jsp">자주 묻는 질문</a>
			<a href="<%= ctx %>/qna/qnaList.jsp">1:1 문의</a>
			<a href="<%= ctx %>/chat/chatbot.jsp">AI 상담</a>
		</nav>
		<div class="util">
			<%-- 언어 바꾸기 (영어는 AI 번역) --%>
			<span class="lang">
				<a href="<%= ctx %>/lang/setLang.jsp?lang=ko" class="${sessionScope.LANG != 'en' ? 'on' : ''}">KO</a>
				<a href="<%= ctx %>/lang/setLang.jsp?lang=en" class="${sessionScope.LANG == 'en' ? 'on' : ''}">EN</a>
			</span>
			<% if (loginId == null) { %>
				<a href="<%= ctx %>/member/loginForm.jsp">로그인</a>
				<a class="btn-line" href="<%= ctx %>/member/joinForm.jsp">회원가입</a>
			<% } else { %>
				<span><b><%= loginName %></b>님</span>
				<a href="<%= ctx %>/mypage/myPage.jsp">마이페이지</a>
				<a href="<%= ctx %>/member/logout.jsp">로그아웃</a>
			<% } %>
		</div>
	</div>
</header>
