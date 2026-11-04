<%@ page pageEncoding="UTF-8" %>
<%--
	로그인이 필요한 페이지 맨 위에서 include
	로그인 안 했으면 로그인 화면으로 보내고, 이 페이지의 나머지는 실행하지 않는다(return).
--%>
<%
	if (session.getAttribute("LOGIN") == null) {
		response.sendRedirect(request.getContextPath() + "/member/loginForm.jsp");
		return;
	}
%>
