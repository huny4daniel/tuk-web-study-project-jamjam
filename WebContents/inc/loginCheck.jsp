<%@ page pageEncoding="UTF-8" %>
<%--
	로그인이 필요한 페이지 맨 위에서 include
	로그인 안 했으면 로그인 화면으로 보내고, 이 페이지의 나머지는 실행하지 않는다(return).
	관리자(admin)는 이용자 기능(예약, 리뷰, 문의 작성 ...)을 쓰지 않으므로 관리자 대시보드로 보낸다.
--%>
<%
	if (session.getAttribute("LOGIN") == null) {
		response.sendRedirect(request.getContextPath() + "/member/loginForm.jsp");
		return;
	}
	if ("admin".equals(session.getAttribute("LOGIN"))) {
		response.sendRedirect(request.getContextPath() + "/admin/index.jsp");
		return;
	}
%>
