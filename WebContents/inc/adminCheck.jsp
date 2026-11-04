<%@ page pageEncoding="UTF-8" %>
<%--
	관리자 전용 페이지 맨 위에서 include
	로그인한 아이디가 admin 이 아니면 로그인 화면으로 보낸다.
--%>
<%
	if (!"admin".equals(session.getAttribute("LOGIN"))) {
		response.sendRedirect(request.getContextPath() + "/member/loginForm.jsp");
		return;
	}
%>
