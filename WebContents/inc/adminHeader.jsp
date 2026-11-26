<%@ page pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%--
	관리자 화면 공통 윗부분 (관리자 페이지 맨 위에서 include)
	이용자 화면과 다르게 왼쪽 메뉴가 있는 관리자 전용 레이아웃을 쓴다.
	관리자인지 검사(adminCheck)도 여기서 같이 한다.
--%>
<%@ include file="/inc/adminCheck.jsp" %>
<%
	String ctx = request.getContextPath();
	String loginId = (String) session.getAttribute("LOGIN");
	String loginName = (String) session.getAttribute("NAME");
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>호텔 잠잠 관리자</title>
<link href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9/dist/web/static/pretendard.min.css" rel="stylesheet">
<link href="<%= ctx %>/css/style.css?v=6" rel="stylesheet" type="text/css">
</head>
<body class="admin">
<aside class="admin-side">
	<div class="logo">JAMJAM<br><small>ADMIN</small></div>
	<ul>
		<li><a href="<%= ctx %>/admin/index.jsp">대시보드</a></li>
		<li><a href="<%= ctx %>/admin/room/roomList.jsp">객실 관리</a></li>
		<li><a href="<%= ctx %>/admin/reservation/reservationList.jsp">예약 관리</a></li>
		<li><a href="<%= ctx %>/admin/coupon/couponList.jsp">할인 쿠폰 관리</a></li>
		<li><a href="<%= ctx %>/admin/qna/qnaList.jsp">문의 답변</a></li>
		<li><a href="<%= ctx %>/admin/faq/faqList.jsp">자주 묻는 질문</a></li>
		<li><a href="<%= ctx %>/admin/review/reviewList.jsp">리뷰 관리</a></li>
		<li><a href="<%= ctx %>/admin/member/memberList.jsp">회원 목록</a></li>
		<li><a href="<%= ctx %>/admin/ai/aiConsole.jsp">AI 도우미</a></li>
	</ul>
	<div class="bottom">
		<a href="<%= ctx %>/member/logout.jsp">로그아웃</a>
	</div>
</aside>
<div class="admin-main">
	<div class="topbar">
		<span>관리자 모드</span>
		<span><b><%= loginName %></b> (<%= loginId %>) 님 접속 중</span>
	</div>
