<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,my.util.*,my.dao.*,my.model.*" %>
<%@ include file="/inc/loginCheck.jsp" %>
<%-- 투숙객 등록 처리 (아이디는 폼이 아니라 세션 값) --%>
<% request.setCharacterEncoding("utf-8"); %>
<jsp:useBean id="guest" class="my.model.Guest"/>
<jsp:setProperty name="guest" property="*"/>
<%
	String loginId = (String) session.getAttribute("LOGIN");
	guest.setUserId(loginId);
	String msg = "투숙객을 등록했습니다.";

	Connection conn = ConnectionProvider.getConnection();
	try {
		GuestDao dao = new GuestDao();
		if (guest.getName() == null || guest.getName().trim().equals("") || guest.getPhone() == null || guest.getPhone().trim().equals("")) {
			msg = "이름과 연락처를 입력하세요.";
		} else if (dao.selectByUser(conn, loginId).size() >= 10) {
			msg = "투숙객은 10명까지 등록할 수 있습니다.";
		} else if (dao.exists(conn, loginId, guest.getName().trim(), guest.getPhone().trim())) {
			msg = "이미 등록한 투숙객입니다.";
		} else {
			guest.setName(guest.getName().trim());
			guest.setPhone(guest.getPhone().trim());
			dao.insert(conn, guest);
		}
	} finally {
		JdbcUtil.close(conn);
	}
%>
<script>
	alert("<%= msg %>");
	location.href = "guest.jsp";
</script>
