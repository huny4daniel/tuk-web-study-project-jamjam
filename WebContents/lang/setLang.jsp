<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%--
	언어 바꾸기 : setLang.jsp?lang=en (영어) / setLang.jsp?lang=ko (한국어)
	세션에 "LANG" 으로 저장하고, 보고 있던 페이지로 돌아간다.
--%>
<%
	String lang = request.getParameter("lang");
	session.setAttribute("LANG", "en".equals(lang) ? "en" : "ko");   // 정해진 두 값만 허용

	// 보고 있던 페이지(Referer)로 돌아가기. 우리 사이트 주소가 아니면 메인으로
	String back = request.getHeader("Referer");
	String home = request.getContextPath() + "/index.jsp";
	String site = "://" + request.getHeader("Host") + request.getContextPath() + "/";   // 예) ://localhost:8080/hotel/
	if (back == null || back.indexOf(site) < 0 || back.indexOf(site) > 5 || back.indexOf("/lang/") >= 0) {
		back = home;
	}
	response.sendRedirect(back);
%>
